# Pipeline Patterns

## Pattern 1: Simple RAG Ingestion

Chunk documents and store in a vector database:

```python
from chonkie import Pipeline

docs = (Pipeline()
    .fetch_from("file", path="./knowledge_base/")
    .process_with("markdown")
    .chunk_with("recursive", chunk_size=512, tokenizer="tiktoken:gpt-4")
    .refine_with("embeddings", embedding_model="openai:text-embedding-3-small")
    .store_in("chroma", collection_name="kb")
    .run(show_progress=True)
)
```

## Pattern 2: Code Repository Ingestion

Chunk source code preserving function boundaries:

```python
from chonkie import Pipeline

docs = (Pipeline()
    .fetch_from("file", path="./src/", extensions=[".py", ".ts", ".rs"])
    .chunk_with("code", chunk_size=1024)
    .refine_with("embeddings", embedding_model="voyageai:voyage-code-3")
    .store_in("qdrant", url="http://localhost:6333", collection="code")
    .run(show_progress=True)
)
```

## Pattern 3: High-Quality Semantic Pipeline with Overlap Context

SemanticChunker has no built-in overlap — use OverlapRefinery to add surrounding context:

```python
from chonkie import Pipeline

docs = (Pipeline()
    .process_with("text")
    .chunk_with("semantic",
        embedding_model="minishlab/potion-base-32M",
        chunk_size=512,
        similarity_window=3,
    )
    .refine_with("overlap", context_size=64, method="suffix")  # append start of next chunk
    .refine_with("embeddings", embedding_model="openai:text-embedding-3-small")
    .export_with("json", file="semantic_chunks.json")
    .run(texts=documents, show_progress=True)
)
```

## Pattern 3b: Overlap as Separate Context (Not Merged)

Store overlap context in `chunk.context` without changing `chunk.text`:

```python
from chonkie import RecursiveChunker
from chonkie.refinery import OverlapRefinery

chunker = RecursiveChunker(chunk_size=512)
chunks = chunker(text)

refinery = OverlapRefinery(
    context_size=0.25,     # 25% of each chunk's token count
    method="prefix",       # prepend end of previous chunk
    merge=False,           # keep context separate from chunk.text
)
refined = refinery(chunks)

for chunk in refined:
    print(chunk.text)       # original text, unchanged
    print(chunk.context)    # surrounding context, or None for first chunk
```

## Pattern 4: Markdown + Tables Pipeline

Handle documents with embedded tables:

```python
from chonkie import Pipeline

docs = (Pipeline()
    .fetch_from("file", path="./docs/")
    .process_with("markdown")
    .chunk_with("table", chunk_size=2048)
    .chunk_with("recursive", chunk_size=512)
    .refine_with("overlap", context_size=64, method="suffix")
    .refine_with("embeddings", embedding_model="openai:text-embedding-3-small")
    .store_in("pinecone", index_name="docs", namespace="prod")
    .run(show_progress=True)
)
```

## Pattern 5: Batch Processing with Custom Tokenizer

Process many documents with token-accurate chunking:

```python
from chonkie import RecursiveChunker

chunker = RecursiveChunker(
    tokenizer="tiktoken:gpt-4",
    chunk_size=2048,
)

texts = [open(f).read() for f in file_list]
all_chunks = chunker(texts, show_progress=True)

for doc_chunks in all_chunks:
    for chunk in doc_chunks:
        print(f"[{chunk.token_count} tokens] {chunk.text[:80]}...")
```

## Pattern 6: Async High-Throughput Pipeline

```python
import asyncio
from chonkie import Pipeline

async def ingest_documents(texts: list[str]):
    pipeline = (Pipeline()
        .chunk_with("recursive", chunk_size=512)
        .refine_with("embeddings", embedding_model="openai:text-embedding-3-small")
        .store_in("qdrant", url="http://localhost:6333", collection="async_docs")
    )
    docs = await pipeline.arun(texts=texts, show_progress=True)
    return docs

asyncio.run(ingest_documents(large_text_list))
```

## Pattern 7: Export to HuggingFace Datasets

```python
from chonkie import Pipeline

docs = (Pipeline()
    .chunk_with("recursive", chunk_size=512)
    .refine_with("embeddings", embedding_model="minishlab/potion-base-32M")
    .export_with("datasets", dataset_name="my-chunked-corpus")
    .run(texts=documents)
)
```

## Pattern 8: Recipe-Based Pipeline

Load a pre-configured pipeline from HuggingFace Hub:

```python
from chonkie import Pipeline

pipeline = Pipeline.from_recipe(name="default", lang="en")
docs = pipeline.run(texts=["Your document..."])
```
