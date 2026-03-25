# Milestone: Split User Names

We will replace the `full_name` column in the `Users` table with `first_name` and `last_name`. This allows clients to capture and format user names more flexibly. Both the database columns and the API specifications will treat these fields as optional.

# Part 1: SQLite Schema Updates
Modify `DatabaseFactory.kt` by removing the `fullName` mapping and introducing `firstName` and `lastName` (both `varchar(255)`, nullable).

# Part 2: API Specifications
Update `specs/api/main.tsp` to replace `fullName?: string;` with `firstName?: string;` and `lastName?: string;` inside the `User` model.

# Part 3: Stubs Regeneration
Execute the OpenAPI build scripts to emit the updated swift models for the iOS client.
