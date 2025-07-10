import mongoose from "mongoose";

export async function connectToDatabase() {
  if (mongoose.connections[0].readyState) {
    return;
  }

  const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/benchkit";

  const options: mongoose.ConnectOptions = {
    bufferCommands: false,
  };

  // Add Cosmos DB specific options if using Azure Cosmos DB
  if (uri.includes("cosmos.azure.com")) {
    options.ssl = true;
    options.retryWrites = false;
    options.maxIdleTimeMS = 120000;
  }

  try {
    await mongoose.connect(uri, options);
    console.log("Connected to MongoDB");
  } catch (error) {
    console.error("Database connection error:", error);
    throw error;
  }
}

export function isCosmosDB(): boolean {
  const uri = process.env.MONGODB_URI || "";
  return uri.includes("cosmos.azure.com");
}
