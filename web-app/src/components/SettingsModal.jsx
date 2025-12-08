import React, { useState } from 'react';
import { apiService } from '../services/api';

function SettingsModal({ currentMode, onClose, onModeChange, onHistoryCleared }) {
  const [mode, setMode] = useState(currentMode);
  const [knowledgeContent, setKnowledgeContent] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);

  const modes = [
    { value: 'local', label: 'Local' },
    { value: 'grok', label: 'Grok' },
    { value: 'openai', label: 'OpenAI' },
  ];

  const handleSaveMode = async () => {
    try {
      await apiService.setSetting('ai_mode', mode);
      onModeChange(mode);
      alert('Mode saved successfully!');
    } catch (err) {
      alert('Failed to save mode: ' + err.message);
    }
  };

  const handleClearHistory = async () => {
    if (!confirm('Are you sure you want to clear all chat history?')) return;
    
    try {
      await apiService.clearChatHistory();
      onHistoryCleared();
      alert('Chat history cleared!');
    } catch (err) {
      alert('Failed to clear history: ' + err.message);
    }
  };

  const handleAddKnowledge = async (e) => {
    e.preventDefault();
    if (!knowledgeContent.trim()) return;

    try {
      await apiService.addVectorContent(knowledgeContent.trim(), {
        timestamp: new Date().toISOString(),
      });
      setKnowledgeContent('');
      alert('Knowledge added successfully!');
    } catch (err) {
      alert('Failed to add knowledge: ' + err.message);
    }
  };

  const handleSearch = async (e) => {
    e.preventDefault();
    if (!searchQuery.trim()) return;

    try {
      const results = await apiService.searchVectorContent(searchQuery, 5);
      setSearchResults(results.results || []);
    } catch (err) {
      alert('Failed to search: ' + err.message);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <h2>Settings</h2>

        <div className="modal-section">
          <h3>AI Mode</h3>
          <div className="mode-selector">
            {modes.map((m) => (
              <button
                key={m.value}
                className={`mode-option ${mode === m.value ? 'active' : ''}`}
                onClick={() => setMode(m.value)}
              >
                {m.label}
              </button>
            ))}
          </div>
          <button className="btn btn-primary" onClick={handleSaveMode} style={{ marginTop: '1rem' }}>
            Save Mode
          </button>
        </div>

        <div className="modal-section">
          <h3>Knowledge Base</h3>
          <form onSubmit={handleAddKnowledge} className="add-knowledge-form">
            <textarea
              placeholder="Add knowledge to the vector database..."
              value={knowledgeContent}
              onChange={(e) => setKnowledgeContent(e.target.value)}
            />
            <button type="submit" className="btn btn-primary" style={{ marginTop: '0.5rem' }}>
              Add Knowledge
            </button>
          </form>

          <form onSubmit={handleSearch} style={{ marginTop: '1rem' }}>
            <input
              type="text"
              placeholder="Search knowledge base..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{ width: '100%', padding: '0.75rem', borderRadius: '8px', border: '1px solid #ddd' }}
            />
            <button type="submit" className="btn btn-secondary" style={{ marginTop: '0.5rem' }}>
              Search
            </button>
          </form>

          {searchResults.length > 0 && (
            <div className="knowledge-container">
              <h4 style={{ marginTop: '1rem', marginBottom: '0.5rem' }}>Search Results:</h4>
              {searchResults.map((result, index) => (
                <div key={index} className="knowledge-item">
                  <div>{result.content}</div>
                  <small>Distance: {result.distance.toFixed(4)}</small>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="modal-section">
          <h3>Chat History</h3>
          <button className="btn btn-danger" onClick={handleClearHistory}>
            Clear All Messages
          </button>
        </div>

        <div className="modal-actions">
          <button className="btn btn-secondary" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
}

export default SettingsModal;
