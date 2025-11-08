#!/bin/bash
#
# Converts images from one format to another and saves to export directory
# Usage: ./convert-format.sh <source_format> <target_format>
# Example: ./convert-format.sh png jpg

if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_format> <target_format>"
    echo "Example: $0 png jpg"
    exit 1
fi

SOURCE_FORMAT="$1"
TARGET_FORMAT="$2"

# Create export directory if it doesn't exist
mkdir -p export

# Convert images
convert *.$SOURCE_FORMAT -set filename:original %t "export/%[filename:original].$TARGET_FORMAT"

echo "Conversion complete! Files saved to export/"
