#!/bin/bash
#
# Adds a prefix to MP3 title metadata for all files in current directory
# Usage: ./retitle_mp3.sh <prefix>
# Example: ./retitle_mp3.sh melnyks_

# Check if a prefix was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <prefix>"
    echo "Example: $0 melnyks_"
    exit 1
fi

PREFIX="$1"

for file in *.mp3; do
    # Get filename without extension
    basename="${file%.mp3}"
    # Define the title with the prefix
    title="${PREFIX}${basename}"

    echo "Changing title of '$file' to '$title'"

    # Set the MP3 title metadata as the filename with prefix
    ffmpeg -i "$file" -metadata title="$title" -codec copy "temp_$file" -hide_banner -loglevel error

    # Move the temporary file to replace the original
    mv "temp_$file" "$file"
done

echo "Process completed!"