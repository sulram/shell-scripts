#!/bin/bash
#
# Resizes images to fit within dimensions with background color padding
# Usage: ./resize-with-background.sh <width> <height> [bg_color] [format]
# Example: ./resize-with-background.sh 1024 768 black png
# Default: bg_color=black, format=png

if [ $# -lt 2 ]; then
    echo "Usage: $0 <width> <height> [bg_color] [format]"
    echo "Example: $0 1024 768 black png"
    echo "Default background: black, format: png"
    exit 1
fi

WIDTH="$1"
HEIGHT="$2"
BG_COLOR="${3:-black}"
FORMAT="${4:-png}"

# Create output directory
mkdir -p fit

# Resize to fit with background
convert *.$FORMAT -background $BG_COLOR -resize ${WIDTH}x${HEIGHT} -gravity center -extent ${WIDTH}x${HEIGHT} "fit/fit.${FORMAT}"

echo "Images resized to fit ${WIDTH}x${HEIGHT} with $BG_COLOR background, saved to fit/"
