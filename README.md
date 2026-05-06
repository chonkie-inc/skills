# Chonkie Skills

Agent Skills for text chunking, offline documentation search, and unified embeddings — built for Claude Code, Cursor, Gemini CLI, Codex, and other AI coding agents.

## Skills

| Skill | Description |
|-------|-------------|
| [chonkie](skills/chonkie/SKILL.md) | Fast, lightweight text chunking for RAG pipelines. 11 chunker types, Pipeline API, embeddings refineries, and vector DB integrations. |
| [mandex](skills/mandex/SKILL.md) | Offline documentation packages for AI agents. Pull, search, and build searchable doc packages with BM25 + semantic reranking. |
| [catsu](skills/catsu/SKILL.md) | Unified embedding API client for 11 providers through a single interface. Built-in retry, cost tracking, and model discovery. |

## Installation

### Skills (via `npx skills`)

```bash
# Claude Code
npx skills add chonkie-inc/skills

# Cursor
npx skills add chonkie-inc/skills --cursor

# Gemini CLI
npx skills add chonkie-inc/skills --gemini

# OpenAI Codex
npx skills add chonkie-inc/skills --codex

# VS Code / GitHub Copilot
npx skills add chonkie-inc/skills --vscode
```

### Plugins (native integration)

```bash
# Claude Code
/plugin marketplace add chonkie-inc/skills

# Cursor — add to .cursor/settings.json
# { "plugins": ["chonkie-inc/skills"] }

# Gemini CLI — add to ~/.gemini/settings.json
# { "extensions": ["github:chonkie-inc/skills"] }
```

### Manual

```bash
git clone https://github.com/chonkie-inc/skills.git
```

Then point your agent's skill/plugin path at the `skills/` directory.

## Related Projects

- [Chonkie](https://github.com/chonkie-inc/chonkie) — The chunking library
- [Mandex](https://github.com/chonkie-inc/mandex) — Documentation package manager
- [Catsu](https://github.com/chonkie-inc/catsu) — Unified embedding client
