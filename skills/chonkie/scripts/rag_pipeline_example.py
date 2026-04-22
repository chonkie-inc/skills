# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "chonkie[semantic,openai,qdrant]",
# ]
# ///
"""Minimal RAG ingestion pipeline using Chonkie.

Reads markdown files from a directory, chunks them with recursive splitting,
adds OpenAI embeddings, and stores in Qdrant.

Usage:
    uv run scripts/rag_pipeline_example.py --docs-dir ./knowledge_base --collection my_docs
"""

import argparse
from pathlib import Path
from chonkie import Pipeline


def main():
    parser = argparse.ArgumentParser(description="Chonkie RAG ingestion")
    parser.add_argument("--docs-dir", type=str, required=True, help="Path to markdown docs")
    parser.add_argument("--collection", type=str, default="documents", help="Qdrant collection name")
    parser.add_argument("--qdrant-url", type=str, default="http://localhost:6333", help="Qdrant URL")
    parser.add_argument("--chunk-size", type=int, default=512, help="Target chunk size in tokens")
    parser.add_argument("--embedding-model", type=str, default="openai:text-embedding-3-small")
    args = parser.parse_args()

    docs_path = Path(args.docs_dir)
    if not docs_path.exists():
        raise FileNotFoundError(f"Docs directory not found: {docs_path}")

    print(f"Ingesting from {docs_path} into Qdrant collection '{args.collection}'")

    docs = (Pipeline()
        .fetch_from("file", path=str(docs_path))
        .process_with("markdown")
        .chunk_with("recursive",
            chunk_size=args.chunk_size,
            tokenizer="tiktoken:gpt-4",
        )
        .refine_with("overlap", context_size=64)
        .refine_with("embeddings", embedding_model=args.embedding_model)
        .store_in("qdrant", url=args.qdrant_url, collection=args.collection)
        .run(show_progress=True)
    )

    total_chunks = sum(len(doc.chunks) for doc in docs) if isinstance(docs, list) else len(docs.chunks)
    print(f"Ingested {total_chunks} chunks into Qdrant collection '{args.collection}'")


if __name__ == "__main__":
    main()
