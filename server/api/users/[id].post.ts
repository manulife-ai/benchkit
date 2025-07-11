import { User } from "~/models";

export default defineEventHandler(async (event) => {
  try {
    const userId = getRouterParam(event, "id");

    if (!userId) {
      throw createError({
        statusCode: 400,
        statusMessage: "User ID is required",
      });
    }

    const body = await readBody(event);
    const method = body._method || "GET";

    if (method === "DELETE") {
      const result = await User.findByIdAndDelete(userId);

      if (!result) {
        throw createError({
          statusCode: 404,
          statusMessage: "User not found",
        });
      }

      return { success: true, message: "User deleted successfully" };
    }

    if (method === "PATCH") {
      const { _method, ...updateData } = body;

      const updatedUser = await User.findByIdAndUpdate(
        userId,
        { ...updateData, updatedAt: new Date() },
        { new: true, runValidators: true },
      );

      if (!updatedUser) {
        throw createError({
          statusCode: 404,
          statusMessage: "User not found",
        });
      }

      return updatedUser;
    }

    // Default GET behavior
    const user = await User.findById(userId);

    if (!user) {
      throw createError({
        statusCode: 404,
        statusMessage: "User not found",
      });
    }

    return user;
  } catch (error: any) {
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || "Internal server error",
    });
  }
});
