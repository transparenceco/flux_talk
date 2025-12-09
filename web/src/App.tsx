import React, { useEffect, useMemo, useState } from 'react'

interface ModelSource {
  name: string
  host?: string
  model?: string
  api_key?: string
  is_local: boolean
}

interface Message {
  id: number
  role: string
  content: string
  created_at: string
}

interface Conversation {
  id: number
  title: string
  created_at: string
  messages: Message[]
  model_source?: ModelSource
}

interface ChatResponse {
  conversation: Conversation
  reply: Message
}

const apiBase = import.meta.env.VITE_API_BASE || 'http://localhost:8000'

function App() {
  const [conversations, setConversations] = useState<Conversation[]>([])
  const [activeConversation, setActiveConversation] = useState<Conversation | null>(null)
  const [input, setInput] = useState('')
  const [modelSource, setModelSource] = useState<ModelSource>({
    name: 'LM Studio',
    is_local: true,
    host: 'http://localhost:1234',
  })
  const [collections, setCollections] = useState<string[]>([])
  const [selectedCollection, setSelectedCollection] = useState('')
  const [documents, setDocuments] = useState<{ ids: string[]; documents: string[]; metadatas: Record<string, unknown>[] } | null>(
    null
  )
  const [docForm, setDocForm] = useState({ id: '', text: '', metadata: '' })

  const loadConversations = async () => {
    const res = await fetch(`${apiBase}/conversations`)
    const data = await res.json()
    setConversations(data)
    if (!activeConversation && data.length) {
      setActiveConversation(data[0])
    }
  }

  useEffect(() => {
    loadConversations()
    loadCollections()
  }, [])

  const sendMessage = async () => {
    if (!input.trim()) return
    const payload = {
      conversation_id: activeConversation?.id,
      message: { content: input, role: 'user' },
      model_source: modelSource,
    }
    const res = await fetch(`${apiBase}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
    const data: ChatResponse = await res.json()
    setActiveConversation(data.conversation)
    setInput('')
    loadConversations()
  }

  const saveModelSource = async () => {
    if (!activeConversation) return
    await fetch(`${apiBase}/conversations/${activeConversation.id}/model`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(modelSource),
    })
    await loadConversations()
  }

  const loadCollections = async () => {
    const res = await fetch(`${apiBase}/chroma/collections`)
    const data = await res.json()
    setCollections(data.collections)
  }

  const createCollection = async (name: string) => {
    await fetch(`${apiBase}/chroma/collections`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, metadata: {} }),
    })
    loadCollections()
  }

  const loadDocuments = async (collection: string) => {
    const res = await fetch(`${apiBase}/chroma/documents/${collection}`)
    const data = await res.json()
    setSelectedCollection(collection)
    setDocuments(data)
  }

  const upsertDocument = async () => {
    if (!selectedCollection || !docForm.id || !docForm.text) return
    await fetch(`${apiBase}/chroma/documents`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        collection: selectedCollection,
        document_id: docForm.id,
        text: docForm.text,
        metadata: docForm.metadata ? JSON.parse(docForm.metadata) : {},
      }),
    })
    loadDocuments(selectedCollection)
  }

  const conversationMessages = useMemo(() => activeConversation?.messages ?? [], [activeConversation])

  return (
    <div className="layout">
      <aside className="sidebar">
        <h2>Conversations</h2>
        <button onClick={() => setActiveConversation(null)}>New Chat</button>
        <ul>
          {conversations.map((convo) => (
            <li key={convo.id} className={activeConversation?.id === convo.id ? 'active' : ''} onClick={() => setActiveConversation(convo)}>
              <div className="title">{convo.title}</div>
              <div className="subtitle">{convo.model_source?.name ?? 'No source'}</div>
            </li>
          ))}
        </ul>
      </aside>

      <main className="content">
        <section className="chat">
          <h1>Flux Talk</h1>
          <div className="messages">
            {conversationMessages.map((msg) => (
              <div key={msg.id} className={`message ${msg.role}`}>
                <strong>{msg.role}:</strong> {msg.content}
              </div>
            ))}
          </div>
          <div className="input-row">
            <textarea value={input} onChange={(e) => setInput(e.target.value)} placeholder="Say something" />
            <button onClick={sendMessage}>Send</button>
          </div>
        </section>

        <section className="settings">
          <h2>Model Settings</h2>
          <label>
            Source name
            <input value={modelSource.name} onChange={(e) => setModelSource({ ...modelSource, name: e.target.value })} />
          </label>
          <label>
            Host
            <input value={modelSource.host ?? ''} onChange={(e) => setModelSource({ ...modelSource, host: e.target.value })} />
          </label>
          <label>
            Model
            <input value={modelSource.model ?? ''} onChange={(e) => setModelSource({ ...modelSource, model: e.target.value })} />
          </label>
          <label>
            API Key (for online)
            <input value={modelSource.api_key ?? ''} onChange={(e) => setModelSource({ ...modelSource, api_key: e.target.value })} />
          </label>
          <label className="checkbox">
            <input
              type="checkbox"
              checked={modelSource.is_local}
              onChange={(e) => setModelSource({ ...modelSource, is_local: e.target.checked })}
            />
            Use LM Studio / local model
          </label>
          <button onClick={saveModelSource} disabled={!activeConversation}>
            Save settings to conversation
          </button>
        </section>

        <section className="chroma">
          <h2>ChromaDB</h2>
          <div className="collections">
            <h3>Collections</h3>
            <button onClick={() => createCollection(prompt('Collection name') || '')}>New Collection</button>
            <ul>
              {collections.map((c) => (
                <li key={c} onClick={() => loadDocuments(c)} className={selectedCollection === c ? 'active' : ''}>
                  {c}
                </li>
              ))}
            </ul>
          </div>
          {selectedCollection && (
            <div className="documents">
              <h3>Documents in {selectedCollection}</h3>
              <div className="doc-list">
                {documents?.documents?.map((doc, idx) => (
                  <div key={documents.ids[idx]} className="doc-item">
                    <strong>{documents.ids[idx]}</strong>
                    <p>{doc}</p>
                    <small>{JSON.stringify(documents.metadatas[idx] || {})}</small>
                  </div>
                ))}
              </div>
              <div className="doc-form">
                <input
                  placeholder="Document ID"
                  value={docForm.id}
                  onChange={(e) => setDocForm({ ...docForm, id: e.target.value })}
                />
                <textarea
                  placeholder="Text"
                  value={docForm.text}
                  onChange={(e) => setDocForm({ ...docForm, text: e.target.value })}
                />
                <input
                  placeholder='Metadata JSON (e.g. {"tag":"note"})'
                  value={docForm.metadata}
                  onChange={(e) => setDocForm({ ...docForm, metadata: e.target.value })}
                />
                <button onClick={upsertDocument}>Save Document</button>
              </div>
            </div>
          )}
        </section>
      </main>
    </div>
  )
}

export default App
