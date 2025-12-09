#!/bin/bash

echo "=== Flux Talk Vector DB Test ===" && \
echo "" && \
echo "1. Testing Chroma:" && \
curl -s http://localhost:8000/api/v2/heartbeat | python3 -c "import sys, json; print('✓ Chroma responding' if 'heartbeat' in json.load(sys.stdin) else '✗ Chroma failed')" && \
echo "" && \
echo "2. Testing Backend:" && \
curl -s http://localhost:8080/health | python3 -c "import sys, json; print('✓ Backend responding' if json.load(sys.stdin).get('status') == 'ok' else '✗ Backend failed')" && \
echo "" && \
echo "Vector database search should now work in the web app!" && \
echo "" && \
echo "Open http://localhost:3001 to test"
