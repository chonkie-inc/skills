# Mandex Search Tips

## Writing Effective Queries

### Use specific terms, not questions
```bash
# Good
mx search pytorch "multi-head attention forward pass"
mx search nextjs "middleware matcher config"

# Less effective (too vague)
mx search pytorch "how to use attention"
mx search nextjs "middleware"
```

### Combine nouns and verbs
FTS5 uses Porter stemming, so "training" matches "train", "trained", etc.

```bash
mx search pytorch "train distributed data parallel"
mx search fastapi "validate request body pydantic"
```

### Use package-scoped search when you know the library
```bash
# Faster and more precise
mx search pytorch "autograd backward"

# Cross-package search when unsure which library
mx search "gradient computation automatic differentiation"
```

## Reranking Strategy

- **Enable reranking** (default) when queries are conceptual: "how to handle authentication"
- **Disable reranking** (`--no-rerank`) for exact term lookup: "MultiheadAttention parameters"
- **Increase candidates** (`--rerank-candidates 50`) for broad conceptual queries

## Building Better Packages

When building custom `.mandex` packages with `mx build`:

1. **Use clear `#` headings** — These become entry names in search results
2. **Keep files under 16KB** — Larger files get auto-split by `##` headings
3. **Prefer structured markdown** — Headers, code blocks, and lists index better than prose
4. **Include API signatures** — Function names and parameters are highly searchable
5. **One concept per file** — Improves relevance of search hits
