# Deploy Frontend on Render

## Service Type
- `Static Site`

## Render Settings
- Root Directory: `.`
- Build Command: `bash render-build.sh`
- Publish Directory: `build/web`

## Required Environment Variables
- `API_BASE_URL` = public backend URL (for example `https://wildquest-backend.onrender.com`)
- `SUPABASE_URL` = your Supabase project URL (`https://<project-ref>.supabase.co`)
- `SUPABASE_ANON_KEY` = Supabase anon/public key

## Optional Environment Variables
- `GOOGLE_WEB_CLIENT_ID` = optional for legacy `google_sign_in`; not required with Supabase OAuth flow

## Notes
- The app reads `API_BASE_URL`, `SUPABASE_URL` and `SUPABASE_ANON_KEY` at build time through `--dart-define`.
- Use URL without trailing slash (`https://...`, not `https://.../`).
- Backend CORS must allow this frontend domain.
