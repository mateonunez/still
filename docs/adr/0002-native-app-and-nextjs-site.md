# ADR 0002: Native app, direct distribution and Next.js website

Status: Accepted on 2026-10-04.

## Decision

Still is a real native macOS application. It is distributed directly, outside the Mac App Store. Evaluate Homebrew cask installation and terminal download alongside the main signed package; Node-based installation is optional only if it offers a justified benefit.

The landing website uses Next.js App Router, typed content and semantic design tokens. Keep native app and website responsibilities separate while sharing brand fundamentals.

## Consequences

Prepare Developer ID signing/notarization, hosted versioned artifacts, installation/update instructions and support. Adopt App Router, typed content/metadata, local fonts, semantic tokens and measured accessibility for the website. No store submission is planned.

This decision does not establish a public domain, signing authority, remote repository, tap, license, payment flow or deployment target. Implementation and delivery evidence are recorded separately.
