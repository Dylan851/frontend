# Deploy Frontend on Render

## Service Type
- `Static Site`

## Render Settings
- Root Directory: `.`
- Build Command: `bash render-build.sh`
- Publish Directory: `build/web`

## Required Environment Variables
- `API_BASE_URL` = public backend URL (for example `https://wildquest-backend.onrender.com`)

## Optional Environment Variables
- `GOOGLE_WEB_CLIENT_ID` = Google OAuth Web Client ID (required if you enable Google sign-in on web)

## Notes
- The app reads `API_BASE_URL` at build time through `--dart-define`.
- Use URL without trailing slash (`https://...`, not `https://.../`).
- Backend CORS must allow this frontend domain.
