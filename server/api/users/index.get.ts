import { User } from "~~/models";

export default defineEventHandler(async (event) => {
  try {
    const users = await User.find();
    return users;
  } catch (error) {
    throw createError({
      statusCode: 500,
      statusMessage: "Failed to fetch users",
      data: error,
    });
  }
});
