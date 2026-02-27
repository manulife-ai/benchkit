import { Project } from "~~/models";

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event);

    const project = new Project({
      name: body.name,
      description: body.description,
      owner: body.owner,
      members: body.members || [],
    });

    await project.save();

    // Populate the owner and members before returning
    await project.populate("owner", "name email");
    await project.populate("members", "name email");

    return project;
  } catch (error: any) {
    throw createError({
      statusCode: 500,
      statusMessage: "Failed to create project",
      data: error,
    });
  }
});
