# Installation Guide

This guide assumes macOS or Linux, Python 3.10+, Zotero Desktop, and an MCP-capable agent client.

## 1. Install Zotero Requirements

Install Zotero Desktop and the Better BibTeX plugin.

Confirm Better BibTeX local JSON-RPC is reachable:

```bash
curl http://127.0.0.1:23119/better-bibtex/json-rpc
```

The exact response can vary. Connection refusal means Zotero is not running, Better BibTeX is not installed, or local endpoints are blocked.

## 2. Create Zotero Web API Key

Create a Zotero key at:

```text
https://www.zotero.org/settings/keys
```

Required:

- library read access
- write access

Write access is needed for adding items, managing collections, and creating annotations.

## 3. Create MinerU API Token

Use MinerU API Management, not a normal web-login token.

Set:

```bash
MINERU_API_TOKEN=...
```

## 4. Install Python Packages

Install Zotero MCP with PDF support:

```bash
pip install "zotero-mcp-server[pdf]"
```

Install the custom MCP server:

```bash
git clone https://github.com/<your-org>/mineru-zotero-mcp.git
cd mineru-zotero-mcp
pip install -e .
```

The custom MCP server imports `zotero_mcp` internals, so `zotero-mcp-server[pdf]` must be installed in the same Python environment as `mineru-zotero-mcp`.

## 5. Prepare the Obsidian Vault

Use the `claude-obsidian` fork as the vault root:

```bash
git clone https://github.com/<your-org>/claude-obsidian.git
```

Set:

```bash
VAULT_ROOT=/absolute/path/to/claude-obsidian
```

Open that folder as an Obsidian vault.

If Obsidian still points at an old path, update the vault path from Obsidian's UI or edit the local app config. Restart Obsidian completely after changing vault path or hidden-file filters.

## 6. Configure MCP

Use the examples:

- `examples/codex.config.example.toml`
- `examples/zcode.mcp.example.json`

Minimum MCP env:

```bash
MINERU_API_TOKEN=...
VAULT_ROOT=/absolute/path/to/claude-obsidian
ZOTERO_LOCAL=true
ZOTERO_LIBRARY_ID=...
ZOTERO_USER_ID=...
ZOTERO_API_KEY=...
ZOTERO_LIBRARY_TYPE=user
```

Optional recommendation bridge:

```bash
RECOMMENDATIONS_URL=/absolute/path/to/zotero-arxiv-daily/data/recommendations
```

Optional WebDAV:

```bash
WEBDAV_URL=...
WEBDAV_USER=...
WEBDAV_PASS=...
```

WebDAV is only needed if you want the stack to bypass Zotero cloud file quota. It is not required when official Zotero file sync works for your library.

## 7. Install Codex Skills

From this repository:

```bash
scripts/install-codex-skills.sh /absolute/path/to/claude-obsidian
```

Restart Codex after installing skills or changing MCP config.

## 8. Smoke Test

Run:

```bash
scripts/doctor.sh
```

In an MCP client, expected checks:

```text
mineru_doctor()
arxiv_daily_recommendations(limit=3)     # if RECOMMENDATIONS_URL configured
zotero_list_libraries()
```

## 9. First Paper Test

Recommended first test:

1. Add a paper:

```text
zotero_add_by_url("https://arxiv.org/abs/<id>")
```

2. Get its attachment key:

```text
zotero_get_item_children(item_key=<parent_item_key>)
```

3. If the PDF is not locally available:

```text
zotero_local_sync(attachment_key=<attachment_key>, pdf_path=<downloaded_pdf>)
```

4. Parse:

```text
mineru_parse_pdf(item_key=<parent_item_key>)
```

5. Build indexes:

```bash
python "$VAULT_ROOT/skills/paper-wiki/scripts/build_indexes.py" --vault "$VAULT_ROOT"
```

6. Lint:

```bash
python "$VAULT_ROOT/skills/paper-wiki/scripts/lint_vault.py" --vault "$VAULT_ROOT"
```
