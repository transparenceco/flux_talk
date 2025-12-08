const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

export const apiService = {
  async sendMessage(message, useContext = true) {
    const response = await fetch(`${API_BASE_URL}/api/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message, useContext }),
    });
    
    if (!response.ok) {
      throw new Error('Failed to send message');
    }
    
    return response.json();
  },

  async getChatHistory() {
    const response = await fetch(`${API_BASE_URL}/api/chat/history`);
    
    if (!response.ok) {
      throw new Error('Failed to fetch chat history');
    }
    
    const data = await response.json();
    return data.messages;
  },

  async clearChatHistory() {
    const response = await fetch(`${API_BASE_URL}/api/chat/history`, {
      method: 'DELETE',
    });
    
    if (!response.ok) {
      throw new Error('Failed to clear chat history');
    }
  },

  async getSettings() {
    const response = await fetch(`${API_BASE_URL}/api/settings`);
    
    if (!response.ok) {
      throw new Error('Failed to fetch settings');
    }
    
    return response.json();
  },

  async getSetting(key) {
    const response = await fetch(`${API_BASE_URL}/api/settings/${key}`);
    
    if (!response.ok) {
      throw new Error('Failed to fetch setting');
    }
    
    return response.json();
  },

  async setSetting(key, value) {
    const response = await fetch(`${API_BASE_URL}/api/settings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ key, value }),
    });
    
    if (!response.ok) {
      throw new Error('Failed to set setting');
    }
    
    return response.json();
  },

  async addVectorContent(content, metadata) {
    const response = await fetch(`${API_BASE_URL}/api/vector/add`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ content, metadata }),
    });
    
    if (!response.ok) {
      throw new Error('Failed to add vector content');
    }
  },

  async searchVectorContent(query, limit = 5) {
    const response = await fetch(`${API_BASE_URL}/api/vector/search`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query, limit }),
    });
    
    if (!response.ok) {
      throw new Error('Failed to search vector content');
    }
    
    return response.json();
  },
};
