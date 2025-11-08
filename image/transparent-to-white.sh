#!/bin/bash
#
# Converts transparent PNG background to white (or specified color) and saves as JPG
# Usage: ./transparent-to-white.sh <input.png> [output.jpg] [bg_color]
# Example: ./transparent-to-white.sh logo.png logo.jpg white

if [ -z "$1" ]; then
    echo "Usage: $0 <input.png> [output.jpg] [bg_color]"
    echo "Example: $0 logo.png logo.jpg white"
    echo "Default background: white"
    exit 1
fi

INPUT="$1"
FILENAME="${INPUT%.*}"
OUTPUT="${2:-${FILENAME}-white.jpg}"
BG_COLOR="${3:-white}"

# Convert with background color
convert "$INPUT" -background $BG_COLOR -flatten "$OUTPUT"

echo "Converted $INPUT to $OUTPUT with $BG_COLOR background"
