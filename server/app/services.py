from __future__ import annotations

import logging
from typing import Optional

import requests
from chromadb import Client
from chromadb.config import Settings
from sqlalchemy.orm import Session

from . import models, schemas

logger = logging.getLogger(__name__)


def get_chroma_client(persist_directory: str) -> Client:
    return Client(Settings(persist_directory=persist_directory))


def ensure_conversation(
    db: Session, conversation_id: Optional[int] = None, model_source: Optional[schemas.ModelSourceCreate] = None
) -> models.Conversation:
    if conversation_id:
        convo = db.get(models.Conversation, conversation_id)
        if convo:
            return convo

    convo = models.Conversation()
    db.add(convo)
    db.flush()

    if model_source:
        source = models.ModelSource(
            conversation_id=convo.id,
            name=model_source.name,
            host=model_source.host,
            model=model_source.model,
            api_key=model_source.api_key,
            is_local=model_source.is_local,
        )
        db.add(source)
        convo.model_source = source
    return convo


def send_to_model(payload: schemas.ChatRequest) -> str:
    if payload.model_source and not payload.model_source.is_local and payload.model_source.host:
        headers = {}
        if payload.model_source.api_key:
            headers["Authorization"] = f"Bearer {payload.model_source.api_key}"
        try:
            response = requests.post(
                f"{payload.model_source.host.rstrip('/')}/v1/chat/completions",
                json={"model": payload.model_source.model, "messages": [{"role": payload.message.role, "content": payload.message.content}]},
                headers=headers,
                timeout=10,
            )
            response.raise_for_status()
            data = response.json()
            return data.get("choices", [{}])[0].get("message", {}).get("content", "")
        except Exception as exc:  # pragma: no cover - best-effort networking
            logger.warning("Falling back to stubbed reply due to remote error: %s", exc)
    # Stubbed local model response
    return f"Echo from {'LM Studio' if not payload.model_source or payload.model_source.is_local else 'remote model'}: {payload.message.content}"


def add_message(db: Session, conversation: models.Conversation, role: str, content: str) -> models.Message:
    message = models.Message(conversation_id=conversation.id, role=role, content=content)
    db.add(message)
    db.flush()
    db.refresh(message)
    return message


def upsert_model_source(db: Session, conversation: models.Conversation, model_source: schemas.ModelSourceCreate | None) -> None:
    if not model_source:
        return
    if conversation.model_source:
        conversation.model_source.name = model_source.name
        conversation.model_source.host = model_source.host
        conversation.model_source.model = model_source.model
        conversation.model_source.api_key = model_source.api_key
        conversation.model_source.is_local = model_source.is_local
    else:
        conversation.model_source = models.ModelSource(
            conversation_id=conversation.id,
            name=model_source.name,
            host=model_source.host,
            model=model_source.model,
            api_key=model_source.api_key,
            is_local=model_source.is_local,
        )


def serialize_conversation(conversation: models.Conversation) -> schemas.ConversationRead:
    return schemas.ConversationRead(
        id=conversation.id,
        title=conversation.title,
        created_at=conversation.created_at,
        messages=[
            schemas.MessageRead(
                id=msg.id, role=msg.role, content=msg.content, created_at=msg.created_at
            )
            for msg in sorted(conversation.messages, key=lambda m: m.created_at)
        ],
        model_source=(
            schemas.ModelSourceCreate(
                name=conversation.model_source.name,
                host=conversation.model_source.host,
                model=conversation.model_source.model,
                api_key=conversation.model_source.api_key,
                is_local=conversation.model_source.is_local,
            )
            if conversation.model_source
            else None
        ),
    )
