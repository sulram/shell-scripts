#!/bin/bash
#
# Creates MP4 video from PNG image sequence
# Usage: ./png-sequence-to-video.sh <input_fps> <output_fps> <pattern> [output.mp4]
# Example: ./png-sequence-to-video.sh 8 30 "frame-%06d.png" output.mp4
# Pattern uses printf format: %06d = 6-digit number with leading zeros

if [ $# -lt 3 ]; then
    echo "Usage: $0 <input_fps> <output_fps> <pattern> [output.mp4]"
    echo "Example: $0 8 30 'frame-%06d.png' output.mp4"
    echo "Pattern examples:"
    echo "  frame-%06d.png  (frame-000001.png, frame-000002.png, ...)"
    echo "  img-%04d.png    (img-0001.png, img-0002.png, ...)"
    exit 1
fi

INPUT_FPS="$1"
OUTPUT_FPS="$2"
PATTERN="$3"
OUTPUT="${4:-output.mp4}"

# Create video from PNG sequence
ffmpeg -r $INPUT_FPS -i "$PATTERN" -c:v libx264 -vf fps=$OUTPUT_FPS -pix_fmt yuv420p "$OUTPUT"

echo "Video created: $OUTPUT (${OUTPUT_FPS} fps)"
