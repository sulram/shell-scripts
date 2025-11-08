#!/bin/bash
#
# Converts video to optimized animated GIF
# Usage: ./video-to-gif.sh <input_video> <fps> <width> [output.gif]
# Example: ./video-to-gif.sh video.mov 10 640 animation.gif

if [ $# -lt 3 ]; then
    echo "Usage: $0 <input_video> <fps> <width> [output.gif]"
    echo "Example: $0 video.mov 10 640 animation.gif"
    exit 1
fi

INPUT="$1"
FPS="$2"
WIDTH="$3"
FILENAME="${INPUT%.*}"
OUTPUT="${4:-${FILENAME}.gif}"

# Create temporary directory for frames
TEMP_DIR="temp_frames_$$"
mkdir -p "$TEMP_DIR"

echo "Step 1: Extracting frames from video..."
ffmpeg -i "$INPUT" -r $FPS -vf "scale=${WIDTH}:-1:flags=lanczos" -f image2 "$TEMP_DIR/frame-%03d.png"

echo "Step 2: Creating optimized GIF..."
# Calculate delay (1/fps * 100 for ImageMagick format)
DELAY=$((100 / FPS))
convert "$TEMP_DIR"/*.png -delay ${DELAY}x100 -coalesce -layers OptimizeTransparency "$OUTPUT"

# Cleanup
rm -rf "$TEMP_DIR"

echo "GIF created: $OUTPUT"
