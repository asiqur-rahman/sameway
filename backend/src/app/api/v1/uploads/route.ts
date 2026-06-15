import { apiRoute } from "@/lib/http/api-route";
import { created } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { saveUpload } from "@/modules/uploads/uploads.service";

export const POST = apiRoute(async (request) => {
  await requireAuth(request);
  const formData = await request.formData();
  const file = formData.get("file");
  const type = formData.get("type");

  if (!(file instanceof File)) {
    const { ValidationError } = await import("@/lib/http/errors");
    throw new ValidationError({ formErrors: ["file is required"], fieldErrors: {} });
  }

  const subdir = type === "verification" ? "verification" : "profiles";
  const url = await saveUpload(file, subdir);
  return created({ url });
});
