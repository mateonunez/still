# Launch channel fit

Research date: October 7, 2026. This note distinguishes platform guidance from Still-specific recommendations. No submission, account creation or scheduling was performed.

Planning baseline: Still has public MIT source and an experimental ad-hoc macOS preview; Developer ID signing/notarization and clean-Mac acceptance remain separate work. This baseline must be rechecked against the exact release before publication.

## Hacker News / Show HN

Show HN is for substantial personal work people can actually try. Early-stage projects are welcome, preferably without signup/email barriers; landing pages, signup pages and blog-only submissions do not qualify. The maker should be present to discuss the work. Submit with a title beginning `Show HN`. Routine version updates are generally insufficient for a new Show HN. Asking others to upvote or comment is prohibited. [Show HN guidelines](https://news.ycombinator.com/showhn.html)

HN's general guidelines permit occasional self-submission but reject primarily promotional usage, generated text in submissions, generated or AI-edited comments, and automated posting. They also reject coordinated requests for votes/comments/submissions. **For this channel, the maker must write the actual submission and comments and post manually.** An agent can prepare factual evidence, check links, assemble assets and explain the platform rules; it should not supply ready-to-post generated HN prose or automate submission. [HN guidelines](https://news.ycombinator.com/newsguidelines.html)

The reviewed primary pages do not specify a minimum account-age or karma requirement to submit a Show HN. The FAQ documents a visibility threshold for the main Show page; do not invent account requirements or guarantee placement. [HN FAQ](https://news.ycombinator.com/newsfaq.html)

**Still recommendation:** a technical preview can fit before notarization if readers can realistically try the exact artifact or build the public source. First verify clean-Mac installation, document the ad-hoc status without encouraging global security bypasses, and keep the visual-curtain/security-lock distinction visible. Link to the actual usable product/repository, with direct installation instructions. This readiness recommendation is ours; the reviewed HN guidance does not require notarization.

## Product Hunt

Makers can submit their own product using a personal account; a paid or third-party hunter is unnecessary. The product URL should lead directly to the product/download or repository. Current preparation guidance specifies a tagline up to 60 characters, description up to 500, up to three launch tags, a square thumbnail (240×240 recommended, under 3 MB) and at least two gallery images (1270×760 recommended). A demo video is optional. Prepare a first maker comment explaining the audience, story, capabilities and desired feedback. Drafts can be scheduled up to one month ahead. [Preparing for launch](https://www.producthunt.com/launch/preparing-for-launch)

Product Hunt recommends waiting until a product is live for the best experience and may remove pre-launch submissions at its discretion. An unreleased listing is not equivalent to a successful launch. [Unreleased products](https://help.producthunt.com/en/articles/484932-can-i-submit-an-unreleased-product)

The launch guide encourages asking people to visit and comment, but forbids directly asking for upvotes. This differs from HN, which also forbids soliciting comments. Company accounts are prohibited. No promised launch day, hunter choice or creative format guarantees ranking. [Product Hunt launch guide](https://www.producthunt.com/launch)

**Still recommendation:** prepare the draft and assets now; launch after the ordinary-user installation and first-use path is reliable. A broad audience will encounter Gatekeeper before appreciating the editor. Prefer a signed/notarized build for a broad launch, while preserving the separately approved experimental preview track. Signing is our usability recommendation, not a verified Product Hunt eligibility rule. Show actual native behavior; label exported views and concept artwork appropriately. Do not market repository installation as available before its package and native runtime work.

## GitHub discovery and Trending

GitHub documents topics, repository search, personalized Explore recommendations and Trending as discovery surfaces. `good first issue` and `help wanted` labels help contributors find actionable work. [Finding open-source projects](https://docs.github.com/en/get-started/exploring-projects-on-github/finding-ways-to-contribute-to-open-source-on-github)

Repository administrators can add relevant topics to classify their work. Topics are discoverability metadata, not a release or endorsement. [Repository topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics)

Trending is a browsing surface with language and time filters. **No direct submission flow was found on the reviewed Trending page or in the reviewed discovery documentation.** Treat a possible appearance as an outcome, not a channel we can submit to or guarantee. These sources do not establish a ranking formula; do not invent star thresholds or manipulate engagement. [GitHub Trending](https://github.com/trending)

**Still recommendation:** improve the public repository now: clear description, homepage, accurate topics such as `macos`, `swift`, `swiftui` and `widgets`; prominent preview status; release download/build instructions; concise screenshots; contribution paths and runnable plugin examples. Add `plugins`/SDK emphasis only where the implementation supports the claims. Invite genuine issue reports and contributions, not coordinated stars.

## Recommended sequence

| Stage | Channel/work | Evidence required |
| --- | --- | --- |
| Now | Repository, landing, existing personal blog/X communication | Exact release links, accurate preview limitations, source/license, useful screenshots, feedback route |
| Now | Product Hunt draft and reusable launch assets | Personal account access, current form constraints, real screenshots and concise truthful feature inventory |
| After installation checks | Maker-written, manually posted Show HN | A tryable artifact or documented source build, clear security boundary, maker availability for technical discussion |
| After end-user onboarding checks | Product Hunt launch | Reliable download/install/first-use, tested feature claims, prepared assets and human support capacity |
| Ongoing | GitHub discovery | Useful repository metadata, maintainable source, examples and actionable contributor work; no Trending submission promise |

Other hubs should be assessed individually before posting. A useful tutorial about implementing a declarative Still plugin can serve technical communities after the SDK exists; generic copied launch announcements should not replace a platform-specific contribution. No additional hub rules or guaranteed audience outcomes were verified in this research.

## Operational checklist

- Recheck the exact live release, installer behavior and known limitations before any announcement.
- Keep one canonical product/download URL; follow each platform's link rules rather than adding tracking links everywhere.
- Separate generated cover art from real application screenshots and screen recordings.
- Provide support and structured feedback without requiring a new account in Still.
- Measure installation success and useful feedback alongside visits; never report leaderboard placement, signups or conversions without evidence.
- Keep HN text and posting with the maker; prepare Product Hunt and owned-channel material separately.
