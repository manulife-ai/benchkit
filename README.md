# BenchKit

Gen AI-powered Benchmarking Tool

## Setup

Make sure to install dependencies:

```bash
pnpm install
```

### Database Setup

This project uses MongoDB with mongoose for data persistence. You can run it locally during development and connect to Azure Cosmos DB for production.

#### Quick Start

For the fastest setup, run the setup script:

```bash
./setup.sh
```

This will check your MongoDB installation and create the necessary files and directories.

#### Local Development

**Option 1: Local MongoDB Installation (Recommended)**

1. Install MongoDB locally:

```bash
# macOS (using Homebrew)
brew install mongodb/brew/mongodb-community

# Ubuntu/Debian
sudo apt-get install mongodb

# Windows
# Download from https://www.mongodb.com/try/download/community
```

2. Copy the environment file:

```bash
cp .env.example .env
```

3. Start development (MongoDB + Nuxt concurrently):

```bash
pnpm dev
```

**Option 2: External MongoDB Instance**

If you have MongoDB running elsewhere (remote server, cloud instance, etc.):

```bash
# Update .env with your MongoDB connection string
MONGODB_URI=mongodb://your-host:27017/benchkit

# Start Nuxt only
pnpm dev:standalone
```

**Note**: During development, uploaded files are stored locally in `/public/uploads/`. For production, you should configure Azure Blob Storage or another cloud storage solution.

#### Production (Azure Cosmos DB)

For production deployment with Azure Cosmos DB:

1. Create a Cosmos DB account with MongoDB API
2. Update your `.env` file with the Cosmos DB connection string:

```env
MONGODB_URI=mongodb://your-cosmos-account.mongo.cosmos.azure.com:10255/benchkit?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@your-cosmos-account@
```

### Running the Application

**Development Mode (with MongoDB)**

Start both MongoDB and Nuxt concurrently:

```bash
pnpm dev
```

This will start:

- MongoDB server on port 27017 (if installed locally)
- Nuxt development server on http://localhost:3000

**Other Available Scripts**

```bash
pnpm dev:standalone    # Start Nuxt only (if MongoDB is running elsewhere)
```

### Getting Started with Database

1. **Create Users and Projects**: Visit the Manage page (`/manage`) and use the Users and Projects tabs to create your initial data
2. **Create Test Cases**: Use the file upload in the Samples tab to create new test cases
3. **Review Samples**: Go to the Review page (`/review`) to validate test cases
4. **View Data**: Check the Users and Projects tabs to see the created data

The application will automatically connect to your local MongoDB instance or Cosmos DB based on the `MONGODB_URI` environment variable.

### Troubleshooting

**MongoDB Connection Issues:**

1. **Port 27017 already in use**: Stop any existing MongoDB instances with `sudo pkill mongod`
2. **Permission denied**: Ensure the `data/db` directory has proper permissions: `chmod 755 data/db`
3. **MongoDB not found**: Install MongoDB locally following the installation instructions above

**Development Scripts:**

- `pnpm dev` - Start MongoDB + Nuxt concurrently (recommended)
- `pnpm dev:standalone` - Start Nuxt only (if MongoDB running elsewhere)
- `./setup.sh` - Quick setup script for new environments

Build the application for production:

```bash
pnpm build
```

Locally preview production build:

```bash
pnpm preview
```

## Features

This application is designed to manage and benchmark test cases.
The main feature allows users to manage test cases and review benchmarks.
The validation process consists of an user interface for validating input(s) against expected output(s).
For example, a user can upload a PDF or image file and validate it against a JSON output.

Pages:

- Login page
  - Connected to Azure AD for authentication
- Manage
  - Role-based access control
  - Create, edit, and delete test cases
    - Needs to support upload multiple files and file types (json, img, pdf, txt)
    - Needs to link between input(s) (pdf, txt, img) and output (json)
  - Assign test cases to projects and users
- Review
  - Selection
    - Show/filter samples with table view
    - Navigate between samples with keyboard
    - Show progress with progress bar
  - Validation
    - Show input(s) on the left, validation on the right
    - Navigate between input fields with keyboard
    - Add note with text/voice
    - Submit button to log validation
      - Push into the validated list
    - Show validation history
- Analyse
  - Show and filter benchmark results
  - Compare benchmarks
  - use `jsondiffpatch`
- Backend API
  - CRUD operations for test cases
  - Authentication with Azure AD
  - File upload handling
  - Fetch benchmark results
  - Fetch validated dataset

### API Endpoints

#### Users

- `GET /api/users` - Get all users
- `POST /api/users` - Create a new user

#### Projects

- `GET /api/projects` - Get all projects
- `POST /api/projects` - Create a new project

#### Test Cases

- `GET /api/test-cases` - Get test cases (supports ?project=id&user=id filters)
- `POST /api/test-cases` - Create a new test case
- `POST /api/test-cases/:id/validate` - Add validation to a test case

### Database Integration

The application uses nuxt-mongoose for seamless MongoDB integration:

- **Models**: Located in `/models/` directory with TypeScript interfaces
- **Auto-connection**: Database connection is automatically established
- **Environment-aware**: Switches between local MongoDB and Cosmos DB based on connection string
- **Type-safe**: Full TypeScript support for all database operations

Usage in components:

```typescript
// Get all users
const { getUsers } = useUsers();
const users = await getUsers();

// Create a test case
const { createTestCase } = useTestCases();
const testCase = await createTestCase({
  inputs: [{ type: "pdf", file: "path/to/file.pdf", filename: "document.pdf" }],
  original: { expected: "data" },
  assigned: [{ user: userId, project: projectId }],
});
```

- blob
  - inputs
- db
  - collections
    - users
      - email (string, unique)
      - name (string)
      - role (enum: 'admin', 'user', 'reviewer')
      - azureId (string, unique)
      - timestamps
    - projects
      - name (string)
      - description (string, optional)
      - owner (ObjectId ref User)
      - members (array of ObjectId ref User)
      - timestamps
    - test_cases
      - inputs (array of objects)
        - type (enum: 'pdf', 'img', 'txt', 'json')
        - file (string, file path)
        - filename (string)
      - original (object, expected JSON output)
      - assigned (array of objects)
        - user (ObjectId ref User)
        - project (ObjectId ref Project)
      - validated (array of objects)
        - timestamp (Date)
        - user (ObjectId ref User)
        - comment (string, optional)
        - data (object, validated JSON data)
      - timestamps
