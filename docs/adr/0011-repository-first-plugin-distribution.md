# ADR 0011 — Repository-first plugin distribution

Date: 2026-10-07. Status: proposed implementation contract; repository-first UX/DX is requested product scope.

## Context

The native collection and local declarative importer do not provide repository discovery, remote installation, provenance receipts or upgrades. A catalog-only product would prevent authors from distributing compatible plugins independently. The requested experience supports Settings and a published npx entry point, inspired by Skills, Codex and Claude marketplaces.

## Direction

Treat repository source, compatible package, installed package, configured source and visible widget as distinct domain concepts. Use one resolver/validator/import transaction and receipt semantics across CLI and Settings. The public catalog is optional discovery/curation; it does not gate direct repository installation. Aim for HTTPS Git hosts and local folders, with first delivery public HTTPS/local and separate private-host authentication.

Propose bounded `still.plugins.json` discovery metadata and explicit package paths, pin inspection/import to one commit, and retain the current canonical Swift validator for declarative packages. Installation remains disconnected and executes no repository code. Track provenance and explicitly reviewed updates independently of package connection state. Keep existing built-in installer commands compatible.

Do not claim that Skills/Codex/Claude manifests can execute or render inside Still. Additional widget/configuration capabilities require a versioned host-rendered SDK and migration contract. Do not silently introduce arbitrary runners, accounts, payments or automatic updates.

## Open implementation decisions

Exact repository-index schema and discovery bounds; shared resolver delivery/IPC boundary; typed compatibility/error schema; versioned upgrade transaction; npm publication identity/version; richer SDK configuration and widget contract. The product plan specifies acceptance before these become shipping guarantees.

## Consequences

People can review source/compatibility before installation. Authors can use their own repositories; agents receive structured inspect/install results. One implementation must serve both entry points, avoiding a JavaScript approximation of Swift validation. The current v1 imported-card limits and Porcelain-only contract remain explicit until migrated. Runtime installation, CLI publication and launch are separate delivery gates.

[Product plan](../development/repository-marketplace.md) · [Primary-source research](../research/repository-plugin-marketplaces.md).
