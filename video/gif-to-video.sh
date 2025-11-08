#!/bin/bash
#
# Converts animated GIF to video format
# Usage: ./gif-to-video.sh <input.gif> [output.mp4]
# Example: ./gif-to-video.sh animation.gif output.mp4

if [ -z "$1" ]; then
    echo "Usage: $0 <input.gif> [output.mp4]"
    echo "Example: $0 animation.gif output.mp4"
    exit 1
fi

INPUT="$1"
FILENAME="${INPUT%.*}"
OUTPUT="${2:-${FILENAME}.mp4}"

# Create temporary directory for frames
TEMP_DIR="temp_frames_$$"
mkdir -p "$TEMP_DIR"

echo "Step 1: Extracting GIF frames..."
convert "$INPUT" -coalesce "$TEMP_DIR/frame-%d.png"

echo "Step 2: Converting to video..."
ffmpeg -f image2 -i "$TEMP_DIR/frame-%d.png" -c:v libx264 -pix_fmt yuv420p -vb 20M "$OUTPUT"

# Cleanup
rm -rf "$TEMP_DIR"

echo "Video created: $OUTPUT"
