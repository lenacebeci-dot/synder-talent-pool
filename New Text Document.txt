// Fill these in from Supabase → Project Settings → API.
// The anon key is designed to be public; your security rules live in schema.sql.
window.TALENT_POOL_CONFIG = {
  SUPABASE_URL: "https://wufzaxfbfunygpxowjce.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind1ZnpheGZiZnVueWdweG93amNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI3NDc1MDUsImV4cCI6MjEwODMyMzUwNX0.tV7K5VgXJRqQL0BhKuiAivNXVtouJ4AMP6EpgeJwGQQ",

  COMPANY_NAME: "Synder",
  COMPANY_TAGLINE: "Machine accuracy. Human approach.",
  // White logo for the dark header. Best practice: download it into this repo
  // (e.g. logo-synder-white.svg) and point this at the local file.
  LOGO_URL: "https://cdn.prod.website-files.com/622efc5ff4a0f4c4a8b262d5/665053f1c89712c5d8aabe90_logo-synder-white.svg",
  PRIVACY_POLICY_URL: "https://synder.com/privacy/",

  // Shown in the consent text. Keep in sync with '24 months' in schema.sql.
  RETENTION_MONTHS: 24,

  // ---- Answer options for the form (edit freely) ----
  ROLE_AREAS: [
    "Engineering",
    "Product",
    "Design",
    "Data & Analytics",
    "Sales",
    "Marketing",
    "Customer Success & Support",
    "Accounting & Finance",
    "Partnerships",
    "People & HR",
    "Operations",
    "Other"
  ],
  SENIORITY: ["Less than 1 year", "1–3 years", "3–5 years", "5+ years"],
  ENGLISH_LEVELS: ["Native or bilingual", "Fluent (C1–C2)", "Professional (B2)", "Conversational (B1 or below)"],
  EMPLOYMENT_TYPES: ["Full-time", "Part-time", "Contract / freelance", "Internship"],
  WORK_SETUP: ["Remote", "Hybrid", "On-site"],
  AVAILABILITY: ["Immediately", "Within 1 month", "1–3 months", "3+ months", "Just exploring"],
  REFERRAL_SOURCES: ["LinkedIn", "Synder website", "A Synder employee", "Friend or colleague", "Job board", "Event or webinar", "Other"]
};
