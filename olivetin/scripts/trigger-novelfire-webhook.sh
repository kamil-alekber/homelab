#!/bin/bash

# Trigger NovelFire Webhook Script
# Arguments:
#   $1 - Book Name
#   $2 - Chapters URL
#   $3 - Voice
#   $4 - Exaggeration
#   $5 - Speech Pace
#   $6 - Creativity
#   $7 - Output Extension
#   $8 - Workflow URL

BOOK_NAME="$1"
CHAPTERS_URL="$2"
VOICE="$3"
EXAGGERATION="$4"
SPEECH_PACE="$5"
CREATIVITY="$6"
OUTPUT_EXT="$7"
WORKFLOW_URL="$8"

curl --location "$WORKFLOW_URL" \
  --header "Content-Type: application/json" \
  --data "{\"book_name\": \"$BOOK_NAME\", \"chapters_url\": \"$CHAPTERS_URL\", \"voice\": \"$VOICE\", \"exaggeration\": \"$EXAGGERATION\", \"speech_pace\": \"$SPEECH_PACE\", \"creativity\": \"$CREATIVITY\", \"output_ext\": \"$OUTPUT_EXT\"}"
