#!/bin/bash
#
# Converts all .ts (transport stream) files to .mp4 format in a directory
# Usage: ./ts-to-mp4.sh <input_directory>
# Example: ./ts-to-mp4.sh /path/to/ts/files
# Output: Creates converted_mp4/ and conversion_logs/ subdirectories

# Function to display usage
usage() {
    echo "Usage: $0 <input_directory>"
    echo "Example: $0 /path/to/ts/files"
    exit 1
}

# Check if directory parameter is provided
if [ $# -ne 1 ]; then
    usage
fi

# Get the input directory path
input_dir="$1"

# Check if input directory exists
if [ ! -d "$input_dir" ]; then
    echo "Error: Directory '$input_dir' does not exist."
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it first."
    exit 1
fi

# Create output directory if it doesn't exist
output_dir="${input_dir}/converted_mp4"
mkdir -p "$output_dir"

# Create log directory
log_dir="${input_dir}/conversion_logs"
mkdir -p "$log_dir"

# Counter for processed files
processed=0
failed=0

# Print start message
echo "Starting TS to MP4 conversion..."
echo "Input directory: $input_dir"
echo "Output directory: $output_dir"
echo "Log directory: $log_dir"

# Find all .ts files in input directory and process them
find "$input_dir" -maxdepth 1 -type f -name "*.ts" | while read -r ts_file; do
    # Generate output filename
    filename=$(basename "$ts_file")
    mp4_file="$output_dir/${filename%.ts}.mp4"
    log_file="$log_dir/${filename%.ts}.log"
    
    echo "Converting: $filename -> $(basename "$mp4_file")"
    
    # First, analyze the input file
    echo "Analyzing input file format..."
    ffmpeg -i "$ts_file" 2> "$log_file"
    
    # Convert using ffmpeg with stream copying (no re-encoding)
    # Added -avoid_negative_ts make_zero option and verbose output
    if ffmpeg -i "$ts_file" -c copy -avoid_negative_ts make_zero -y "$mp4_file" 2>> "$log_file"; then
        echo "✓ Successfully converted: $filename"
        ((processed++))
    else
        echo "✗ Failed to convert: $filename"
        echo "Check error log at: $log_file"
        ((failed++))
        
        # Display the error for immediate debugging
        echo "Error details:"
        tail -n 5 "$log_file"
        echo "---"
    fi
done

# Print summary
echo ""
echo "Conversion complete!"
echo "Successfully converted: $processed files"
echo "Failed conversions: $failed files"
echo "Output files are in: $output_dir"
echo "Conversion logs are in: $log_dir"