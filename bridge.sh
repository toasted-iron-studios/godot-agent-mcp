#!/bin/bash
# mcp-http-bridge.sh
HTTP_ENDPOINT="http://localhost:8080"

while IFS= read -r line; do
    echo "$line" | curl -s -X POST "$HTTP_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d @-
done