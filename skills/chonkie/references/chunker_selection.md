# Chunker Selection Guide

## Decision Tree

### 1. What type of content are you chunking?

**Source code** → Use `CodeChunker`
- Respects function, class, and block boundaries
- Auto-detects language (Python, JS, Rust, Go, etc.)
- Falls back to `RecursiveChunker` for unsupported languages

**Markdown with large tables** → Use `TableChunker` first, then chain with `RecursiveChunker`
```python
Pipeline()
    .chunk_with("table", chunk_size=2048)
    .chunk_with("recursive", chunk_size=512)
    .run(texts=[markdown_text])
```

**Plain text / prose / general documents** → Continue to step 2.

### 2. What matters most?

**Speed (processing TB+ of data)**
→ `FastChunker` — 100+ GB/s, SIMD-accelerated
→ Splitting is byte-level, so boundaries are approximate

**Quality (retrieval accuracy matters most)**
→ `SemanticChunker` — Groups content by embedding similarity
→ `SlumberChunker` — LLM-predicted boundaries (highest quality, slowest)
→ `NeuralChunker` — ML model predicts split points (good balance)

**Balance of speed + structure**
→ `RecursiveChunker` — Best default. Hierarchical splits that preserve document structure.

### 3. Do you need embeddings on each chunk?

**Yes, and embedding quality is critical**
→ `LateChunker` — Chunks and embeds in a single pass with context-aware representations

**Yes, standard embeddings are fine**
→ Any chunker + `EmbeddingsRefinery` post-processing

**No embeddings needed**
→ Any chunker works

### 4. Token budget compliance?

If chunks must be exactly ≤ N tokens for an LLM context window:
→ `TokenChunker` with `chunk_size=N` guarantees hard limits
→ `RecursiveChunker` also respects `chunk_size` but may produce slightly smaller chunks

### 5. Do you need overlap between chunks?

**Only TokenChunker and SentenceChunker** have a built-in `chunk_overlap` parameter that creates actual overlapping windows at chunking time.

**All other chunkers** should use `OverlapRefinery` as a post-processing step:
```python
from chonkie.refinery import OverlapRefinery

refinery = OverlapRefinery(context_size=64, method="suffix")
chunks = refinery(chunks)
```

Choose `method="suffix"` to append the start of the next chunk (default), or `method="prefix"` to prepend the end of the previous chunk. Set `merge=False` to keep context separate from `chunk.text`.

## Quick Reference

| Chunker | Speed | Quality | Built-in Overlap | Dependencies | Cost |
|---------|-------|---------|-----------------|-------------|------|
| FastChunker | ★★★★★ | ★★ | No | None | Free |
| TokenChunker | ★★★★ | ★★ | Yes (int/float) | None | Free |
| SentenceChunker | ★★★★ | ★★★ | Yes (int) | None | Free |
| RecursiveChunker | ★★★★ | ★★★★ | No | None | Free |
| CodeChunker | ★★★ | ★★★★ | No | tree-sitter | Free |
| SemanticChunker | ★★ | ★★★★ | No | embedding model | Free/API |
| LateChunker | ★★ | ★★★★★ | No | embedding model | Free/API |
| NeuralChunker | ★★ | ★★★★ | No | torch, transformers | Free |
| SlumberChunker | ★ | ★★★★ | No | LLM API | API cost |
| TableChunker | ★★★ | ★★★ | No | pandas | Free |

All chunkers without built-in overlap support `OverlapRefinery` for post-chunking context.
