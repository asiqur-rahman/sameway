import { readFile } from "fs/promises";
import path from "path";
import { NextRequest, NextResponse } from "next/server";
import { env } from "@/lib/env";
import { NotFoundError } from "@/lib/http/errors";
import { fail } from "@/lib/http/response";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ path: string[] }> },
) {
  try {
    const { path: segments } = await params;

    if (segments.some((segment) => segment === ".." || segment.includes("\0"))) {
      throw new NotFoundError("File");
    }

    const filePath = path.join(process.cwd(), env.UPLOAD_DIR, ...segments);
    const uploadRoot = path.resolve(process.cwd(), env.UPLOAD_DIR);
    if (!path.resolve(filePath).startsWith(uploadRoot)) {
      throw new NotFoundError("File");
    }

    const buffer = await readFile(filePath);
    const ext = path.extname(filePath).slice(1);
    const mime =
      ext === "png" ? "image/png" : ext === "webp" ? "image/webp" : "image/jpeg";
    return new NextResponse(buffer, { headers: { "Content-Type": mime } });
  } catch (error) {
    return fail(error, { method: request.method, path: request.nextUrl.pathname });
  }
}
