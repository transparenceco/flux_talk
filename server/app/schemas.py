from __future__ import annotations

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class MessageCreate(BaseModel):
    content: str
    role: str = "user"


class ModelSourceCreate(BaseModel):
    name: str
    host: Optional[str] = None
    model: Optional[str] = None
    api_key: Optional[str] = None
    is_local: bool = True


class MessageRead(BaseModel):
    id: int
    role: str
    content: str
    created_at: datetime

    class Config:
        from_attributes = True


class ConversationRead(BaseModel):
    id: int
    title: str
    created_at: datetime
    messages: List[MessageRead] = []
    model_source: Optional[ModelSourceCreate] = None

    class Config:
        from_attributes = True


class ChatRequest(BaseModel):
    conversation_id: Optional[int] = None
    message: MessageCreate
    model_source: Optional[ModelSourceCreate] = None


class ChatResponse(BaseModel):
    conversation: ConversationRead
    reply: MessageRead


class ChromaCollectionRequest(BaseModel):
    name: str
    metadata: Optional[dict] = Field(default_factory=dict)


class ChromaDocumentRequest(BaseModel):
    collection: str
    document_id: str
    text: str
    metadata: Optional[dict] = Field(default_factory=dict)
