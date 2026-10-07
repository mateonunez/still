# Website analytics

The personal Vercel project `mmateonunez/still` has Web Analytics enabled. The root Next.js layout mounts `WebsiteAnalytics` only in production. Development and preview deployments omit it.

`beforeSend` removes query strings and fragments from page-view URLs. No custom events, account identification, session replay or native-app telemetry is configured. Provider behavior is described in the public privacy page. See [Vercel's documentation](https://vercel.com/docs/analytics/privacy-policy).

After deployment, visit the production site in a browser and navigate to another page. Check the personal project Analytics dashboard and allow for processing delay. Content blockers and network restrictions may prevent collection; do not disable user protections to force it. A script loading successfully does not prove an event was accepted or appeared in reporting.

Interpret aggregate visits and referrals as website engagement. A visit to `/download` is not evidence of installation. Record installation feedback separately through GitHub issues.
