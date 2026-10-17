# ManubisGuard Android Client

## Product direction
- Product name: ManubisGuard
- Platform first: Android; keep architecture extensible for a future Windows client.
- Visual style: premium minimalist, polished and modern.
- Visual palette: black/navy base with restrained electric-blue/cyan accents; refined cards, typography, icons, and subtle motion.
- Home screen: full dashboard with connection state, connect/disconnect, active server, connection duration, subscription usage, remaining quota, expiry, and purchase/renew actions.
- Authentication: support both account-based use and importing a personal subscription/config without creating an account.
- Store: full purchase and renewal journey, plan details, coupon support if backend supports it, checkout, wallet, transaction history, order history, and secure payment verification.
- Server management: server/location list, measured latency where available, favorites, search, personal config import, and connection profile management.
- Languages: Persian and English.
- VPN engine requirement: verify real AmneziaWG 2.x support before changing or replacing the connection engine. WireGuard support alone is not sufficient evidence.
- Backend: inspect the existing ManubisGuard/PasarGuard APIs before deciding whether any new backend is needed. Never embed privileged panel credentials in the Android app.
- Security: server-side authorization, payment verification, and subscription activation; avoid logging sensitive configs or secrets.

## Design decisions confirmed
1. Premium minimalist visual design.
2. Full dashboard home screen.
3. Both account login and guest/personal-config mode.
4. Full purchase and renewal experience.

## Working rules
- Inspect the existing repository and server environment before making code changes.
- Make real, testable changes; do not leave pseudocode as implementation.
- Do not change the VPN engine until protocol and AmneziaWG 2.x compatibility are verified.
- Do not overwrite or remove existing services, secrets, or data.
- Keep Windows extensibility in mind, but build and validate Android first.

## Next steps
1. Add the user's fork URL and inspect repository structure, license, Android build instructions, and engine integration.
2. Verify the installed Android build toolchain and available server resources.
3. Produce a screen-by-screen design specification and navigation flow.
4. Map required store/account features to the existing backend API.
5. Implement incrementally and run available tests/builds.

## Repository
Fork URL: pending user-provided URL.
