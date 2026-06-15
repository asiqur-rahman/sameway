import { apiRoute, parseQuery } from "@/lib/http/api-route";
import { ok } from "@/lib/http/response";
import { requireAuth } from "@/lib/auth/session";
import { env } from "@/lib/env";
import { z } from "zod";

const querySchema = z.object({
  q: z.string().min(1),
});

export const GET = apiRoute(async (request) => {
  await requireAuth(request);
  const { q } = parseQuery(request, querySchema);

  if (!env.GOOGLE_MAPS_API_KEY) {
    return ok({
      items: [],
      message: "Configure GOOGLE_MAPS_API_KEY for live autocomplete",
      query: q,
    });
  }

  const url = new URL("https://maps.googleapis.com/maps/api/place/autocomplete/json");
  url.searchParams.set("input", q);
  url.searchParams.set("key", env.GOOGLE_MAPS_API_KEY);
  url.searchParams.set("components", "country:bd");

  const res = await fetch(url);
  const data = await res.json();
  return ok(data);
});
