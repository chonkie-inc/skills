---
name: chonkie
description: "Use Chonkie for fast, lightweight text chunking in RAG pipelines. Covers all 11 chunker types (Token, Fast, Sentence, Recursive, Semantic, Late, Code, Neural, Slumber, Table, TeraflopAI), the Pipeline API for chaining fetch→process→chunk→refine→export→store workflows, embeddings refineries, vector DB handshakes (Chroma, Qdrant, Pinecone, etc.), tokenizer selection, recipe system, REST API server, and async/batch processing. Use when: splitting documents for embeddings, building ingestion pipelines, chunking code or markdown, setting up vector DB ingestion, or any text segmentation task for retrieval-augmented generation."
license: MIT
metadata:
  author: chonkie-inc
  version: "1.6.4"
  category: rag-ingestion
  repository: https://github.com/chonkie-inc/chonkie
compatibility: Requires Python 3.10+. Core has zero heavy dependencies (505KB wheel). Optional extras for semantic chunking, code chunking, vector DBs, LLM genies, and REST API.
---

# Chonkie — Fast, Lightweight Text Chunking for RAG

Chonkie is a high-performance Python library for splitting text into chunks optimized for retrieval-augmented generation. It provides 11 specialized chunkers, a composable Pipeline API, and integrations with 30+ embedding providers, vector databases, and LLMs.

## When to Use This Skill

Use this skill when users want to:
- Chunk or split text, documents, code, or markdown for RAG
- Build document ingestion pipelines for vector databases
- Choose a chunking strategy (token, sentence, semantic, recursive, code-aware)
- Set up end-to-end workflows: fetch → preprocess → chunk → embed → store
- Use the Chonkie REST API server for chunking-as-a-service
- Process large document batches with async/multiprocessing
- Configure tokenizers, embedding models, or recursive chunking rules

## Installation

```bash
# Core (lightweight, ~50MB installed)
pip install chonkie
# or with uv (faster)
uv pip install chonkie

# With specific features
pip install "chonkie[semantic]"       # Semantic chunking (model2vec)
pip install "chonkie[code]"           # Code-aware chunking (tree-sitter)
pip install "chonkie[openai]"         # OpenAI embeddings
pip install "chonkie[qdrant,chroma]"  # Vector DB integrations
pip install "chonkie[api]"            # REST API server

# Everything
pip install "chonkie[all]"
```

**Optional extras:** `hub`, `viz`, `cli`, `api`, `table`, `tokenizers`, `tiktoken`, `code`, `neural`, `semantic`, `st`, `openai`, `gemini`, `azure-openai`, `groq`, `cerebras`, `voyageai`, `cohere`, `jina`, `litellm`, `catsu`, `chroma`, `qdrant`, `pgvector`, `weaviate`, `pinecone`, `mongodb`, `elastic`, `milvus`, `lancedb`, `tpuf`, `datasets`

## Core Concepts

### Chunk Type

All chunkers return `Chunk` objects:

```python
Chunk(
    text="...",            # The chunk text
    start_index=0,         # Start position in original text
    end_index=512,         # End position in original text
    token_count=128,       # Token count (per configured tokenizer)
    context=None,          # Optional surrounding context
    embedding=None,        # Optional embedding vector (after refinement)
    metadata={},           # Arbitrary metadata dict
    id="uuid-...",         # Auto-generated UUID
)
```

### Calling a Chunker

```python
from chonkie import RecursiveChunker

chunker = RecursiveChunker(chunk_size=2048)

# Single text
chunks = chunker("Your long document text here...")

# Batch processing
batch_results = chunker(["doc1...", "doc2...", "doc3..."], show_progress=True)
# Returns: list[list[Chunk]]
```

## Chunker Types

### TokenChunker — Fixed-size token windows

```python
from chonkie import TokenChunker

# chunk_overlap accepts int (exact tokens) or float (fraction of chunk_size)
chunker = TokenChunker(chunk_size=512, chunk_overlap=64)
chunker = TokenChunker(chunk_size=512, chunk_overlap=0.1)  # 10% = 51 tokens
chunks = chunker(text)
```

Best for: Simple, predictable chunk sizes. Baseline chunking. One of only two chunkers with built-in `chunk_overlap`.

### FastChunker — SIMD byte-level (~100 GB/s)

```python
from chonkie import FastChunker
chunker = FastChunker(chunk_size=512)
chunks = chunker(text)
```

Best for: Maximum throughput on large corpora. Uses Rust SIMD acceleration. No built-in overlap — use `OverlapRefinery` after chunking.

### SentenceChunker — Sentence-boundary aware

```python
from chonkie import SentenceChunker
chunker = SentenceChunker(
    chunk_size=512,
    chunk_overlap=64,            # optional, int token overlap
    min_sentences_per_chunk=1,
)
chunks = chunker(text)
```

Best for: Natural language documents where sentence integrity matters. One of only two chunkers with built-in `chunk_overlap`.

### RecursiveChunker — Hierarchical splitting (recommended default)

```python
from chonkie import RecursiveChunker

# With default rules (paragraphs → sentences → words)
chunker = RecursiveChunker(chunk_size=2048)

# With custom rules
from chonkie.types import RecursiveRules, RecursiveLevel
rules = RecursiveRules(levels=[
    RecursiveLevel(delimiters=["\n\n"]),        # Split on paragraphs
    RecursiveLevel(delimiters=["\n"]),           # Then lines
    RecursiveLevel(delimiters=[". ", "! ", "?"]),# Then sentences
    RecursiveLevel(whitespace=True),             # Then words
])
chunker = RecursiveChunker(chunk_size=2048, rules=rules)

# With a language-specific recipe from HuggingFace Hub
chunker = RecursiveChunker(chunk_size=2048, recipe="markdown", lang="en")
chunks = chunker(text)
```

Best for: General-purpose chunking. Preserves document structure hierarchically. **Start here if unsure.**

### SemanticChunker — Embedding-similarity splits

```python
from chonkie import SemanticChunker
chunker = SemanticChunker(
    embedding_model="minishlab/potion-base-32M",
    chunk_size=512,
    similarity_window=2,
)
chunks = chunker(text)
```

Requires: `pip install "chonkie[semantic]"`

Best for: Grouping semantically related content. Higher quality but slower.

### LateChunker — Chunk-then-embed for better embeddings

```python
from chonkie import LateChunker
chunker = LateChunker(
    embedding_model="minishlab/potion-base-32M",
    chunk_size=512,
)
chunks = chunker(text)
```

Best for: When chunk embedding quality is critical. Each chunk gets a context-aware embedding.

### CodeChunker — Structure-aware code splitting

```python
from chonkie import CodeChunker
chunker = CodeChunker(
    language="python",  # or auto-detect
    chunk_size=512,
)
chunks = chunker(code_text)
```

Requires: `pip install "chonkie[code]"`

Best for: Source code. Respects function/class boundaries via tree-sitter parsing.

### NeuralChunker — Token-classification model

```python
from chonkie import NeuralChunker
chunker = NeuralChunker(
    model="mirth/chonkie_bert_uncased_1",  # Pre-trained
)
chunks = chunker(text)
```

Requires: `pip install "chonkie[neural]"`

Best for: When you want ML-predicted chunk boundaries. Three pre-trained models available.

### SlumberChunker — LLM-based semantic chunking

```python
from chonkie import SlumberChunker
from chonkie.genie import OpenAIGenie

genie = OpenAIGenie(model="gpt-4o-mini")
chunker = SlumberChunker(genie=genie, chunk_size=1024)
chunks = chunker(text)
```

Best for: Highest-quality semantic splits using an LLM. Slowest but most intelligent.

### TableChunker — Markdown/HTML table splitting

```python
from chonkie import TableChunker
chunker = TableChunker(chunk_size=512)
chunks = chunker(markdown_with_tables)
```

Requires: `pip install "chonkie[table]"`

Best for: Documents with large tables that need row-level splitting.

### TeraflopAIChunker — External API-based

```python
from chonkie import TeraflopAIChunker
chunker = TeraflopAIChunker(api_key="...", chunk_size=512)
chunks = chunker(text)
```

Best for: Using TeraflopAI's hosted segmentation service.

## Chunker Selection Guide

| Scenario | Recommended Chunker |
|----------|-------------------|
| General purpose / don't know | `RecursiveChunker` |
| Maximum speed, huge corpora | `FastChunker` |
| Natural language prose | `SentenceChunker` or `RecursiveChunker` |
| Semantic grouping needed | `SemanticChunker` |
| Source code files | `CodeChunker` |
| Best possible quality, cost OK | `SlumberChunker` (LLM) |
| Markdown with tables | `TableChunker` + `RecursiveChunker` |
| Token budget compliance | `TokenChunker` |

See `references/chunker_selection.md` for detailed decision guidance.

## Tokenizers

All chunkers accept a `tokenizer` parameter to control how text size is measured:

```python
from chonkie import RecursiveChunker

# Built-in (no extra deps)
chunker = RecursiveChunker(tokenizer="character", chunk_size=4000)  # char count
chunker = RecursiveChunker(tokenizer="word", chunk_size=500)        # word count

# HuggingFace tokenizers (pip install "chonkie[tokenizers]")
chunker = RecursiveChunker(tokenizer="tokenizers:gpt2", chunk_size=512)

# OpenAI tiktoken (pip install "chonkie[tiktoken]")
chunker = RecursiveChunker(tokenizer="tiktoken:gpt-4", chunk_size=512)

# Custom callable
def my_counter(text: str) -> int:
    return len(text.split())
chunker = RecursiveChunker(tokenizer=my_counter, chunk_size=500)
```

Default tokenizer is `"character"` (no dependencies). For LLM-aligned chunking, use `"tiktoken:gpt-4"` or a HuggingFace tokenizer matching your embedding model.

## Pipeline API

The Pipeline chains processing steps fluently:

```python
from chonkie import Pipeline

# Full end-to-end pipeline
docs = (Pipeline()
    .fetch_from("file", path="./documents/")
    .process_with("markdown")
    .chunk_with("recursive", chunk_size=1024)
    .refine_with("embeddings", embedding_model="openai:text-embedding-3-small")
    .store_in("qdrant", url="http://localhost:6333", collection="my_docs")
    .run(show_progress=True)
)

# Chain multiple chunkers
docs = (Pipeline()
    .chunk_with("table", chunk_size=2048)          # Split tables first
    .chunk_with("recursive", chunk_size=512)        # Then recursive split
    .refine_with("overlap", context_size=128)       # Add overlap context
    .export_with("json", file="chunks.json")        # Save to JSON
    .run(texts=["Your document text..."])
)

# Async execution for high throughput
docs = await (Pipeline()
    .chunk_with("semantic", chunk_size=512)
    .arun(texts=large_text_list)
)

# Load from a HuggingFace recipe
pipeline = Pipeline.from_recipe(name="default", lang="en")
docs = pipeline.run(texts=["..."])
```

### Pipeline Step Types

| Step | Method | Options |
|------|--------|---------|
| **Fetch** | `.fetch_from("file", path=...)` | Single file or directory with extension filtering |
| **Process** | `.process_with("markdown" \| "text" \| "table")` | Preprocesses raw text |
| **Chunk** | `.chunk_with("recursive" \| "semantic" \| ...)` | Any of the 11 chunker types |
| **Refine** | `.refine_with("overlap" \| "embeddings", ...)` | Post-chunk processing |
| **Export** | `.export_with("json" \| "datasets", ...)` | Save to file or HF datasets |
| **Store** | `.store_in("chroma" \| "qdrant" \| "pinecone" \| ...)` | Vector DB ingestion |

## Overlap and Context

Chonkie has two distinct mechanisms for adding surrounding context to chunks. Understanding the difference is important.

### Built-in `chunk_overlap` (chunking-time)

Only **TokenChunker** and **SentenceChunker** support a `chunk_overlap` parameter. This creates actual overlapping token windows during chunking — adjacent chunks share content at their boundaries.

```python
from chonkie import TokenChunker

chunker = TokenChunker(chunk_size=512, chunk_overlap=64)
chunks = chunker(text)
# Chunk N ends at token 512, Chunk N+1 starts at token 448 (512-64)
```

- `int` value: exact token count overlap
- `float` value (0-1): fraction of `chunk_size` (e.g., `0.1` = 10%)
- Affects `start_index`/`end_index` — chunks genuinely overlap in the source text

All other chunkers (Recursive, Semantic, Code, Fast, Neural, Slumber, Table, Late, TeraflopAI) do **not** have built-in overlap. Use the OverlapRefinery instead.

### OverlapRefinery (post-chunking)

Adds surrounding context to chunks **after** they've been created by any chunker. This is the recommended approach for all chunkers.

```python
from chonkie import RecursiveChunker
from chonkie.refinery import OverlapRefinery

chunker = RecursiveChunker(chunk_size=512)
chunks = chunker(text)

refinery = OverlapRefinery(
    context_size=128,         # int (exact tokens) or float (fraction of chunk token_count)
    method="suffix",          # "suffix" (default) or "prefix"
    mode="token",             # "token" (default) or "recursive"
    merge=True,               # True: append/prepend to chunk.text; False: store in chunk.context only
    inplace=True,             # modify chunks in place
)
refined = refinery(chunks)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `context_size` | int or float | 0.25 | Tokens of context to add. Float (0-1) = fraction of chunk's token_count |
| `method` | `"suffix"` or `"prefix"` | `"suffix"` | `suffix`: appends start of next chunk. `prefix`: prepends end of previous chunk |
| `mode` | `"token"` or `"recursive"` | `"token"` | `token`: exact token slicing. `recursive`: split at logical boundaries (delimiters) |
| `merge` | bool | True | If True, context is merged into `chunk.text` and `token_count` is updated. If False, context is stored in `chunk.context` field only |
| `inplace` | bool | True | Modify chunks in place or return copies |

**Suffix method** (default): takes the first N tokens of the *next* chunk and appends them to the current chunk — provides "what comes after" context.

**Prefix method**: takes the last N tokens of the *previous* chunk and prepends them to the current chunk — provides "what came before" context.

When `merge=False`, `chunk.text` and `start_index`/`end_index` stay unchanged; context is stored separately in the `chunk.context` field.

### In a Pipeline

```python
from chonkie import Pipeline

docs = (Pipeline()
    .chunk_with("recursive", chunk_size=512)
    .refine_with("overlap", context_size=0.25, method="suffix")
    .refine_with("embeddings", embedding_model="openai:text-embedding-3-small")
    .run(texts=documents)
)
```

## Embeddings

Add embeddings to chunks with the `EmbeddingsRefinery` or via Pipeline:

```python
from chonkie import AutoEmbeddings, EmbeddingsRefinery

# Local models
embed = AutoEmbeddings.get_embeddings("minishlab/potion-base-32M")
embed = AutoEmbeddings.get_embeddings("sentence-transformers/all-MiniLM-L6-v2")

# API-based
embed = AutoEmbeddings.get_embeddings("openai:text-embedding-3-small")
embed = AutoEmbeddings.get_embeddings("cohere")
embed = AutoEmbeddings.get_embeddings("voyageai")

# Apply to chunks
refinery = EmbeddingsRefinery(embedding_model=embed)
chunks_with_embeddings = refinery(chunks)
# Each chunk now has chunk.embedding populated
```

## Vector Database Integrations

One-line ingestion from chunks into vector stores:

```python
from chonkie.handshakes import ChromaHandshake, QdrantHandshake, PineconeHandshake

# ChromaDB
ChromaHandshake(collection_name="docs").write(chunks)

# Qdrant
QdrantHandshake(url="http://localhost:6333", collection_name="docs").write(chunks)

# Pinecone
PineconeHandshake(index_name="docs", namespace="prod").write(chunks)

# Also: Weaviate, Elastic, MongoDB, PostgreSQL (pgvector),
#        LanceDB, Milvus, Turbopuffer
```

All handshakes support async: `await handshake.awrite(chunks)`

## REST API Server

Serve Chonkie as an API:

```bash
pip install "chonkie[api]"
chonkie serve --port 3000 --reload
```

Key endpoints:
- `POST /v1/chunking/{chunker_name}` — Chunk text
- `POST /v1/refineries/{refinery_name}` — Refine chunks
- `POST /v1/pipelines` — Create reusable pipeline
- `POST /v1/pipelines/{id}/run` — Execute saved pipeline
- `GET /docs` — Interactive API documentation

Pipelines are persisted in SQLite for reuse across applications.

## Recipes

Load language-specific chunking rules from HuggingFace Hub:

```python
from chonkie.types import RecursiveRules

rules = RecursiveRules.from_recipe(name="markdown", lang="en")
chunker = RecursiveChunker(rules=rules, chunk_size=2048)

# 56 languages supported
rules_ja = RecursiveRules.from_recipe(name="default", lang="ja")
```

Recipes are hosted at `chonkie-ai/recipes` on HuggingFace Hub.

## Performance

- **FastChunker:** 100+ GB/s (SIMD-accelerated via Rust core)
- **RecursiveChunker:** 33x faster than LangChain equivalent
- **SemanticChunker:** ~2.5x faster than competitors
- **Wheel size:** 505KB | **Installed:** ~49MB (default)
- Batch processing with multiprocessing and progress bars

## Common Patterns

See `references/pipeline_patterns.md` for complete pipeline examples and `scripts/rag_pipeline_example.py` for a production-ready ingestion script.
