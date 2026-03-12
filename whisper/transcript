#!/bin/bash
# ◢◢ transcript.sh - Split & transcribe audio with whisper-cpp
# Usage: ./transcript.sh <audio_file> [language] [chunk_seconds]
# Examples:
#   ./transcript.sh audio.m4a
#   ./transcript.sh audio.m4a pt
#   ./transcript.sh audio.m4a pt 300

set -euo pipefail

# --- Config ---
MODEL="${WHISPER_MODEL:-$HOME/dev/models/whisper/ggml-large-v3-turbo-q5_0.bin}"
VAD_MODEL="${WHISPER_VAD_MODEL:-$HOME/dev/models/whisper/ggml-silero-v6.2.0.bin}"
THREADS="${WHISPER_THREADS:-4}"

# --- Args ---
INPUT="${1:?Usage: ./transcript.sh <audio_file> [language] [chunk_seconds]}"
LANG="${2:-auto}"
CHUNK_SECS="${3:-600}"  # 10 min default

if [[ ! -f "$INPUT" ]]; then
  echo "❌ File not found: $INPUT"
  exit 1
fi

if [[ ! -f "$MODEL" ]]; then
  echo "❌ Model not found: $MODEL"
  echo "   Download with: curl -L -o $MODEL 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin'"
  exit 1
fi

# --- Setup ---
BASENAME=$(basename "$INPUT" | sed 's/\.[^.]*$//')
WORKDIR="${BASENAME}_whisper"
mkdir -p "$WORKDIR"

echo "◢◢ transcript.sh"
echo "   File:     $INPUT"
echo "   Language: $LANG"
echo "   Chunks:   ${CHUNK_SECS}s"
echo "   Output:   $WORKDIR/"
echo ""

# --- Step 1: Convert to WAV 16kHz ---
echo "⏳ Converting to WAV 16kHz..."
WAV_FILE="$WORKDIR/${BASENAME}.wav"
ffmpeg -y -i "$INPUT" -ar 16000 -ac 1 -c:a pcm_s16le "$WAV_FILE" 2>/dev/null
echo "✅ WAV generated"

# --- Step 2: Get duration ---
DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$WAV_FILE" | cut -d. -f1)
echo "   Duration: ${DURATION}s (~$(( DURATION / 60 ))min)"
echo ""

# --- Step 3: Split if needed ---
if (( DURATION > CHUNK_SECS + 30 )); then
  echo "⏳ Splitting into ${CHUNK_SECS}s chunks..."
  ffmpeg -y -i "$WAV_FILE" \
    -f segment \
    -segment_time "$CHUNK_SECS" \
    -c copy \
    "$WORKDIR/chunk_%03d.wav" 2>/dev/null

  CHUNKS=("$WORKDIR"/chunk_*.wav)
  echo "✅ ${#CHUNKS[@]} chunks created"
else
  CHUNKS=("$WAV_FILE")
  echo "ℹ️  Short audio, no splitting needed"
fi
echo ""

# --- Step 4: Transcribe each chunk ---
LANG_FLAG=""
if [[ "$LANG" != "auto" ]]; then
  LANG_FLAG="--language $LANG"
fi

VAD_FLAG=""
if [[ -f "$VAD_MODEL" ]]; then
  VAD_FLAG="--vad -vm $VAD_MODEL"
  echo "ℹ️  VAD enabled (Silero)"
fi

TOTAL=${#CHUNKS[@]}
COUNTER=0
FINAL_OUTPUT="$WORKDIR/${BASENAME}_transcript.txt"
> "$FINAL_OUTPUT"

for CHUNK in "${CHUNKS[@]}"; do
  COUNTER=$((COUNTER + 1))
  CHUNK_NAME=$(basename "$CHUNK" .wav)
  echo ""
  echo "⏳ [$COUNTER/$TOTAL] Transcribing $CHUNK_NAME..."

  whisper-cli \
    --model "$MODEL" \
    $LANG_FLAG \
    $VAD_FLAG \
    --threads "$THREADS" \
    --max-context 0 \
    --entropy-thold 2.4 \
    -nt \
    --output-txt \
    --file "$CHUNK" \
    --output-file "$WORKDIR/$CHUNK_NAME" 2>/dev/null

  if [[ -f "$WORKDIR/${CHUNK_NAME}.txt" ]]; then
    # Add separator between chunks
    if (( COUNTER > 1 )); then
      echo "" >> "$FINAL_OUTPUT"
    fi
    cat "$WORKDIR/${CHUNK_NAME}.txt" >> "$FINAL_OUTPUT"
    echo "✅ $CHUNK_NAME ok"
  else
    echo "⚠️  $CHUNK_NAME failed"
  fi
done

# --- Step 5: Cleanup intermediate files ---
echo ""
echo "🧹 Cleaning up intermediate files..."
rm -f "$WORKDIR"/chunk_*.wav "$WORKDIR"/chunk_*.txt "$WAV_FILE"

# --- Done ---
WORD_COUNT=$(wc -w < "$FINAL_OUTPUT" | tr -d ' ')
echo ""
echo "════════════════════════════════════════"
echo "✅ Transcription complete!"
echo "   File:  $FINAL_OUTPUT"
echo "   Words: $WORD_COUNT"
echo "════════════════════════════════════════"
