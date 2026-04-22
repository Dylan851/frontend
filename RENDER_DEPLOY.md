# Deploy Frontend on Render

## Service Type
- `Static Site`

## Render Settings
- Root Directory: `.`
- Build Command: `bash render-build.sh`
- Publish Directory: `build/web`

## Required Environment Variables
- `API_BASE_URL` = public backend URL (for example `https://wildquest-backend.onrender.com`)

## Notes
- The app reads `API_BASE_URL` at build time through `--dart-define`.
- Use URL without trailing slash (`https://...`, not `https://.../`).
- Backend CORS must allow this frontend domain.
