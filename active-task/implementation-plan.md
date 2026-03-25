# Implementation Plan: Split User Names

## Step 1: Update API Specification
Modify `specs/api/main.tsp` inside the `User` model. Replace `fullName?: string;` with `firstName?: string;` and `lastName?: string;`.

## Step 2: Update Database Schema
Modify `rest-server/src/main/kotlin/com/echoapp/server/DatabaseFactory.kt` inside the `Users` table. Replace `val fullName = varchar("full_name", 255).nullable()` with `firstName` and `lastName` (both `varchar(255).nullable()`).

## Step 3: Clear Development Database
Run `rm rest-server/data/echo.db` to delete the existing database. This will allow the Exposed framework to reconstruct the schema cleanly on the next startup. 

## Step 4: Rebuild and Verify
Run `./bin/build` to regenerate the OpenAPI outputs. Then run `./bin/restart-rest-server` and `./bin/test` to verify compiling routes against the new schema.
