# ADR 0008 — Declarative local plugins and advisory agent hooks

Date: 2026-10-05. Status: implemented in the development candidate; native client/hardware acceptance remains open.

## Context

A reusable community path must allow customization without handing the curtain, credentials or arbitrary execution to imported packages. Agent quota does not describe session progress, and PermissionRequest hooks do not identify an authoritative pending approval.

## Decision

Use StillPluginKit v1: strictly validated manifests, ISO 8601 full snapshots, host-issued connection UUIDs, increasing revisions, explicit Sample markers and declared quota/activity facts. Import only declarative package manifests. Templates choose approved Porcelain layouts/slots and grant no source access. Local metadata producers run separately with their existing OS permissions; Still never launches or claims to sandbox them.

Bound packages/input/cards, reject unknown/private fields and symlinks, clear missing/invalid data, and enforce freshness with monotonic deadlines. Disconnect clears cards and connection files; reconnect rotates the UUID. Publisher attribution is not trust or authentication against another process with the same OS user.

First-party activity uses documented Codex/Claude hooks and a bundled native helper. Preserve unrelated configuration, retain private backups, remove only exact owned groups, and leave Codex trust to /hooks. Hook input can transiently contain content: project anonymous state, HMAC identities with a private salt, never persist/display content or open transcripts. Emit no approval decision. Attention is advisory and expires; no pending-approval counter or in-app approval action is implemented.

## Consequences

The protocol is interoperable without another embedded runtime. Authors receive schemas, validator, starter packages and a sample producer. External producer installation, isolation, updates and permissions remain outside this slice. V1 does not include arbitrary themes/assets/settings/actions or a marketplace. Existing native quota Codable files remain internal and distinct from the public wire format.

Supported AppKit presentation options restrict Cmd-Tab/hide Dock while covered and restore exact prior values, preserving ordinary recovery. They do not document a blanket trackpad/Spaces veto. Real slow/fast swipes, authentication and accessibility remain independent release gates. Signing/notarization and release distribution are deferred.
