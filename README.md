# Chonkie Skills

Agent Skills for text chunking, offline documentation search, and unified embeddings built for Claude Code, Cursor, Gemini CLI, and other AI coding agents.

## Skills

| Skill | Description |
|-------|-------------|
| [chonkie](skills/chonkie/SKILL.md) | Fast, lightweight text chunking for RAG pipelines. 11 chunker types, Pipeline API, embeddings refineries, and vector DB integrations. |
| [mandex](skills/mandex/SKILL.md) | Offline documentation packages for AI agents. Pull, search, and build searchable doc packages with BM25 + semantic reranking. |
| [catsu](skills/catsu/SKILL.md) | Unified embedding API client for 11 providers through a single interface. Built-in retry, cost tracking, and model discovery. |

## Installation

### Claude Code

```bash
claude install github:chonk-lain/skills
```

### Cursor

Install as a Cursor plugin from the `.cursor-plugin/` directory.

### Gemini CLI

Reference `gemini-extension.json` in your Gemini CLI configuration.

### Manual

Clone this repo and point your agent's skill/plugin path at the `skills/` directory.

## Repository Structure

```
skills/
├── .claude-plugin/          # Claude Code plugin manifest
│   ├── plugin.json
│   └── marketplace.json
├── .cursor-plugin/          # Cursor plugin manifest
│   ├── plugin.json
│   └── marketplace.json
├── agents/
│   └── AGENTS.md            # Fallback agent instructions
├── skills/
│   ├── chonkie/             # Chonkie chunking skill
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── scripts/
│   ├── mandex/              # Mandex documentation skill
│   │   ├── SKILL.md
│   │   └── references/
│   └── catsu/               # Catsu embeddings skill
│       ├── SKILL.md
│       └── references/
├── gemini-extension.json    # Gemini CLI extension
├── LICENSE
└── README.md
```

## Related Projects

- [Chonkie](https://github.com/chonkie-inc/chonkie) — The chunking library
- [Mandex](https://github.com/chonkie-inc/mandex) — Documentation package manager
- [Catsu](https://github.com/chonkie-inc/catsu) — Unified embedding client
