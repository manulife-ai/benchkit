# Database Configuration Guide

## Overview

BenchKit uses MongoDB with Mongoose for data persistence, implemented through the `nuxt-mongoose` module. The setup supports both local development with MongoDB and production deployment with Azure Cosmos DB.

## Models

### User Model (`/models/User.ts`)

- Stores user authentication and profile information
- Linked to Azure AD via `azureId`
- Role-based access control (admin, user, reviewer)

### Project Model (`/models/Project.ts`)

- Organizes test cases into projects
- Supports project ownership and membership
- Links users to specific projects

### TestCase Model (`/models/TestCase.ts`)

- Core entity for benchmarking workflow
- Supports multiple input files (PDF, images, text, JSON)
- Tracks assignment to users and projects
- Stores validation history with user comments

## Environment Configuration

### Local Development

```env
MONGODB_URI=mongodb://localhost:27017/benchkit
```

### Production (Azure Cosmos DB)

```env
MONGODB_URI=mongodb://your-cosmos-account.mongo.cosmos.azure.com:10255/benchkit?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@your-cosmos-account@
```

## API Endpoints

### Users

- `GET /api/users` - List all users
- `POST /api/users` - Create new user

### Projects

- `GET /api/projects` - List all projects with populated owner/members
- `POST /api/projects` - Create new project

### Test Cases

- `GET /api/test-cases` - List test cases (filterable by project/user)
- `POST /api/test-cases` - Create new test case
- `POST /api/test-cases/:id/validate` - Add validation to test case

## Usage in Components

```typescript
// Using the database composables
const { getUsers, createUser } = useUsers();
const { getProjects, createProject } = useProjects();
const { getTestCases, createTestCase, validateTestCase } = useTestCases();

// Example: Fetch test cases for a specific project
const testCases = await getTestCases({ project: projectId });

// Example: Validate a test case
await validateTestCase(testCaseId, {
  user: currentUserId,
  comment: "Document extraction looks accurate",
  data: { extracted: "validated data" },
});
```

## Database Seeding

For development and testing, use the provided seed script:

```bash
npm run db:seed
```

This creates sample users, projects, and test cases to get started quickly.

## Connection Management

The database connection is automatically managed through:

- **Nitro Plugin**: `/server/plugins/database.ts` - Initializes connection on server start
- **Utility Functions**: `/server/utils/database.ts` - Handles connection logic and Cosmos DB detection
- **Auto-reconnection**: Built-in MongoDB driver reconnection logic

## Schema Flexibility

The MongoDB schema is designed for flexibility:

- **Mixed types** for JSON data (original/validated fields)
- **Array fields** for multiple inputs and validations
- **ObjectId references** with population for related data
- **Timestamps** automatically managed by Mongoose

This setup provides a robust foundation for the BenchKit application's data layer, supporting both the current requirements and future scalability needs.
