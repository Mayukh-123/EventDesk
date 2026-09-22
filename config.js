// ---- Supabase connection ----
// Replace these two values with your own project's URL and anon public key.
// Find them in your Supabase dashboard under Project Settings > API.
const SUPABASE_URL = "https://rikpbjzihoxdlskoypvi.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_YpB560mvNt6tuKOGDo9ANQ_a58t3sjr";

const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ---- Shared helpers ----

function formatDate(dateStr) {
  const d = new Date(dateStr + "T00:00:00");
  const options = { day: "numeric", month: "short", year: "numeric" };
  return d.toLocaleDateString("en-IN", options);
}
