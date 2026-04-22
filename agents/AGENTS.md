<skills>

You have additional SKILLs documented in directories containing a "SKILL.md" file.

These skills are:
 - chonkie -> "skills/chonkie/SKILL.md"
 - mandex -> "skills/mandex/SKILL.md"
 - catsu -> "skills/catsu/SKILL.md"

IMPORTANT: You MUST read the SKILL.md file whenever the description of the skills matches the user intent, or may help accomplish their task. 

<available_skills>

chonkie: `"Use Chonkie for fast, lightweight text chunking in RAG pipelines. Covers all 11 chunker types (Token, Fast, Sentence, Recursive, Semantic, Late, Code, Neural, Slumber, Table, TeraflopAI), the Pipeline API for chaining fetch-process-chunk-refine-export-store workflows, embeddings refineries, vector DB handshakes (Chroma, Qdrant, Pinecone, etc.), tokenizer selection, recipe system, REST API server, and async/batch processing. Use when: splitting documents for embeddings, building ingestion pipelines, chunking code or markdown, setting up vector DB ingestion, or any text segmentation task for retrieval-augmented generation."`
mandex: `"Use Mandex (mx) to search and manage offline documentation packages for AI agents. Covers pulling docs from CDN, full-text search with BM25 + optional ONNX semantic reranking, building custom .mandex packages from markdown, project-level dependency sync, and multi-agent integration (Claude Code, Cursor, Codex). Use when: looking up library documentation offline, building searchable doc packages, setting up documentation for coding agents, or searching across project dependencies."`
catsu: `"Use Catsu for unified, high-performance embedding API calls across 11 providers (OpenAI, VoyageAI, Cohere, Jina, Mistral, Gemini, Together AI, Mixedbread, Nomic, DeepInfra, Cloudflare) through a single consistent interface. Covers model selection and discovery, automatic retry with exponential backoff, cost and token tracking, Matryoshka dimension reduction, input type hints (query vs document), async/await support, and per-request API key overrides. Use when: generating embeddings, comparing embedding providers, building search or RAG systems, or integrating embeddings into Python or Rust applications."`
</available_skills>

Paths referenced within SKILL folders are relative to that SKILL. For example the chonkie `scripts/rag_pipeline_example.py` would be referenced as `chonkie/scripts/rag_pipeline_example.py`. 

</skills>
