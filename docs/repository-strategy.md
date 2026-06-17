# Repository Strategy

## Recommended Public Layout

Use this repository as the public integration entry point:

```text
paper-wiki-stack/
├── README.md
├── docs/
├── examples/
└── scripts/
```

Keep the implementation repositories separate:

```text
mineru-zotero-mcp/      # first-party MCP server
claude-obsidian/        # heavily modified fork, provides paper-wiki vault/skill
zotero-arxiv-daily/     # heavily modified fork, optional recommendations provider
zotero-mcp/             # upstream dependency
```

## Why Not One Giant Repository

Do not flatten all source into one ordinary repository.

Reasons:

- `claude-obsidian` and `zotero-arxiv-daily` are forks with upstream history and license obligations.
- `zotero-mcp` is an upstream dependency, not owned by this project.
- `mineru-zotero-mcp` is a reusable MCP server and should be installable without the full paper-wiki stack.
- The Obsidian vault contains private user data unless explicitly sanitized.
- Public examples and private working vaults have different lifecycle rules.

## What This Repository Owns

This repository owns:

- installation documentation
- MCP config examples
- environment variable templates
- troubleshooting notes
- helper scripts for local setup
- high-level architecture
- open-source release checklist

It does not own:

- private vault content
- Zotero database files
- parsed paper artifacts
- upstream fork history
- real credentials

## Component Ownership

### mineru-zotero-mcp

Primary first-party code. Publish as a normal package repository.

Before release:

- add a license
- keep `.env.example`
- document `zotero-mcp-server[pdf]` dependency
- document local PDF requirement
- document the `arxiv_ingest_paper` fallback path
- add CI for unit tests

### claude-obsidian fork

Treat as a forked vault/skill distribution.

Before release:

- keep upstream license and attribution
- do not publish private `.raw/`, `attachments/`, or personal wiki notes
- move representative paper pages to `examples/` if useful
- keep `paper-wiki` skill, scripts, templates, and CSS documented

### zotero-arxiv-daily fork

Treat as an optional recommendation provider.

Before release:

- keep upstream attribution
- document local embedding cache
- document recommendation JSON export
- document launchd setup separately from the core stack
- ignore generated `data/recommendations/*.json` unless intentionally publishing sample fixtures

### zotero-mcp

Do not vendor by default.

Document installation:

```bash
pip install "zotero-mcp-server[pdf]"
```

If a patch is required, maintain a public fork or upstream PR. Do not silently depend on unpublished local edits.

## Release Options

### Option A: Integration repo + separate repos

Recommended.

- easiest to reason about licenses
- keeps private data out
- lets developers install only what they need
- avoids submodule friction

### Option B: Git submodules

Acceptable if you want reproducible checkouts.

Downside: contributors often find submodules brittle.

### Option C: Monorepo import

Not recommended unless you intentionally relicense, sanitize history, and accept long-term ownership of all components.

## Public README Disclosure

State clearly:

- this is an integration stack
- `mineru-zotero-mcp` is first-party
- `claude-obsidian` and `zotero-arxiv-daily` are forks with substantial changes
- `zotero-mcp` is an external dependency
- WebDAV is optional
- MinerU token and Zotero write API key are required for the full workflow
