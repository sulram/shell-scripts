#!/bin/bash
#
# Creates an animated GIF from PNG sequence
# Usage: ./create-gif.sh <delay> [output_name]
# Example: ./create-gif.sh 5 animation.gif
# Delay is in 1/100th of a second (5 = 0.05s per frame)

if [ -z "$1" ]; then
    echo "Usage: $0 <delay> [output_name]"
    echo "Example: $0 5 animation.gif"
    echo "Delay is in 1/100th of a second (5 = 0.05s per frame)"
    exit 1
fi

DELAY="$1"
OUTPUT="${2:-animation.gif}"

# Create animated GIF
convert -delay $DELAY -loop 0 *.png "$OUTPUT"

echo "Animated GIF created: $OUTPUT"
