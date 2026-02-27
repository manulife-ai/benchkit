import { TestCase } from "~~/models";

export default defineEventHandler(async (event) => {
  try {
    const testCaseId = getRouterParam(event, "id");

    if (!testCaseId) {
      throw createError({
        statusCode: 400,
        statusMessage: "Test case ID is required",
      });
    }

    const body = await readBody(event);
    const method = body._method || "GET";

    if (method === "DELETE") {
      const result = await TestCase.findByIdAndDelete(testCaseId);

      if (!result) {
        throw createError({
          statusCode: 404,
          statusMessage: "Test case not found",
        });
      }

      return { success: true, message: "Test case deleted successfully" };
    }

    if (method === "PATCH") {
      const { _method, ...updateData } = body;

      const updatedTestCase = await TestCase.findByIdAndUpdate(
        testCaseId,
        { ...updateData, updatedAt: new Date() },
        { new: true, runValidators: true },
      )
        .populate("assigned.project", "name")
        .populate("assigned.user", "name email");

      if (!updatedTestCase) {
        throw createError({
          statusCode: 404,
          statusMessage: "Test case not found",
        });
      }

      return updatedTestCase;
    }

    // Default GET behavior
    const testCase = await TestCase.findById(testCaseId)
      .populate("assigned.project", "name")
      .populate("assigned.user", "name email");

    if (!testCase) {
      throw createError({
        statusCode: 404,
        statusMessage: "Test case not found",
      });
    }

    return testCase;
  } catch (error: any) {
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || "Internal server error",
    });
  }
});
