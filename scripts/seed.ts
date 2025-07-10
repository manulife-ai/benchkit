import mongoose from "mongoose";
import { Project, TestCase, User } from "../models";

async function seedDatabase() {
  try {
    // Connect to database
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/benchkit";
    await mongoose.connect(uri);
    console.log("Connected to MongoDB");

    // Clear existing data (optional, for development)
    await User.deleteMany({});
    await Project.deleteMany({});
    await TestCase.deleteMany({});

    // Create sample users
    const adminUser = await User.create({
      email: "admin@example.com",
      name: "Admin User",
      role: "admin",
      azureId: "azure-admin-id",
    });

    const reviewerUser = await User.create({
      email: "reviewer@example.com",
      name: "Reviewer User",
      role: "reviewer",
      azureId: "azure-reviewer-id",
    });

    console.log("Created users:", {
      admin: adminUser._id,
      reviewer: reviewerUser._id,
    });

    // Create sample project
    const project = await Project.create({
      name: "Sample Project",
      description: "A sample project for testing",
      owner: adminUser._id,
      members: [reviewerUser._id],
    });

    console.log("Created project:", project._id);

    // Create sample test case
    const testCase = await TestCase.create({
      inputs: [
        {
          type: "pdf",
          file: "uploads/sample-document.pdf",
          filename: "sample-document.pdf",
        },
      ],
      original: {
        title: "Sample Document",
        content: "This is expected content from the document",
        metadata: {
          pages: 5,
          language: "en",
        },
      },
      assigned: [
        {
          user: reviewerUser._id,
          project: project._id,
        },
      ],
    });

    console.log("Created test case:", testCase._id);
    console.log("Database seeded successfully!");
  } catch (error) {
    console.error("Error seeding database:", error);
  } finally {
    await mongoose.disconnect();
  }
}

// Run if called directly
if (require.main === module) {
  seedDatabase();
}

export default seedDatabase;
