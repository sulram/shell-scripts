#!/bin/bash
#
# Speeds up or slows down video playback
# Usage: ./time-stretch.sh <input_video> <speed_factor> [output_video]
# Example: ./time-stretch.sh input.mp4 2 output.mp4
# Speed factor: 2 = 2x faster, 0.5 = 2x slower

if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_video> <speed_factor> [output_video]"
    echo "Example: $0 input.mp4 2 output.mp4"
    echo "Speed factor: 2 = 2x faster, 0.5 = 2x slower"
    exit 1
fi

INPUT="$1"
SPEED="$2"
FILENAME="${INPUT%.*}"
OUTPUT="${3:-${FILENAME}-${SPEED}x.mp4}"

# Apply time stretch
ffmpeg -i "$INPUT" -filter_complex "setpts=PTS/$SPEED" "$OUTPUT"

echo "Time-stretched video created: $OUTPUT (${SPEED}x speed)"
