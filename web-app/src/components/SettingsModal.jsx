import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';

function SettingsModal({ currentMode, onClose, onModeChange, onHistoryCleared }) {
  const [mode, setMode] = useState(currentMode);
  const [knowledgeContent, setKnowledgeContent] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  
  // AI Settings
  const [temperature, setTemperature] = useState(0.7);
  const [localModel, setLocalModel] = useState('local-model');
  const [grokModel, setGrokModel] = useState('grok-beta');
  const [openaiModel, setOpenaiModel] = useState('gpt-4');
  const [grokApiKey, setGrokApiKey] = useState('');
  const [openaiApiKey, setOpenaiApiKey] = useState('');
  const [localBaseUrl, setLocalBaseUrl] = useState('http://localhost:1234/v1');
  const [useContextByDefault, setUseContextByDefault] = useState(true);

  const modes = [
    { value: 'local', label: 'Local' },
    { value: 'grok', label: 'Grok' },
    { value: 'openai', label: 'OpenAI' },
  ];

  // Load settings on mount
  useEffect(() => {
    loadAISettings();
  }, []);

  const loadAISettings = async () => {
    try {
      const settings = await apiService.getSettings();
      const settingsMap = settings.reduce((acc, s) => {
        acc[s.key] = s.value;
        return acc;
      }, {});

      setTemperature(parseFloat(settingsMap.temperature || '0.7'));
      setLocalModel(settingsMap.local_model || 'local-model');
      setGrokModel(settingsMap.grok_model || 'grok-beta');
      setOpenaiModel(settingsMap.openai_model || 'gpt-4');
      setGrokApiKey(settingsMap.grok_api_key || '');
      setOpenaiApiKey(settingsMap.openai_api_key || '');
      setLocalBaseUrl(settingsMap.local_base_url || 'http://localhost:1234/v1');
      setUseContextByDefault(settingsMap.use_context === 'true');
    } catch (err) {
      console.error('Failed to load AI settings:', err);
    }
  };

  const handleSaveMode = async () => {
    try {
      await apiService.setSetting('ai_mode', mode);
      onModeChange(mode);
      alert('Mode saved successfully!');
    } catch (err) {
      alert('Failed to save mode: ' + err.message);
    }
  };

  const handleSaveAISettings = async () => {
    try {
      await Promise.all([
        apiService.setSetting('temperature', temperature.toString()),
        apiService.setSetting('local_model', localModel),
        apiService.setSetting('grok_model', grokModel),
        apiService.setSetting('openai_model', openaiModel),
        apiService.setSetting('local_base_url', localBaseUrl),
        apiService.setSetting('use_context', useContextByDefault.toString()),
        grokApiKey ? apiService.setSetting('grok_api_key', grokApiKey) : Promise.resolve(),
        openaiApiKey ? apiService.setSetting('openai_api_key', openaiApiKey) : Promise.resolve(),
      ]);
      alert('AI settings saved successfully!');
    } catch (err) {
      alert('Failed to save AI settings: ' + err.message);
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
          <h3>AI Configuration</h3>
          
          <div className="form-group">
            <label>
              Temperature: {temperature.toFixed(2)}
              <small style={{ display: 'block', color: '#666', marginBottom: '0.5rem' }}>
                Controls randomness (0 = focused, 2 = creative)
              </small>
            </label>
            <input
              type="range"
              min="0"
              max="2"
              step="0.1"
              value={temperature}
              onChange={(e) => setTemperature(parseFloat(e.target.value))}
              style={{ width: '100%' }}
            />
          </div>

          {mode === 'local' && (
            <>
              <div className="form-group">
                <label>LM Studio Base URL</label>
                <input
                  type="text"
                  value={localBaseUrl}
                  onChange={(e) => setLocalBaseUrl(e.target.value)}
                  placeholder="http://localhost:1234/v1"
                />
              </div>
              <div className="form-group">
                <label>Model Name</label>
                <input
                  type="text"
                  value={localModel}
                  onChange={(e) => setLocalModel(e.target.value)}
                  placeholder="local-model"
                />
              </div>
            </>
          )}

          {mode === 'grok' && (
            <>
              <div className="form-group">
                <label>Grok API Key</label>
                <input
                  type="password"
                  value={grokApiKey}
                  onChange={(e) => setGrokApiKey(e.target.value)}
                  placeholder="Enter your Grok API key"
                />
              </div>
              <div className="form-group">
                <label>Model</label>
                <select value={grokModel} onChange={(e) => setGrokModel(e.target.value)}>
                  <option value="grok-beta">grok-beta</option>
                  <option value="grok-vision-beta">grok-vision-beta</option>
                </select>
              </div>
            </>
          )}

          {mode === 'openai' && (
            <>
              <div className="form-group">
                <label>OpenAI API Key</label>
                <input
                  type="password"
                  value={openaiApiKey}
                  onChange={(e) => setOpenaiApiKey(e.target.value)}
                  placeholder="Enter your OpenAI API key"
                />
              </div>
              <div className="form-group">
                <label>Model</label>
                <select value={openaiModel} onChange={(e) => setOpenaiModel(e.target.value)}>
                  <option value="gpt-4">GPT-4</option>
                  <option value="gpt-4-turbo">GPT-4 Turbo</option>
                  <option value="gpt-3.5-turbo">GPT-3.5 Turbo</option>
                </select>
              </div>
            </>
          )}

          <div className="form-group">
            <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <input
                type="checkbox"
                checked={useContextByDefault}
                onChange={(e) => setUseContextByDefault(e.target.checked)}
              />
              Use vector database context by default
            </label>
          </div>

          <button className="btn btn-primary" onClick={handleSaveAISettings}>
            Save AI Settings
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
