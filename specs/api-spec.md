# Echo API Specification

This document summarizes our REST API capabilities. We use **TypeSpec** as the source of truth to define our APIs formally in code, which compiles down to OpenApi/Swagger.

## 1. The `echo` Endpoint
This is our initial "tracer bullet" method to validate the server, the client, and the OpenAPI generation pipeline.

- **Path:** `/echo`
- **Method:** `POST`
- **Description:** Accepts a standard JSON payload containing a text string, and echoes that same string back.

### Expected Request Body
```json
{
  "message": "Hello, Pipeline!"
}
```

### Expected Response (200 OK)
```json
{
  "message": "Hello, Pipeline!"
}
```
