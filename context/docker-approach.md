# Docker Microservice Tooling Pattern

This architecture implements the **Microservice Tooling Pattern**. It isolates all dependencies by utilizing Docker strictly as transient CLI tools rather than traditional monolithic environments.

## Core Properties

### 1. Zero-Install Host
The developer host environment remains perfectly clean. Docker is the only software that must be explicitly installed natively on the developer's machine. By mapping local directories securely into containers (e.g., `volumes: - .:/workspace`), Docker tools execute against native files sequentially without requiring other local software installations (such as Node or Java).

### 2. Ephemeral Build Tools
Compilers and generators execute as isolated commands that start, process file inputs, emit generated code entirely to a shared `/build` directory, and terminate instantly. 
* **Example:** A TypeSpec container executes, compiles the API definitions into an OpenAPI schema, and exits completely to release system memory.

### 3. Separation of Concerns
Images strictly manage exactly one operation and one native runtime.
* **Example:** One dedicated container defines API models, a separate container explicitly serves the backend traffic, and an isolated third container strictly runs the test suites.

### 4. Direct Networking
System testing validates infrastructure natively from inside the private Docker network.
* **Example:** A functional testing container targets `http://rest-server:8080`, bypassing host port mapping entirely for secure local verification.
