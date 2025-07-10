import { promises as fs } from "fs";
import path from "path";

export default defineEventHandler(async (event) => {
  try {
    const files = await readMultipartFormData(event);

    if (!files || files.length === 0) {
      throw createError({
        statusCode: 400,
        statusMessage: "No files provided",
      });
    }

    const uploadedFiles = [];
    const uploadDir = path.join(process.cwd(), "public/uploads");

    // Ensure upload directory exists
    await fs.mkdir(uploadDir, { recursive: true });

    for (const file of files) {
      if (file.filename && file.data) {
        // Generate unique filename
        const timestamp = Date.now();
        const extension = path.extname(file.filename);
        const baseName = path.basename(file.filename, extension);
        const uniqueFilename = `${baseName}_${timestamp}${extension}`;
        const filePath = path.join(uploadDir, uniqueFilename);

        // Write file to disk
        await fs.writeFile(filePath, file.data);

        // Return relative path for database storage
        const relativePath = `/uploads/${uniqueFilename}`;

        uploadedFiles.push({
          originalName: file.filename,
          filename: uniqueFilename,
          path: relativePath,
          size: file.data.length,
          type: getFileType(file.filename),
        });
      }
    }

    return {
      success: true,
      files: uploadedFiles,
    };
  } catch (error: any) {
    throw createError({
      statusCode: 500,
      statusMessage: "File upload failed",
      data: error.message,
    });
  }
});

function getFileType(filename: string): "pdf" | "img" | "txt" | "json" {
  const ext = path.extname(filename).toLowerCase();

  if (ext === ".pdf") return "pdf";
  if ([".png", ".jpg", ".jpeg", ".gif", ".webp"].includes(ext)) return "img";
  if (ext === ".txt") return "txt";
  if (ext === ".json") return "json";

  return "txt"; // default
}
