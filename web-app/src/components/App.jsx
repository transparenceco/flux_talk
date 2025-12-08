import React, { useState, useEffect, useRef } from 'react';
import { apiService } from '../services/api';
import SettingsModal from './SettingsModal';
import '../styles/App.css';

function App() {
  const [messages, setMessages] = useState([]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [currentMode, setCurrentMode] = useState('local');
  const [showSettings, setShowSettings] = useState(false);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    loadInitialData();
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const loadInitialData = async () => {
    try {
      const [history, modeSetting] = await Promise.all([
        apiService.getChatHistory(),
        apiService.getSetting('ai_mode').catch(() => ({ value: 'local' })),
      ]);
      setMessages(history);
      setCurrentMode(modeSetting.value);
    } catch (err) {
      setError('Failed to load data: ' + err.message);
    }
  };

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!inputMessage.trim() || isLoading) return;

    setIsLoading(true);
    setError(null);

    try {
      await apiService.sendMessage(inputMessage.trim());
      setInputMessage('');
      
      // Reload messages
      const history = await apiService.getChatHistory();
      setMessages(history);
    } catch (err) {
      setError('Failed to send message: ' + err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const formatTime = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const getModeDisplayName = (mode) => {
    const modes = {
      local: 'Local (LM Studio)',
      grok: 'Grok (xAI)',
      openai: 'OpenAI',
    };
    return modes[mode] || mode;
  };

  return (
    <div className="app">
      <header className="header">
        <h1>Flux Talk</h1>
        <div className="header-info">
          <span className="mode-badge">{getModeDisplayName(currentMode)}</span>
          <button className="settings-btn" onClick={() => setShowSettings(true)}>
            ⚙️ Settings
          </button>
        </div>
      </header>

      {error && <div className="error-message">{error}</div>}

      <div className="messages-container">
        {messages.length === 0 && (
          <div className="loading">
            <p>No messages yet. Start a conversation!</p>
          </div>
        )}
        
        {messages.map((message) => (
          <div key={message.id} className={`message ${message.role}`}>
            <div className="message-bubble">
              <div>{message.content}</div>
              <div className="message-meta">
                {formatTime(message.createdAt)}
                {message.role === 'assistant' && ` · ${message.provider}`}
              </div>
            </div>
          </div>
        ))}
        
        {isLoading && (
          <div className="loading">AI is thinking...</div>
        )}
        
        <div ref={messagesEndRef} />
      </div>

      <form className="input-container" onSubmit={handleSendMessage}>
        <input
          type="text"
          className="message-input"
          placeholder="Type a message..."
          value={inputMessage}
          onChange={(e) => setInputMessage(e.target.value)}
          disabled={isLoading}
        />
        <button
          type="submit"
          className="send-btn"
          disabled={isLoading || !inputMessage.trim()}
        >
          {isLoading ? '...' : 'Send'}
        </button>
      </form>

      {showSettings && (
        <SettingsModal
          currentMode={currentMode}
          onClose={() => setShowSettings(false)}
          onModeChange={(mode) => {
            setCurrentMode(mode);
            loadInitialData();
          }}
          onHistoryCleared={() => {
            setMessages([]);
          }}
        />
      )}
    </div>
  );
}

export default App;
