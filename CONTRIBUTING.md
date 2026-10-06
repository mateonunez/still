# Contributing to Still

Still is in development and the repository currently requires access. The public [SDK](https://meet-still.app/developers) and [plugin catalog](https://meet-still.app/plugins) are available without repository access. There is no community submission or package-publishing service yet.

## Start with a small, complete change

Read [the architecture](docs/architecture.md), [design contract](DESIGN.md) and [developer practices](docs/development/practices.md). Keep a change focused on one user behavior. Explain the trigger, resulting behavior and evidence; include known limits rather than inferring native acceptance from a build.

Native UI lives in `apps/macos`; reusable session, widget and plugin contracts live in the Swift packages. The Next.js website lives in `apps/website`. Use Node 24/pnpm and Biome for website work. Follow existing Node and Swift test runners rather than adding duplicate tooling.

## Validate the relevant surface

- Website: formatting, types, build, descriptive metadata, keyboard/focus behavior and responsive layout.
- Native behavior: relevant package tests plus real app/device observations where gestures, permissions, authentication or sleep are involved.
- Plugin contracts: bounded input, expiry, reconnect, malformed input and revocation. Never add credentials or private activity to fixtures.

Keep build artifacts, local configuration, signing material and private logs out of Git. Do not change a running interactive app or unrelated configuration while verifying a change.

## Reports and licensing

For bugs, include the app/source version, macOS and architecture, reproduction, expected behavior and observed result. Redact credentials, conversations, calendar titles and private project details. The [support page](https://meet-still.app/support) describes the product's current limits.

Original contributions use the project's [MIT license](LICENSE). Preserve existing third-party attribution and font licenses. Source access, native release availability and community publishing are independent of the license.
