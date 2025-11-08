#!/bin/bash
#
# Resizes images to specified width with quality and DPI settings
# Usage: ./resize-images.sh <width> <quality> [input_format]
# Example: ./resize-images.sh 1600 70 jpg
# Default input format: jpg

WIDTH="${1:-1600}"
QUALITY="${2:-70}"
FORMAT="${3:-jpg}"

if [ -z "$1" ]; then
    echo "Usage: $0 <width> <quality> [input_format]"
    echo "Example: $0 1600 70 jpg"
    echo "Defaults: width=1600, quality=70, format=jpg"
    exit 1
fi

# Create export directory
mkdir -p resized

# Resize images
convert *.$FORMAT -set filename:original %t -resize $WIDTH -quality ${QUALITY}% -depth 72 -units pixelsperinch "resized/resized_%[filename:original].$FORMAT"

echo "Resize complete! Files saved to resized/"
