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

## Quick Reference

| Chunker | Speed | Quality | Dependencies | Cost |
|---------|-------|---------|-------------|------|
| FastChunker | ★★★★★ | ★★ | None | Free |
| TokenChunker | ★★★★ | ★★ | None | Free |
| SentenceChunker | ★★★★ | ★★★ | None | Free |
| RecursiveChunker | ★★★★ | ★★★★ | None | Free |
| CodeChunker | ★★★ | ★★★★ | tree-sitter | Free |
| SemanticChunker | ★★ | ★★★★ | embedding model | Free/API |
| LateChunker | ★★ | ★★★★★ | embedding model | Free/API |
| NeuralChunker | ★★ | ★★★★ | torch, transformers | Free |
| SlumberChunker | ★ | ★★★★★ | LLM API | API cost |
| TableChunker | ★★★ | ★★★ | pandas | Free |
