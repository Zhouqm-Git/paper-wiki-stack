# Open-Source Checklist

Use this before publishing any repository in the stack.

## Required Decision

- Choose the public organization or account.
- Choose license per repository.
- Decide whether `claude-obsidian` and `zotero-arxiv-daily` remain forks or become clearly attributed derived repositories.
- Decide whether to publish a minimal public vault template or the full sanitized `claude-obsidian` fork.

## Secret and Data Audit

Run:

```bash
scripts/check-secrets.sh .
```

Also manually check:

- `.env`, MCP configs, shell profiles, LaunchAgent plists.
- Zotero API keys.
- MinerU tokens.
- WebDAV usernames/passwords if used.
- personal file paths in examples.
- PDF files and extracted figures.
- `.raw/` parsed MinerU output.
- Zotero `storage/` and SQLite files.
- personal recommendation JSON and embedding caches.
- Obsidian workspace/app state.

Do not delete private local files just to publish. Keep them ignored and publish only sanitized repositories.

## paper-wiki-stack

- Keep only docs, examples, and helper scripts.
- Keep example configs with placeholders.
- Run `scripts/check-secrets.sh .`.
- Keep `LICENSE` and README license notes in sync.

## mineru-zotero-mcp

- Add license.
- Add `.env.example`.
- Document required env and optional WebDAV.
- Document dependency on `zotero-mcp-server[pdf]`.
- Document fallback workflow:

```text
arxiv_fetch_pdf -> zotero_add_by_url -> zotero_local_sync -> mineru_parse_pdf
```

- Add CI for unit tests.
- Keep test fixtures synthetic or explicitly public.

## claude-obsidian Fork

- Retain upstream license and attribution.
- Keep `skills/paper-wiki` and required scripts.
- Remove or ignore private vault pages before publishing.
- Do not publish `.raw/`, PDFs, extracted private images, Obsidian workspace state, or personal notes.
- Prefer a `template-vault/` or documented setup path if the full local vault contains private research content.

## zotero-arxiv-daily Fork

- Retain upstream attribution.
- Ignore generated recommendation JSON unless publishing a tiny synthetic fixture.
- Document local recommendation export path.
- Keep API keys, model cache paths, and personal preferences out of the repo.

## zotero-mcp

- Do not vendor it in this repository.
- Link upstream install instructions.
- If local patches are required, open a PR upstream or publish a clearly named fork branch.

## Final Publish Check

```bash
git status --short
git diff --cached
scripts/check-secrets.sh .
```

Review the GitHub repository page after the first push and confirm no real paths, keys, PDFs, or private notes are visible.
