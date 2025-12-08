#!/bin/bash

# Flux Talk MVP Demo/Test Script
# This script tests the basic functionality of the Flux Talk backend API

set -e

BASE_URL="http://localhost:8080"
echo "🧪 Flux Talk API Test Suite"
echo "============================"
echo "Base URL: $BASE_URL"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test helper function
test_endpoint() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    
    echo -n "Testing: $test_name... "
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | sed '$d')
    
    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo -e "${GREEN}✓ PASSED${NC} (HTTP $http_code)"
        if [ ! -z "$body" ] && [ "$body" != "null" ]; then
            echo "   Response: $body" | head -c 100
            echo ""
        fi
    else
        echo -e "${RED}✗ FAILED${NC} (HTTP $http_code)"
        echo "   Response: $body"
    fi
    echo ""
}

echo "Step 1: Health Check"
echo "--------------------"
test_endpoint "Health check" "GET" "/health"

echo "Step 2: Settings"
echo "----------------"
test_endpoint "Get all settings" "GET" "/api/settings"
test_endpoint "Get ai_mode setting" "GET" "/api/settings/ai_mode"
test_endpoint "Set ai_mode to local" "POST" "/api/settings" '{"key":"ai_mode","value":"local"}'

echo "Step 3: Chat History (Initial)"
echo "-------------------------------"
test_endpoint "Get chat history (should be empty)" "GET" "/api/chat/history"

echo "Step 4: Vector Database"
echo "-----------------------"
test_endpoint "Add knowledge to vector DB #1" "POST" "/api/vector/add" \
    '{"content":"Vapor is a web framework for Swift","metadata":{"topic":"swift"}}'
    
test_endpoint "Add knowledge to vector DB #2" "POST" "/api/vector/add" \
    '{"content":"SwiftUI is a declarative UI framework","metadata":{"topic":"swift"}}'
    
test_endpoint "Search vector DB" "POST" "/api/vector/search" \
    '{"query":"What is Vapor?","limit":2}'

echo "Step 5: Chat Functionality"
echo "---------------------------"
echo -e "${YELLOW}Note: This will only work if LM Studio is running on localhost:1234${NC}"
echo ""

test_endpoint "Send chat message" "POST" "/api/chat" \
    '{"message":"Hello! What is 2+2?","useContext":false}'
    
echo "Waiting 2 seconds for response..."
sleep 2

test_endpoint "Get chat history (should have messages)" "GET" "/api/chat/history"

echo "Step 6: Context-Enhanced Chat"
echo "------------------------------"
test_endpoint "Send message with context" "POST" "/api/chat" \
    '{"message":"Tell me about Vapor","useContext":true}'

echo "Step 7: Mode Switching"
echo "----------------------"
test_endpoint "Switch to grok mode" "POST" "/api/settings" '{"key":"ai_mode","value":"grok"}'
test_endpoint "Verify mode changed" "GET" "/api/settings/ai_mode"
test_endpoint "Switch back to local mode" "POST" "/api/settings" '{"key":"ai_mode","value":"local"}'

echo "Step 8: Cleanup"
echo "---------------"
test_endpoint "Clear chat history" "DELETE" "/api/chat/history"
test_endpoint "Verify history cleared" "GET" "/api/chat/history"

echo ""
echo "============================"
echo "✅ Test suite completed!"
echo ""
echo "Notes:"
echo "- Chat tests will fail if LM Studio is not running on localhost:1234"
echo "- Vector DB tests may fall back to simple embeddings if Chroma is not running"
echo "- To test with actual AI responses, start LM Studio with a loaded model"
echo ""
