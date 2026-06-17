# Troubleshooting

## MinerU Token Returns 401

Use a token from the MinerU API Management page. A normal OpenXLab login token can expire and is not the correct long-lived API credential.

Required env:

```bash
MINERU_API_TOKEN=...
```

## MinerU Result Download Fails with TLS or CDN Error

`mineru-zotero-mcp` should fall back to `curl` for result ZIP download. Ensure `curl` is installed and available on `PATH`.

## Zotero Annotation Writes Fail

Use hybrid mode:

```bash
ZOTERO_LOCAL=true
ZOTERO_LIBRARY_ID=...
ZOTERO_USER_ID=...
ZOTERO_API_KEY=...
ZOTERO_LIBRARY_TYPE=user
```

The Zotero API key must have write access.

## Better BibTeX Citekey Resolution Fails

Check:

- Zotero Desktop is running.
- Better BibTeX is installed.
- `127.0.0.1:23119` is reachable.

## Python Cannot Import `zotero_mcp`

Install `zotero-mcp-server[pdf]` in the same Python environment as `mineru-zotero-mcp`:

```bash
pip install "zotero-mcp-server[pdf]"
pip install -e /path/to/mineru-zotero-mcp
```

## MinerU Parse Cannot Find Local PDF

The Zotero item may have metadata and an attachment entry, but the PDF may not exist locally.

Fix:

```text
zotero_get_item_children(item_key=<parent>)
zotero_local_sync(attachment_key=<attachment>, pdf_path=<downloaded_pdf>)
mineru_parse_pdf(item_key=<parent>)
```

## `arxiv_ingest_paper` Fails to Create Zotero Item

Known issue in the helper path for some papers.

Use the stable fallback:

```text
arxiv_fetch_pdf(arxiv_ids=[...])
zotero_add_by_url(url="https://arxiv.org/abs/<id>", collections=[...])
zotero_get_item_children(item_key=<new_parent_key>)
zotero_local_sync(attachment_key=<attachment>, pdf_path=<downloaded_pdf>)
mineru_parse_pdf(item_key=<new_parent_key>)
```

## Zotero Cloud vs WebDAV Confusion

Zotero has two separate sync concepts:

- Zotero official sync: metadata, collections, item records.
- WebDAV: optional file storage backend.

The recommendation system and Zotero Web API read official Zotero metadata. WebDAV does not fix missing metadata on Zotero's official server.

WebDAV is optional. Use it only if Zotero cloud file quota is a problem.

## Obsidian Does Not Show `.raw`

This is expected. Parsed artifacts live under `.raw/` and are not meant to be browsed as normal notes.

Human-facing pages live under:

```text
wiki/sources/zotero/
```

## Obsidian Still Opens the Old Vault Path

Update the vault path in Obsidian, or edit Obsidian's local app config. Fully quit and reopen Obsidian.

On macOS, the app config is usually:

```text
~/Library/Application Support/obsidian/obsidian.json
```

Do not commit this file.

## Codex or ZCode Does Not Show New MCP Tools

MCP tools are loaded at session start.

After changing MCP config:

- restart the client, or
- start a new session/thread.

## macOS LaunchAgent Cannot Read Downloads

macOS TCC restricts background access to `~/Downloads`.

Put projects under:

```text
~/projects
```

Rebuild virtual environments after moving a Python project, because scripts and `pyvenv.cfg` can contain absolute paths.

## `wiki-lock.sh` Fails: `flock: command not found`

Some macOS environments do not provide `flock`.

Options:

- install a compatible lock utility
- use filesystem writes carefully when only one agent is active
- replace the lock implementation with a portable Python lock

## Better Notes Does Not Preserve Obsidian Callout Styling

Expected. Better Notes may sync blockquote content while losing Obsidian-specific styling. Treat Better Notes sync as backup/search interoperability, not the primary rendering target.

## Daily Recommendations Do Not Appear

Check:

- `RECOMMENDATIONS_URL` points to a directory containing `latest.json`
- `zotero-arxiv-daily` has run successfully
- Hydra did not change cwd into `outputs/...`
- historical recommendation filtering is not suppressing everything

For local-first setup, prefer an absolute path:

```bash
RECOMMENDATIONS_URL=/absolute/path/to/zotero-arxiv-daily/data/recommendations
```
