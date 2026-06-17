# Roadmap and Known Engineering Work

## Release Blockers

- Add explicit license for `mineru-zotero-mcp`.
- Audit `claude-obsidian` and `zotero-arxiv-daily` histories before making them public.
- Decide whether to publish a sanitized vault template instead of the full working vault.
- Fix or clearly document `arxiv_ingest_paper` failures on the Zotero item creation path.

## Short-Term Fixes

- Make `wiki-lock.sh` portable on macOS without requiring `flock`.
- Add a single `paper_wiki_write_source_page` helper so agents do not reimplement page-writing logic manually.
- Add synthetic fixtures for MinerU parse outputs.
- Add CI for `mineru-zotero-mcp` and paper-wiki scripts.
- Add one end-to-end documented example using a public arXiv paper.

## Medium-Term Improvements

- Support DOI and non-arXiv ingestion paths.
- Add idempotent Zotero collection mapping.
- Add public template vault generation.
- Add better validation for source pages, anchors, tables, and figure references.
- Add optional WebDAV setup docs without making WebDAV part of the required path.

## Non-Goals

- Publishing private vault data.
- Vendoring `zotero-mcp`.
- Treating WebDAV as mandatory.
- Hiding fork ancestry for modified upstream projects.
