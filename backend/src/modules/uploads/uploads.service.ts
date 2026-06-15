import { mkdir, writeFile } from "fs/promises";
import path from "path";
import { randomUUID } from "crypto";
import { env } from "@/lib/env";
import { ForbiddenError } from "@/lib/http/errors";

const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp"];

export async function saveUpload(
  file: File,
  subdir: "profiles" | "verification",
): Promise<string> {
  if (!ALLOWED_TYPES.includes(file.type)) {
    throw new ForbiddenError("Only JPEG, PNG, and WebP images are allowed");
  }

  const maxBytes = env.MAX_UPLOAD_SIZE_MB * 1024 * 1024;
  if (file.size > maxBytes) {
    throw new ForbiddenError(`File exceeds ${env.MAX_UPLOAD_SIZE_MB}MB limit`);
  }

  const ext = file.type.split("/")[1] === "jpeg" ? "jpg" : file.type.split("/")[1];
  const filename = `${randomUUID()}.${ext}`;
  const dir = path.join(process.cwd(), env.UPLOAD_DIR, subdir);
  await mkdir(dir, { recursive: true });

  const buffer = Buffer.from(await file.arrayBuffer());
  await writeFile(path.join(dir, filename), buffer);

  return `/uploads/${subdir}/${filename}`;
}
