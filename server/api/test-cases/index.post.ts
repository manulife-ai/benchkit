import { TestCase } from "~/models";

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event);

    const testCase = new TestCase({
      inputs: body.inputs,
      original: body.original,
      assigned: body.assigned || [],
      validated: [],
    });

    await testCase.save();

    // Populate related data before returning
    await testCase.populate("assigned.user", "name email");
    await testCase.populate("assigned.project", "name");

    return testCase;
  } catch (error: any) {
    throw createError({
      statusCode: 500,
      statusMessage: "Failed to create test case",
      data: error,
    });
  }
});
