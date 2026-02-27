import { TestCase } from "~~/models";

export default defineEventHandler(async (event) => {
  try {
    const query = getQuery(event);

    // Build filter based on query parameters
    const filter: any = {};

    if (query.project) {
      filter["assigned.project"] = query.project;
    }

    if (query.user) {
      filter["assigned.user"] = query.user;
    }

    const testCases = await TestCase.find(filter)
      .populate("assigned.user", "name email")
      .populate("assigned.project", "name")
      .populate("validated.user", "name email")
      .sort({ createdAt: -1 });

    return testCases;
  } catch (error) {
    throw createError({
      statusCode: 500,
      statusMessage: "Failed to fetch test cases",
      data: error,
    });
  }
});
