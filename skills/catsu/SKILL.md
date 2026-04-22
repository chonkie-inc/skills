---
name: catsu
description: "Use Catsu for unified, high-performance embedding API calls across 11 providers (OpenAI, VoyageAI, Cohere, Jina, Mistral, Gemini, Together AI, Mixedbread, Nomic, DeepInfra, Cloudflare) through a single consistent interface. Covers model selection and discovery, automatic retry with exponential backoff, cost and token tracking, Matryoshka dimension reduction, input type hints (query vs document), async/await support, and per-request API key overrides. Use when: generating embeddings, comparing embedding providers, building search or RAG systems, or integrating embeddings into Python or Rust applications."
license: MIT
metadata:
  author: chonkie-inc
  version: "0.1.0"
  category: embeddings
  repository: https://github.com/chonkie-inc/catsu
compatibility: "Python 3.10+ or Rust 2021 edition. Python package uses Rust core via PyO3 bindings. Requires API keys for chosen providers via environment variables."
---

# Catsu — Unified Embedding API Client

Catsu provides a single, consistent interface for generating embeddings across 11 providers and 35+ models. Built-in retry logic, cost tracking, and model discovery eliminate the need for provider-specific SDKs.

## When to Use This Skill

Use this skill when users want to:
- Generate embeddings from any provider through a unified API
- Compare embedding models across providers (cost, quality, dimensions)
- Add embeddings to a RAG pipeline, search system, or recommendation engine
- Switch between providers without changing application code
- Track token usage and costs across embedding calls
- Use Matryoshka embeddings (reduced dimensions) for storage optimization

## Installation

```bash
# Python
pip install catsu
# Requires Python 3.10+

# Rust
# Add to Cargo.toml:
# [dependencies]
# catsu = "0.1"
# tokio = { version = "1", features = ["full"] }
```

## Setup — API Keys

Set environment variables for the providers you use:

```bash
export OPENAI_API_KEY="sk-..."
export VOYAGE_API_KEY="pa-..."
export COHERE_API_KEY="..."
export JINA_API_KEY="jina_..."
export MISTRAL_API_KEY="..."
export GOOGLE_API_KEY="..."        # or GEMINI_API_KEY
export TOGETHER_API_KEY="..."
export MIXEDBREAD_API_KEY="..."
export NOMIC_API_KEY="..."
export DEEPINFRA_API_KEY="..."
export CLOUDFLARE_API_TOKEN="..."  # + CLOUDFLARE_ACCOUNT_ID
```

Only the keys for providers you actually call are required.

## Basic Usage

### Python

```python
from catsu import Client

client = Client()

# Embed text — provider:model format
response = client.embed(
    model="openai:text-embedding-3-small",
    input=["Hello, world!", "How are you?"]
)

print(response.embeddings)       # [[0.012, -0.034, ...], [...]]
print(response.dimensions)       # 1536
print(response.usage.tokens)     # 10
print(response.usage.cost)       # 0.000002
print(response.latency_ms)       # 142.5
```

### Rust

```rust
use catsu::Client;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new()?;

    let response = client.embed(
        "openai:text-embedding-3-small",
        vec!["Hello, world!".to_string()],
    ).await?;

    println!("Dimensions: {}", response.dimensions);
    println!("Cost: ${}", response.usage.cost.unwrap_or(0.0));
    Ok(())
}
```

## Model Specification

Three ways to specify which model to use:

```python
client = Client()

# 1. Provider prefix (recommended)
response = client.embed(model="voyageai:voyage-3", input="hello")

# 2. Explicit provider parameter
response = client.embed(provider="voyageai", model="voyage-3", input="hello")

# 3. Auto-detection (if model name is unique across providers)
response = client.embed(model="voyage-3", input="hello")
```

## Input Types — Query vs Document

Many providers optimize embeddings differently for search queries vs stored documents:

```python
# For search queries (short, question-like)
response = client.embed(
    model="voyageai:voyage-3",
    input=["what is attention?"],
    input_type="query",
)

# For documents being indexed (longer content)
response = client.embed(
    model="voyageai:voyage-3",
    input=["The attention mechanism allows models to..."],
    input_type="document",
)
```

Providers that support input types: VoyageAI, Cohere (required for v3+), Jina, Mistral, Gemini, Nomic.

## Custom Dimensions (Matryoshka Embeddings)

Reduce embedding dimensions for storage/speed at slight quality cost:

```python
# OpenAI: 1536 → 256 dimensions
response = client.embed(
    model="openai:text-embedding-3-small",
    input=["hello"],
    dimensions=256,
)
print(response.dimensions)  # 256
```

Providers supporting custom dimensions: OpenAI, VoyageAI, Cohere, Jina, Mistral, Gemini, Nomic.

## Supported Providers & Models

| Provider | Models | Dimensions | Max Tokens | Input Type | Custom Dims |
|----------|--------|-----------|------------|------------|-------------|
| **OpenAI** | text-embedding-3-small, 3-large, ada-002 | 1536, 3072, 1536 | 8191 | No | Yes |
| **VoyageAI** | voyage-3, voyage-code-3, voyage-finance-2, voyage-law-2, voyage-multilingual-2, voyage-multimodal-3 | 1024 | 32000 | Yes | Yes |
| **Cohere** | embed-v4.0, embed-english-v3.0, embed-multilingual-v3.0 | 1024 | 128000 | Required (v3+) | Yes |
| **Jina** | jina-embeddings-v4, v3, jina-code-v2 | 1024 | 32768 | Yes | Yes |
| **Mistral** | mistral-embed, codestral-embed-2505 | 1024 | 32768 | Yes | Yes |
| **Gemini** | gemini-embedding-001 | 768 | 2048 | Yes | Yes (128-3072) |
| **Together AI** | BAAI/bge models | 1024 | 8192 | No | No |
| **Mixedbread** | mxbai-embed models | 1024 | 512 | No | No |
| **Nomic** | nomic-embed-text-v1.5 | 768 | 8192 | Yes | Yes |
| **DeepInfra** | BAAI/bge models | 1024 | 8192 | No | No |
| **Cloudflare** | BGE, Qwen models | 768-1024 | 512-8192 | No | No |

## Model Discovery

```python
from catsu import Client

# List all available models
all_models = Client.list_models()

# Filter by provider
openai_models = Client.list_models("openai")
for m in openai_models:
    print(f"{m.name}: {m.dimensions}d, ${m.cost_per_million_tokens}/M tokens")

# Get specific model info
model = Client.get_model("openai", "text-embedding-3-small")
print(f"Max tokens: {model.max_tokens}")
print(f"Supports dimensions: {model.supports_dimensions}")

# Find model by name (auto-detect provider)
model = Client.find_model_by_name("voyage-3")
print(f"Provider: {model.provider}")
```

## Model Selection Guide

| Use Case | Recommended Model | Why |
|----------|------------------|-----|
| General purpose, low cost | `openai:text-embedding-3-small` | Best price/performance ratio |
| Highest quality retrieval | `voyageai:voyage-3` | Top MTEB scores |
| Code search | `voyageai:voyage-code-3` or `jina:jina-code-v2` | Code-optimized training |
| Legal / finance domain | `voyageai:voyage-law-2` / `voyage-finance-2` | Domain-specific |
| Multilingual content | `cohere:embed-multilingual-v3.0` or `voyageai:voyage-multilingual-2` | 100+ languages |
| Long documents (128K) | `cohere:embed-v4.0` | 128K token context |
| Free / self-hosted | `together:BAAI/bge-large-en-v1.5` | Open model, low cost |
| Multimodal (text + images) | `voyageai:voyage-multimodal-3` or `jina:jina-embeddings-v4` | Mixed content |

See `references/model_comparison.md` for detailed benchmarks and cost analysis.

## Retry & Error Handling

Catsu handles transient failures automatically:

```python
client = Client(
    max_retries=5,              # Default: 3
    timeout=60,                 # Default: 30 seconds
)

# Retries automatically on: 429, 408, 409, 500, 502, 503, 504
# Uses exponential backoff with jitter
# Respects Retry-After headers
```

### Explicit error handling

```python
from catsu.utils.errors import (
    RateLimitError,
    AuthenticationError,
    ModelNotFoundError,
    MissingApiKeyError,
)

try:
    response = client.embed(model="voyage-3", input="hello")
except RateLimitError as e:
    print(f"Rate limited. Retry after {e.retry_after}s")
except AuthenticationError:
    print("Invalid API key")
except ModelNotFoundError as e:
    print(f"Unknown model: {e}")
except MissingApiKeyError as e:
    print(f"Set {e.provider} API key")
```

## Advanced Configuration

### Per-request API key override

```python
response = client.embed(
    model="openai:text-embedding-3-small",
    input="hello",
    api_key="sk-different-key-for-this-request",
)
```

### HTTP proxy and custom CA

```python
# Python
client = Client(proxy="http://proxy:8080")

# Rust
let config = HttpConfig {
    proxy: Some("http://proxy:8080".to_string()),
    ca_cert_pem: Some(cert_pem_string),
    ..Default::default()
};
let client = Client::with_config(config)?;
```

### Context managers for cleanup

```python
# Sync
with Client() as client:
    response = client.embed("voyage-3", "hello")

# Async
async with Client() as client:
    response = await client.aembed("voyage-3", "hello")
```

### NumPy conversion

```python
response = client.embed("voyage-3", ["text1", "text2"])
arr = response.to_numpy()   # shape: (2, 1024)
```

## Async Support

```python
import asyncio
from catsu import Client

async def embed_batch():
    async with Client() as client:
        response = await client.aembed(
            model="openai:text-embedding-3-small",
            input=["text1", "text2", "text3"],
        )
        return response.embeddings

embeddings = asyncio.run(embed_batch())
```

## Integration with Chonkie

Catsu works as an embedding provider for Chonkie's RAG pipelines:

```python
pip install "chonkie[catsu]"
```

```python
from chonkie import Pipeline

# Use catsu as the embedding backend
docs = (Pipeline()
    .chunk_with("recursive", chunk_size=512)
    .refine_with("embeddings", embedding_model="catsu:voyage-3")
    .store_in("qdrant", url="http://localhost:6333", collection="docs")
    .run(texts=documents)
)
```

Or use Catsu's embeddings directly with Chonkie's `AutoEmbeddings`:

```python
from chonkie import AutoEmbeddings

embed = AutoEmbeddings.get_embeddings("catsu:openai:text-embedding-3-small")
vectors = embed.embed_batch(["text1", "text2"])
```
