-- Unified Queue Architecture Schema
-- Bootstraps unified polling tables mapping dynamically configured JSON instances.

CREATE TABLE queue_messages (
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL,
    payload JSONB NOT NULL,
    attempt_count INT NOT NULL DEFAULT 0,
    max_retries INT NOT NULL DEFAULT 3,
    retry_delay_ms BIGINT NOT NULL DEFAULT 5000,
    max_work_duration_ms BIGINT NOT NULL DEFAULT 300000,
    process_after TIMESTAMP WITH TIME ZONE,
    error_messages JSONB,
    locked_at TIMESTAMP WITH TIME ZONE,
    locked_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Index optimizing SKIP LOCKED queries targeting specific execution mappings immediately.
CREATE INDEX idx_queue_messages_dispatch 
ON queue_messages (type, process_after, locked_until);

CREATE TABLE queue_history (
    queue_message_id INT PRIMARY KEY,
    type VARCHAR(255) NOT NULL,
    attempt_count INT NOT NULL,
    error_messages JSONB,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE queue_failures (
    queue_message_id INT PRIMARY KEY,
    type VARCHAR(255) NOT NULL,
    payload JSONB NOT NULL,
    error_messages JSONB NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    failed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Trigger notifying distinct queue listener threads organically mitigating standard loops
CREATE OR REPLACE FUNCTION notify_queue_message()
RETURNS trigger AS $$
BEGIN
  PERFORM pg_notify('queue_event', NEW.type);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER queue_message_notify_trigger
AFTER INSERT ON queue_messages
FOR EACH ROW
EXECUTE FUNCTION notify_queue_message();

-- Atomic Completion Function
CREATE OR REPLACE FUNCTION fn_on_queue_message_complete(p_id INT)
RETURNS BOOLEAN AS $$
DECLARE
   v_count INT;
BEGIN
   INSERT INTO queue_history (queue_message_id, type, attempt_count, started_at, error_messages)
   SELECT id, type, attempt_count, locked_at, error_messages
   FROM queue_messages
   WHERE id = p_id;
   
   GET DIAGNOSTICS v_count = ROW_COUNT;
   IF v_count = 0 THEN
       RETURN FALSE;
   END IF;
   
   DELETE FROM queue_messages WHERE id = p_id;
   RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Atomic Failure & Retry Function
CREATE OR REPLACE FUNCTION fn_on_queue_message_failure(p_id INT, p_error TEXT)
RETURNS BOOLEAN AS $$
DECLARE
   v_row queue_messages%ROWTYPE;
   v_new_errors JSONB;
BEGIN
   SELECT * INTO v_row FROM queue_messages WHERE id = p_id FOR UPDATE;
   IF NOT FOUND THEN RETURN FALSE; END IF;
   
   v_new_errors := COALESCE(v_row.error_messages, '[]'::jsonb) || to_jsonb(p_error);

   IF v_row.attempt_count >= v_row.max_retries THEN
       INSERT INTO queue_failures (queue_message_id, type, payload, error_messages, started_at)
       VALUES (v_row.id, v_row.type, v_row.payload, v_new_errors, v_row.locked_at);
       
       DELETE FROM queue_messages WHERE id = p_id;
   ELSE
       UPDATE queue_messages
       SET error_messages = v_new_errors,
           locked_until = NULL,
           process_after = NOW() + (v_row.retry_delay_ms || ' milliseconds')::INTERVAL
       WHERE id = p_id;
   END IF;
   
   RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
