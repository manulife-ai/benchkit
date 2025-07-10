import { connectToDatabase } from "../utils/database";

export default async () => {
  try {
    await connectToDatabase();
    console.log("Database connection initialized");
  } catch (error) {
    console.error("Failed to initialize database connection:", error);
  }
};
