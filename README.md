# Paper Wiki Stack

Open-source integration guide for a Zotero + MinerU + Obsidian paper-reading workflow.

This repository is the distribution and documentation layer. It does not vendor private vault data, parsed PDFs, Zotero databases, local recommendation outputs, or secrets. The stack is composed of a small set of focused projects:

| Component | Role | Required |
|---|---|---:|
| `mineru-zotero-mcp` | MCP server for Zotero PDF parsing, MinerU anchors, figures, arXiv ingest helpers | Yes |
| `claude-obsidian` fork with `paper-wiki` | Obsidian vault conventions, paper source-page skill, indexes, lint scripts | Yes |
| `zotero-mcp` | Zotero metadata, collections, notes, annotations, PDF access | Yes |
| `zotero-arxiv-daily` fork | Optional daily arXiv recommendations exported as JSON | Optional |
| Obsidian | Human-facing markdown vault | Recommended |
| Codex or another MCP client | Agent runtime that calls MCP tools and follows the paper-wiki workflow | Recommended |

## What This Stack Does

1. Reads Zotero metadata and local PDFs.
2. Parses PDFs through MinerU into markdown, anchors, tables, and figure assets.
3. Writes evidence-grounded paper source pages into an Obsidian wiki.
4. Preserves Zotero collection structure as human-readable paths:

```text
wiki/sources/zotero/<collection_path>/<citekey>.md
```

5. Optionally reads daily recommendation JSON from `zotero-arxiv-daily`, ingests selected arXiv papers into Zotero, syncs local PDFs, parses them with MinerU, and writes source pages.

## Repository Strategy

This stack is intentionally not published as one giant source tree.

- `mineru-zotero-mcp` should be developed and versioned as its own package.
- `claude-obsidian` and `zotero-arxiv-daily` are heavily modified forks and should retain upstream attribution.
- `zotero-mcp` should remain an external dependency unless you need to maintain a public patch branch.
- This repository documents how to assemble the stack safely.

For details, see [docs/repository-strategy.md](docs/repository-strategy.md).

Before publishing, use:

- [docs/open-source-checklist.md](docs/open-source-checklist.md)
- [docs/roadmap.md](docs/roadmap.md)

## Required Accounts and Local Software

You need:

- Zotero Desktop, running locally.
- Better BibTeX for Zotero, with its local JSON-RPC endpoint reachable at `127.0.0.1:23119`.
- Zotero Web API key with write access.
- MinerU API token from the MinerU API Management page.
- Python 3.10+.
- `zotero-mcp-server[pdf]`.
- `mineru-zotero-mcp`.
- An Obsidian vault using the `claude-obsidian` paper-wiki layout.

Optional:

- WebDAV credentials for bypassing Zotero cloud file quota.
- `zotero-arxiv-daily` for local daily recommendation snapshots.
- Ollama + `nomic-embed-text` for better local retrieval reranking.

WebDAV is not required. If you rely on Zotero's official cloud storage and it has enough quota, you can omit `WEBDAV_URL`, `WEBDAV_USER`, and `WEBDAV_PASS`.

## Required Environment Variables

Minimum:

```bash
MINERU_API_TOKEN=...
VAULT_ROOT=/absolute/path/to/claude-obsidian
ZOTERO_LOCAL=true
ZOTERO_LIBRARY_ID=...
ZOTERO_USER_ID=...
ZOTERO_API_KEY=...
ZOTERO_LIBRARY_TYPE=user
```

Optional:

```bash
RECOMMENDATIONS_URL=/absolute/path/to/zotero-arxiv-daily/data/recommendations
WEBDAV_URL=https://example.com/dav/zotero/
WEBDAV_USER=...
WEBDAV_PASS=...
```

See [examples/env.example](examples/env.example).

## Quick Install

Install Zotero dependencies:

```bash
pip install "zotero-mcp-server[pdf]"
```

Install the custom MCP server:

```bash
git clone https://github.com/<your-org>/mineru-zotero-mcp.git
cd mineru-zotero-mcp
pip install -e .
```

Configure your MCP client using one of:

- [examples/codex.config.example.toml](examples/codex.config.example.toml)
- [examples/zcode.mcp.example.json](examples/zcode.mcp.example.json)

Install Codex skills from the `claude-obsidian` fork:

```bash
scripts/install-codex-skills.sh /absolute/path/to/claude-obsidian
```

Run a smoke test:

```bash
scripts/doctor.sh
```

## Expected Agent Workflow

For a new arXiv paper:

1. Add it to Zotero:
   - preferred: `zotero_add_by_url(url="https://arxiv.org/abs/<id>")`
   - if using `mineru-zotero-mcp` helper: `arxiv_ingest_paper(...)`
2. Ensure the PDF exists locally:
   - use Zotero sync if available
   - or `zotero_local_sync(attachment_key=..., pdf_path=...)`
3. Parse through MinerU:
   - `mineru_parse_pdf(item_key=<parent_item_key>)`
4. Collect evidence:
   - `mineru_list_anchors`
   - `mineru_resolve_anchor`
   - `mineru_list_visual_candidates`
   - `mineru_read_markdown`
5. Write the source page under:

```text
wiki/sources/zotero/<collection_path>/<citekey>.md
```

6. Rebuild paper indexes:

```bash
python skills/paper-wiki/scripts/build_indexes.py --vault "$VAULT_ROOT"
```

7. Run lint:

```bash
python skills/paper-wiki/scripts/lint_vault.py --vault "$VAULT_ROOT"
```

## Known Limitations

- `mineru-zotero-mcp` currently assumes local PDF availability for parsing. If Zotero created an attachment but did not download it locally, run local sync first.
- `arxiv_ingest_paper` may fail on its built-in Zotero item creation path for some papers. Workaround:

```text
arxiv_fetch_pdf -> zotero_add_by_url -> zotero_local_sync -> mineru_parse_pdf
```

- Codex and ZCode load MCP tools and skills at session start. Restart the client after changing config.
- Obsidian must be fully quit and reopened after changing vault path or hidden-file filters.
- macOS LaunchAgents may not have access to `~/Downloads` because of TCC. Put projects under `~/projects` or another non-protected path.
- `wiki-lock.sh` depends on `flock`; vanilla macOS may not provide it. Use filesystem writes carefully or install a compatible lock utility.

See [docs/troubleshooting.md](docs/troubleshooting.md).

## Open-Source Safety

This repository is designed to be public. Your working vault, Zotero files, parsed paper assets, recommendation outputs, and real MCP configs should stay local or live in separately sanitized repositories.

Run before publishing:

```bash
scripts/check-secrets.sh .
```

## What Not To Commit

Do not commit:

- API tokens or keys.
- WebDAV credentials.
- `.raw/` MinerU parse output.
- `attachments/` extracted figures from private papers.
- Zotero SQLite databases.
- personal recommendation JSON.
- local MCP configs with real env values.
- Obsidian workspace state.

This repository includes a defensive [.gitignore](.gitignore) and `scripts/check-secrets.sh`, but they are not a substitute for review before publishing.

## License and Attribution

This repository is MIT licensed. Each external component keeps its own license.

- `zotero-mcp` is maintained upstream by its original authors.
- `claude-obsidian` and `zotero-arxiv-daily` are forks and must retain upstream license and attribution.
- `mineru-zotero-mcp` should include its own license before publication.

See [docs/repository-strategy.md](docs/repository-strategy.md).
