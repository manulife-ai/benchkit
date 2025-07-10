import { Project } from "~/models";

export default defineEventHandler(async (event) => {
  try {
    const projects = await Project.find()
      .populate("owner", "name email")
      .populate("members", "name email");
    return projects;
  } catch (error) {
    throw createError({
      statusCode: 500,
      statusMessage: "Failed to fetch projects",
      data: error,
    });
  }
});
