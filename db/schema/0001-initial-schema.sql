CREATE TABLE "users" (
    "id" VARCHAR(8) PRIMARY KEY, 
    "email" VARCHAR(255) UNIQUE NOT NULL, 
    "password_hash" VARCHAR(255) NOT NULL, 
    "first_name" VARCHAR(255) NULL, 
    "last_name" VARCHAR(255) NULL, 
    "display_name" VARCHAR(255) NULL, 
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
