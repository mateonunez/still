# Repository marketplace communication

Status: draft copy. Repository installation and npm distribution are planned, not currently available. Do not use the launch variants until their acceptance gates pass.

## Positioning

**Your screen. Your sources. Your plugins.**

Still gives useful details a quiet place on your Mac. Choose the widgets you want, configure their sources, and arrange your screen in Porcelain or Glass.

## Available today

Ten configurable native plugins and a local declarative SDK. The native collection ships with Still. Community authors can validate and import supported local metadata packages and Porcelain templates. Still does not run imported package code; installing and connecting a source are separate.

## Development update — draft

We're building a repository-first plugin experience for Still.

The idea is simple: find a compatible package in a repository, review what it needs, and add it from Settings or the CLI. The public catalog should help you discover plugins, without becoming the only place you can install them from.

Repository discovery, pinned installs, configuration and updates are the next steps. Today, Still supports its native collection and local declarative imports. No remote installer or npm package is published yet.

https://meet-still.app/developers

## Launch copy — gated draft

**A little more of your world. From the repositories you choose.**

Discover compatible Still packages, review their source and add them from Settings or the CLI. Configure each source separately, then give its widget a place on your screen.

Use only when the CLI is published, Settings parity is tested and the catalog accurately marks built-in versus community packages. Insert the exact tested command/version and a real installation recording; do not add download counts, community size, endorsement badges or automatic-update claims without evidence.

## Screenshots and recording brief

1. Settings → Plugins → Add repository, showing a public example repository and resolved commit.
2. Compatibility result with multiple selectable packages and one clearly explained unsupported package.
3. Review showing declared data, source and disconnected initial state.
4. Installed package configuration, then visible widget in the editor.
5. Update comparison and disconnect/remove controls.

Use an owned public example and scratch configuration. No private paths, tokens, agent conversations or personal working desktop. Static exports must be labelled; an install demonstration requires actual installation, not a designed mock.

## Distribution sequence

Repository docs and schema first; functioning native/CLI flow next; npm publication and website install guidance together after acceptance; personal blog and X announcement with real evidence after that. Hub submissions should match each community's rules and describe the same verified availability. This document does not publish or schedule posts.
