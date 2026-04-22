# Embedding Model Comparison

## Cost Analysis (per 1M tokens)

| Model | Cost/1M | Dimensions | Quality (MTEB) |
|-------|---------|-----------|-----------------|
| openai:text-embedding-3-small | $0.02 | 1536 | Good |
| openai:text-embedding-3-large | $0.13 | 3072 | Very Good |
| voyageai:voyage-3 | $0.06 | 1024 | Excellent |
| voyageai:voyage-code-3 | $0.06 | 1024 | Excellent (code) |
| cohere:embed-v4.0 | $0.10 | 1024 | Very Good |
| cohere:embed-english-v3.0 | $0.10 | 1024 | Very Good |
| jina:jina-embeddings-v3 | $0.02 | 1024 | Good |
| mistral:mistral-embed | $0.10 | 1024 | Good |
| together:BAAI/bge-large-en-v1.5 | ~$0.008 | 1024 | Good |

## Choosing by Use Case

### Search / Retrieval (general)
1. **voyageai:voyage-3** — Best MTEB retrieval scores
2. **openai:text-embedding-3-large** — Strong all-round, widely supported
3. **cohere:embed-v4.0** — 128K context, great for long docs

### Code Search
1. **voyageai:voyage-code-3** — Purpose-built for code
2. **jina:jina-code-v2** — Good code-specific performance
3. **mistral:codestral-embed-2505** — Strong code understanding

### Budget-Conscious
1. **together:BAAI/bge-large-en-v1.5** — Cheapest option
2. **openai:text-embedding-3-small** — Best quality per dollar
3. **jina:jina-embeddings-v3** — Competitive pricing

### Multilingual
1. **cohere:embed-multilingual-v3.0** — 100+ languages
2. **voyageai:voyage-multilingual-2** — Strong multilingual scores
3. **jina:jina-embeddings-v3** — Good multilingual support

### Long Documents (>8K tokens)
1. **cohere:embed-v4.0** — 128K token context
2. **voyageai:voyage-3** — 32K tokens
3. **jina:jina-embeddings-v3** — 32K tokens
4. **mistral:mistral-embed** — 32K tokens

### Matryoshka (flexible dimensions)
Models supporting dimension reduction without retraining:
- OpenAI text-embedding-3-* (256, 512, 1024, 1536, 3072)
- VoyageAI voyage-3 (256, 512, 1024)
- Cohere embed-v4.0 (256, 384, 512, 768, 1024)
- Jina jina-embeddings-v3 (256, 512, 768, 1024)
- Gemini gemini-embedding-001 (128 to 3072)

Use smaller dimensions for faster similarity search and less storage, with moderate quality tradeoff.

## Latency Expectations

| Provider | Typical Latency (single input) |
|----------|-------------------------------|
| OpenAI | 100-200ms |
| VoyageAI | 150-300ms |
| Cohere | 200-400ms |
| Jina | 100-200ms |
| Mistral | 150-250ms |
| Gemini | 200-400ms |
| Together AI | 100-200ms |
| Cloudflare | 50-150ms (edge) |

Latencies vary by region, model size, and input length. Batch inputs to reduce per-item latency.
