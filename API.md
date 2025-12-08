# Flux Talk API Documentation

## Base URL
```
http://localhost:8080
```

## Endpoints

### Health Check

#### GET /health
Check server health status.

**Response:**
```json
{
  "status": "ok"
}
```

---

### Chat Endpoints

#### POST /api/chat
Send a message to the AI and get a response.

**Request Body:**
```json
{
  "message": "Hello, how are you?",
  "useContext": true
}
```

**Parameters:**
- `message` (string, required): The message to send to the AI
- `useContext` (boolean, optional): Whether to use vector DB context for the response. Defaults to `true`.

**Response:**
```json
{
  "message": "I'm doing well, thank you! How can I help you today?",
  "provider": "local",
  "messageId": "550e8400-e29b-41d4-a716-446655440000"
}
```

#### GET /api/chat/history
Retrieve all chat messages.

**Response:**
```json
{
  "messages": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "role": "user",
      "content": "Hello!",
      "provider": "local",
      "createdAt": "2024-01-01T12:00:00Z"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "role": "assistant",
      "content": "Hi! How can I help you?",
      "provider": "local",
      "createdAt": "2024-01-01T12:00:01Z"
    }
  ]
}
```

#### DELETE /api/chat/history
Clear all chat messages.

**Response:**
```
204 No Content
```

---

### Settings Endpoints

#### GET /api/settings
Get all settings.

**Response:**
```json
[
  {
    "key": "ai_mode",
    "value": "local"
  }
]
```

#### GET /api/settings/:key
Get a specific setting.

**Parameters:**
- `key` (path parameter): The setting key (e.g., "ai_mode")

**Response:**
```json
{
  "key": "ai_mode",
  "value": "local"
}
```

#### POST /api/settings
Create or update a setting.

**Request Body:**
```json
{
  "key": "ai_mode",
  "value": "grok"
}
```

**Supported Settings:**
- `ai_mode`: AI provider mode (`"local"`, `"grok"`, or `"openai"`)

**Response:**
```json
{
  "key": "ai_mode",
  "value": "grok"
}
```

---

### Vector Database Endpoints

#### POST /api/vector/add
Add content to the vector database for context enhancement.

**Request Body:**
```json
{
  "content": "The capital of France is Paris.",
  "metadata": {
    "source": "geography",
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

**Parameters:**
- `content` (string, required): The content to add to the vector database
- `metadata` (object, optional): Additional metadata about the content

**Response:**
```
201 Created
```

#### POST /api/vector/search
Search the vector database for relevant content.

**Request Body:**
```json
{
  "query": "What is the capital of France?",
  "limit": 5
}
```

**Parameters:**
- `query` (string, required): The search query
- `limit` (integer, optional): Number of results to return. Defaults to 5.

**Response:**
```json
{
  "results": [
    {
      "content": "The capital of France is Paris.",
      "distance": 0.234,
      "metadata": {
        "source": "geography"
      }
    }
  ]
}
```

**Note:** Lower distance values indicate better matches.

---

## AI Provider Configuration

### Local Mode (LM Studio)
- Requires LM Studio running on `localhost:1234`
- No API key needed
- Completely private and offline

### Grok Mode (xAI)
- Requires `GROK_API_KEY` environment variable
- Set in `backend/.env`
- Uses Grok-beta model

### OpenAI Mode
- Requires `OPENAI_API_KEY` environment variable
- Set in `backend/.env`
- Uses GPT-4 model

---

## Error Responses

All endpoints may return error responses in the following format:

**400 Bad Request:**
```json
{
  "error": true,
  "reason": "Missing required parameter: message"
}
```

**404 Not Found:**
```json
{
  "error": true,
  "reason": "Setting not found"
}
```

**500 Internal Server Error:**
```json
{
  "error": true,
  "reason": "Failed to connect to AI provider"
}
```

---

## Examples

### cURL Examples

#### Send a chat message:
```bash
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Tell me about Swift programming"}'
```

#### Get chat history:
```bash
curl http://localhost:8080/api/chat/history
```

#### Change AI mode to Grok:
```bash
curl -X POST http://localhost:8080/api/settings \
  -H "Content-Type: application/json" \
  -d '{"key": "ai_mode", "value": "grok"}'
```

#### Add knowledge to vector DB:
```bash
curl -X POST http://localhost:8080/api/vector/add \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Swift is a powerful and intuitive programming language for iOS, macOS, watchOS, and tvOS.",
    "metadata": {"topic": "programming"}
  }'
```

#### Search vector DB:
```bash
curl -X POST http://localhost:8080/api/vector/search \
  -H "Content-Type: application/json" \
  -d '{"query": "What is Swift?", "limit": 3}'
```

---

## Rate Limiting

Currently, there is no rate limiting implemented in the MVP. For production use, consider adding rate limiting middleware.

## CORS

The server is configured to accept requests from any origin (`Access-Control-Allow-Origin: *`). Adjust CORS settings in production as needed.

## Database

- Chat messages are stored in SQLite (`flux_talk.sqlite`)
- Vector embeddings can be stored in Chroma (optional, falls back to simple embeddings if Chroma is not available)
