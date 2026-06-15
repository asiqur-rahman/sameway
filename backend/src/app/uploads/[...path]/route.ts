import { readFile } from "fs/promises";
import path from "path";
import { NextRequest, NextResponse } from "next/server";
import { env } from "@/lib/env";

export async function GET(
  _request: NextRequest,
  { params }: { params: Promise<{ path: string[] }> },
) {
  const { path: segments } = await params;
  const filePath = path.join(process.cwd(), env.UPLOAD_DIR, ...segments);

  try {
    const buffer = await readFile(filePath);
    const ext = path.extname(filePath).slice(1);
    const mime =
      ext === "png" ? "image/png" : ext === "webp" ? "image/webp" : "image/jpeg";
    return new NextResponse(buffer, { headers: { "Content-Type": mime } });
  } catch {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }
}
