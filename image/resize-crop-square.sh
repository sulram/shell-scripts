#!/bin/bash
#
# Resizes and crops images to exact square dimensions
# Usage: ./resize-crop-square.sh <size> [input_format] [output_dir]
# Example: ./resize-crop-square.sh 460 jpg cropped
# Default: size=512, format=png, output_dir=cropped

SIZE="${1:-512}"
FORMAT="${2:-png}"
OUTPUT_DIR="${3:-cropped}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Resize and crop to exact square
mogrify -path "$OUTPUT_DIR" -format $FORMAT -resize "${SIZE}x${SIZE}^" -gravity center -crop ${SIZE}x${SIZE}+0+0 +repage *.$FORMAT

echo "Images cropped to ${SIZE}x${SIZE} and saved to $OUTPUT_DIR/"
