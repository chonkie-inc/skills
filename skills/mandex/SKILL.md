---
name: mandex
description: "Use Mandex (mx) to search and manage offline documentation packages for AI agents. Covers pulling docs from CDN, full-text search with BM25 + optional ONNX semantic reranking, building custom .mandex packages from markdown, project-level dependency sync, and multi-agent integration (Claude Code, Cursor, Codex). Use when: looking up library documentation offline, building searchable doc packages, setting up documentation for coding agents, or searching across project dependencies."
license: MIT
metadata:
  author: chonkie-inc
  version: "0.1.11"
  category: developer-tools
  repository: https://github.com/chonkie-inc/mandex
compatibility: Single static Rust binary. No runtime dependencies. Supports macOS, Linux, Windows. Optional ONNX reranking requires model download on first run (~50MB).
---

# Mandex — Offline Documentation Packages for AI Agents

Mandex (`mx`) is a package registry for documentation designed for AI coding agents. It distributes searchable documentation packages that download once and query locally with zero rate limits and sub-millisecond latency.

## When to Use This Skill

Use this skill when users want to:
- Look up library/framework documentation without web access
- Search documentation for a specific library (PyTorch, Next.js, FastAPI, etc.)
- Build searchable documentation packages from markdown files
- Set up documentation access for AI coding assistants
- Sync project dependencies to auto-download relevant docs
- Query documentation across all installed packages

## Installation

```bash
# Recommended
curl -fsSL https://mandex.dev/install.sh | sh

# With Cargo
cargo install mandex

# From source
git clone https://github.com/chonkie-inc/mandex.git
cd mandex && cargo build --release
```

The binary is named `mx`. Verify with `mx --help`.

## Core Commands

### Pull — Download documentation packages

```bash
# Download latest version
mx pull pytorch
mx pull nextjs
mx pull fastapi

# Specific version
mx pull pytorch@2.3.0

# Multiple packages
mx pull pytorch numpy pandas
```

Packages are cached at `~/.mandex/cache/{name}/{version}.db` and shared across all projects.

### Search — Full-text search with BM25 + optional reranking

```bash
# Search within a specific package
mx search pytorch "attention mechanism"
mx search nextjs "server components caching"
mx search fastapi "dependency injection"

# Search across ALL installed packages
mx search "state management"

# Control result count
mx search pytorch "loss functions" -n 5

# Force semantic reranking (ONNX cross-encoder)
mx search pytorch "attention" --rerank

# Disable reranking (raw BM25 only)
mx search pytorch "attention" --no-rerank
```

Search uses SQLite FTS5 with Porter stemming. Optional ONNX reranking downloads a cross-encoder model on first use for semantic re-scoring of BM25 candidates.

### Show — Display a specific documentation entry

```bash
# Exact entry lookup
mx show pytorch "MultiheadAttention"
mx show fastapi "Depends"

# Falls back to FTS5 search if no exact match
mx show nextjs "middleware"
```

### List — View installed packages

```bash
mx list
# Output:
#   fastapi    0.135.1
#   nextjs     14.2.0
#   pytorch    2.3.0
```

### Info — Package metadata

```bash
mx info pytorch
# Output:
#   Name:     pytorch
#   Version:  2.3.0
#   Entries:  1,234
#   Size:     4.2 MB
```

### Remove — Uninstall packages

```bash
mx remove pytorch
mx remove pytorch --version 2.2.0  # Remove specific version only
```

### Sync — Auto-detect and download project docs

```bash
cd my-project/
mx sync
```

Scans `package.json`, `requirements.txt`, `pyproject.toml`, and `Cargo.toml` to detect dependencies. Downloads matching documentation packages and creates a merged search index.

Creates `.mandex/manifest.json` and `.mandex/index.db` in the project root.

### Build — Create custom documentation packages

```bash
# Build from a docs directory
mx build ./docs --name mylib --version 1.0.0

# Output: mylib@1.0.0.mandex (zstd-compressed SQLite)
```

Build process:
1. Walks directory for `.md`, `.mdx`, `.markdown` files
2. Extracts first `#` heading as entry name (falls back to filename)
3. Splits files >16KB by `##` headings into sections
4. Further chunks large sections by line breaks (16KB max)
5. Creates FTS5-indexed SQLite database
6. Compresses with zstd level 19 (5-10x ratio)

Compatible with Docusaurus, MkDocs, Mintlify, Sphinx markdown, plain markdown, and MDX.

### Init — Set up AI agent integrations

```bash
mx init
# Interactive setup for:
#   - Claude Code skill
#   - Cursor rules
#   - Windsurf instructions
#   - Codex agent instructions
```

## Available Packages (36+)

### npm ecosystem (23)
ai-sdk, astro, better-auth, claude-code, drizzle-orm, express, fumadocs, hono, langchain-js, mongodb, nextjs, openclaw, opencode, playwright, prisma, react, shadcn-ui, supabase, svelte, tailwindcss, trpc, vite, vue, zod

### pip ecosystem (12)
django, fastapi, flask, langchain, langgraph, numpy, pandas, pydantic, requests, scipy, sqlalchemy, transformers

### cargo ecosystem (1)
mandex

## Configuration

Config file at `~/.mandex/config.toml`:

```toml
[search]
results = 10                    # Results per query
rerank = true                   # Enable ONNX semantic reranking
rerank_candidates = 20          # BM25 candidates before reranking

[network]
cdn_url = "https://cdn.mandex.dev/v1"
api_url = "https://api.mandex.dev"

[display]
color = "auto"                  # "auto" | "always" | "never"
```

Environment variable overrides: `MX_SEARCH_RESULTS=20`, `MX_SEARCH_RERANK=false`, `MX_NETWORK_CDN_URL=...`, etc.

## Project Integration

Per-project manifest at `.mandex/manifest.json`:

```json
{
  "packages": {
    "pytorch": "2.3.0",
    "nextjs": "14.2.0",
    "fastapi": "0.135.1"
  }
}
```

After `mx sync`, the merged project index at `.mandex/index.db` enables fast cross-package search scoped to the project's dependencies.

## Search Architecture

1. **FTS5 + BM25:** Porter stemming, unicode61 tokenization, stop-word filtering
2. **AND/OR merging:** Queries try AND first (boosted 2x), then fall back to OR for broader recall
3. **Optional semantic reranking:** ONNX cross-encoder re-scores top-N BM25 results

Performance:
- Single-package search: ~40ms
- Project-wide search: ~70ms
- Startup time: <5ms (Rust binary vs ~200ms for Node.js)

See `references/search_tips.md` for query optimization guidance.
