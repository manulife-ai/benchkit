import { User } from "~~/models";

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event);

    const userData: any = {
      email: body.email,
      name: body.name,
      role: body.role || "user",
    };

    // Only add azureId if it's provided and not empty
    if (body.azureId && body.azureId.trim() !== "") {
      userData.azureId = body.azureId;
    }

    const user = new User(userData);

    await user.save();

    // Return user without sensitive data
    const { azureId, ...userResponse } = user.toObject();
    return userResponse;
  } catch (error: any) {
    if (error.code === 11000) {
      throw createError({
        statusCode: 400,
        statusMessage: "User already exists",
      });
    }
    throw createError({
      statusCode: 500,
      statusMessage: "Failed to create user",
      data: error,
    });
  }
});
