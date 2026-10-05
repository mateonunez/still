# Launch plugin proposals

Status: proposed shortlist, not an approved implementation plan.

Superseded by the implemented [mateonunez native collection](../guides/native-plugins.md): Codex/Claude became one Agents plugin, with Spotify added as the tenth. The original proposals below remain design history.

Still should offer ten optional plugins while keeping each composition limited to four cards. Nothing is connected automatically. Native host rendering, Porcelain light/dark, explicit source freshness and privacy controls apply throughout.

| Plugin | Essential view | Source / scope |
| --- | --- | --- |
| Codex | Quota, reset window, expiring advisory activity/attention | Existing native client integration; live hook delivery acceptance pending |
| Claude | Quota, reset window, expiring advisory activity/attention | Existing local status-line/hook bridge; live acceptance pending |
| Build Watch | Selected workflow running, passed or failed | GitHub Actions read access; no logs or workflow execution |
| Deploy Watch | Selected project deploying, ready or failed | Vercel read API; no deploy action or environment-variable access |
| Task Watch | Explicitly registered local task running, finished or failed | Producer SDK; no automatic terminal output/process-content capture |
| Mac Pulse | CPU activity, memory pressure, battery/power | Native host metrics; no application/window titles |
| Next Up | Next meeting in a chosen calendar, countdown | EventKit permission; titles hidden by default |
| World Clock | Two or three chosen cities and local times | Local timezone computation; no account or network required |
| Quiet Timer | Remaining break/focus time or time away | Host-local monotonic timer; optional completion signal, no automatic unlock |
| Weather | Current temperature and imminent precipitation | WeatherKit requires Apple Developer access/configuration and attribution; source decision pending |

Suggested first vertical slice: World Clock, Mac Pulse and Task Watch alongside the existing Codex/Claude integrations. Build Watch and Deploy Watch follow; calendar and weather need additional source setup. This is sequencing advice, not a commitment to shipping unverified integrations.

The current public v1 protocol accepts quota and agentActivity only. Generic tasks, resource metrics, agenda, clocks and weather need deliberate typed contract extensions, validators, capability consent and native renderers. Do not encode non-agent information as fake quota or agentActivity. Time values are rendered by the host; sources must not emit arbitrary UI/code. Calendar/weather must not be connected during privacy coverage; configure consent in the Hub first.

References: [GitHub workflow API](https://docs.github.com/en/rest/actions/workflow-runs), [Vercel API](https://vercel.com/docs/rest-api), [EventKit](https://developer.apple.com/documentation/eventkit), [WeatherKit](https://developer.apple.com/weatherkit/). CodexBar remains a source of provider conventions, not an embedded runtime or a guarantee of upstream data availability.
