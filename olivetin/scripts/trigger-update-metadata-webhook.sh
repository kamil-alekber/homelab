#!/bin/bash

# Arguments
BOOK_ID="$1"
METADATA_URL="$2"

# Execute the webhook
curl --location "http://192.168.8.100:5678/webhook/update-metadata" \
  --header "Content-Type: application/json" \
  --data "{\"book_id\": \"$BOOK_ID\", \"metadata_url\": \"$METADATA_URL\"}"
