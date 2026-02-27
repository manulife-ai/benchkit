import { Project } from "~~/models";

export default defineEventHandler(async (event) => {
  try {
    const projectId = getRouterParam(event, "id");

    if (!projectId) {
      throw createError({
        statusCode: 400,
        statusMessage: "Project ID is required",
      });
    }

    const body = await readBody(event);
    const method = body._method || "GET";

    if (method === "DELETE") {
      const result = await Project.findByIdAndDelete(projectId);

      if (!result) {
        throw createError({
          statusCode: 404,
          statusMessage: "Project not found",
        });
      }

      return { success: true, message: "Project deleted successfully" };
    }

    if (method === "PATCH") {
      const { _method, ...updateData } = body;

      const updatedProject = await Project.findByIdAndUpdate(
        projectId,
        { ...updateData, updatedAt: new Date() },
        { new: true, runValidators: true },
      )
        .populate("owner", "name email")
        .populate("members", "name email");

      if (!updatedProject) {
        throw createError({
          statusCode: 404,
          statusMessage: "Project not found",
        });
      }

      return updatedProject;
    }

    // Default GET behavior
    const project = await Project.findById(projectId)
      .populate("owner", "name email")
      .populate("members", "name email");

    if (!project) {
      throw createError({
        statusCode: 404,
        statusMessage: "Project not found",
      });
    }

    return project;
  } catch (error: any) {
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || "Internal server error",
    });
  }
});
