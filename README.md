# Flux Talk

Minimal scaffold for a local-first chatbot experience that can route to LM Studio (local) or an online model, persists chat in SQLite, and exposes ChromaDB for knowledge base management. Includes a FastAPI backend, a Vite/React web client, and a lightweight SwiftUI sample to mirror the chat interface on iOS.

## Backend (FastAPI)

### Setup
```
cd server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

- Chat endpoint: `POST /chat` with `message`, optional `conversation_id`, and `model_source` describing LM Studio vs online model.
- Conversations: `GET /conversations` and `GET /conversations/{id}`
- Model binding to a conversation: `POST /conversations/{id}/model`
- Chroma management: `GET/POST /chroma/collections`, `DELETE /chroma/collections/{name}`, `GET /chroma/documents/{collection}`, `POST /chroma/documents`

The server stores data in `server/app/flux_talk.sqlite3` and persists Chroma data under `server/app/chroma/`.

## Web client (Vite + React)

### Setup
```
cd web
npm install
npm run dev
```

Set `VITE_API_BASE` in a `.env` file to point at the FastAPI host (defaults to `http://localhost:8000`). The UI lets you:
- Chat and view message history
- Save model settings per conversation (toggle local vs online)
- Browse, create, and edit Chroma collections and documents

## iOS sample (SwiftUI)

The `ios/FluxTalk/ContentView.swift` file contains a minimal SwiftUI view that hits the same `/chat` endpoint and appends responses to a simple transcript. Integrate it into an Xcode SwiftUI app target and adjust the backend URL for device/simulator networking.

## Architecture notes
- SQLite via SQLAlchemy for conversations/messages/model sources
- ChromaDB client persisted to `server/app/chroma/`
- Model routing is stubbed to echo locally and will forward to an online host if provided; expand with LM Studio SDK/API calls as needed.
