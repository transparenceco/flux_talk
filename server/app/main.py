from __future__ import annotations

import logging
from pathlib import Path
from typing import List

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from . import db, models, schemas, services

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Flux Talk")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db():
    with db.session_scope() as session:
        yield session


@app.on_event("startup")
def startup_event() -> None:
    db.init_db()


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/chat", response_model=schemas.ChatResponse)
def chat(payload: schemas.ChatRequest, session: Session = Depends(get_db)):
    conversation = services.ensure_conversation(
        session, conversation_id=payload.conversation_id, model_source=payload.model_source
    )
    services.upsert_model_source(session, conversation, payload.model_source)

    user_message = services.add_message(session, conversation, payload.message.role, payload.message.content)
    reply_text = services.send_to_model(payload)
    reply_message = services.add_message(session, conversation, "assistant", reply_text)

    session.refresh(conversation)
    conversation_read = services.serialize_conversation(conversation)
    return schemas.ChatResponse(conversation=conversation_read, reply=schemas.MessageRead.model_validate(reply_message))


@app.get("/conversations", response_model=List[schemas.ConversationRead])
def list_conversations(session: Session = Depends(get_db)):
    conversations = session.query(models.Conversation).all()
    return [services.serialize_conversation(convo) for convo in conversations]


@app.get("/conversations/{conversation_id}", response_model=schemas.ConversationRead)
def get_conversation(conversation_id: int, session: Session = Depends(get_db)):
    conversation = session.get(models.Conversation, conversation_id)
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return services.serialize_conversation(conversation)


@app.post("/conversations/{conversation_id}/model", response_model=schemas.ConversationRead)
def update_model_source(conversation_id: int, model_source: schemas.ModelSourceCreate, session: Session = Depends(get_db)):
    conversation = session.get(models.Conversation, conversation_id)
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    services.upsert_model_source(session, conversation, model_source)
    session.refresh(conversation)
    return services.serialize_conversation(conversation)


@app.get("/chroma/collections")
def list_collections(session: Session = Depends(get_db)):
    chroma_dir = Path(db.BASE_DIR) / "chroma"
    chroma_dir.mkdir(exist_ok=True)
    client = services.get_chroma_client(str(chroma_dir))
    return {"collections": [col.name for col in client.list_collections()]}


@app.post("/chroma/collections")
def create_collection(collection: schemas.ChromaCollectionRequest, session: Session = Depends(get_db)):
    chroma_dir = Path(db.BASE_DIR) / "chroma"
    chroma_dir.mkdir(exist_ok=True)
    client = services.get_chroma_client(str(chroma_dir))
    client.get_or_create_collection(name=collection.name, metadata=collection.metadata)
    return {"status": "created", "name": collection.name}


@app.delete("/chroma/collections/{name}")
def delete_collection(name: str, session: Session = Depends(get_db)):
    chroma_dir = Path(db.BASE_DIR) / "chroma"
    chroma_dir.mkdir(exist_ok=True)
    client = services.get_chroma_client(str(chroma_dir))
    client.delete_collection(name)
    return {"status": "deleted", "name": name}


@app.post("/chroma/documents")
def upsert_document(document: schemas.ChromaDocumentRequest, session: Session = Depends(get_db)):
    chroma_dir = Path(db.BASE_DIR) / "chroma"
    chroma_dir.mkdir(exist_ok=True)
    client = services.get_chroma_client(str(chroma_dir))
    collection = client.get_or_create_collection(name=document.collection)
    collection.upsert(documents=[document.text], ids=[document.document_id], metadatas=[document.metadata])
    return {"status": "upserted", "id": document.document_id}


@app.get("/chroma/documents/{collection}")
def list_documents(collection: str, session: Session = Depends(get_db)):
    chroma_dir = Path(db.BASE_DIR) / "chroma"
    chroma_dir.mkdir(exist_ok=True)
    client = services.get_chroma_client(str(chroma_dir))
    collection_client = client.get_collection(name=collection)
    results = collection_client.get()
    return {
        "ids": results.get("ids", []),
        "documents": results.get("documents", []),
        "metadatas": results.get("metadatas", []),
    }
