#!/bin/bash
#
# Fixes filenames containing broken Unicode characters (e.g., #U00e1 → á)
# Usage: ./fix_filenames.sh [path]
# Default path: /home/user/apps/wordpress/wp-content/uploads/

# Get path from argument or use default
TARGET_PATH="${1:-/home/user/apps/wordpress/wp-content/uploads/}"

# Find all directories under the specified path
directories=$(find "$TARGET_PATH" -type d)

# Loop over each directory
echo "$directories" | while IFS= read -r directory; do
    # Change to the directory
    cd "$directory" || continue

    # Use a while loop with read to handle filenames with spaces
    ls | grep -E '#U00[0-9a-fA-F]{2}' | while IFS= read -r broken_filename; do
        # Replace the broken parts with the correct characters
        corrected_filename=$(echo "$broken_filename" | \
        sed 's/#U00c1/Á/g' | \
        sed 's/#U00e1/á/g' | \
        sed 's/#U00c9/É/g' | \
        sed 's/#U00e9/é/g' | \
        sed 's/#U00cd/Í/g' | \
        sed 's/#U00ed/í/g' | \
        sed 's/#U00d3/Ó/g' | \
        sed 's/#U00f3/ó/g' | \
        sed 's/#U00da/Ú/g' | \
        sed 's/#U00fa/ú/g' | \
        sed 's/#U00c2/Â/g' | \
        sed 's/#U00e2/â/g' | \
        sed 's/#U00ca/Ê/g' | \
        sed 's/#U00ea/ê/g' | \
        sed 's/#U00ce/Î/g' | \
        sed 's/#U00ee/î/g' | \
        sed 's/#U00d4/Ô/g' | \
        sed 's/#U00f4/ô/g' | \
        sed 's/#U00db/Û/g' | \
        sed 's/#U00fb/û/g' | \
        sed 's/#U00c3/Ã/g' | \
        sed 's/#U00e3/ã/g' | \
        sed 's/#U00d5/Õ/g' | \
        sed 's/#U00f5/õ/g' | \
        sed 's/#U00c7/Ç/g' | \
        sed 's/#U00e7/ç/g')

        # Rename the file
        mv "$broken_filename" "$corrected_filename"
    done
done
