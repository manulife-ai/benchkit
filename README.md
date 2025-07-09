# BenchKit

Gen AI-powered Benchmarking Tool

## Setup

Make sure to install dependencies:

```bash
npm install
```

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev
```

Build the application for production:

```bash
npm run build
```

Locally preview production build:

```bash
# npm
npm run preview
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

- blob
  - inputs
- db
  - collections
    - users
    - projects
    - test_cases
      - inputs (list of objects)
        - type (pdf, img, txt)
        - file (file path)
      - timestamp
      - assigned (list of objects)
        - user (user ID)
        - project (project ID)
      - original (object)
      - validated (list of objects)
        - timestamp
        - user
        - comment
