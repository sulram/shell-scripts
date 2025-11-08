#!/bin/bash
#
# Converts video to Apple ProRes format (with optional alpha channel)
# Usage: ./convert-prores.sh <input_video> [profile]
# Example: ./convert-prores.sh input.mp4 standard
# Profiles: proxy, lt, standard, hq, 4444 (4444 includes alpha channel)

if [ -z "$1" ]; then
    echo "Usage: $0 <input_video> [profile]"
    echo "Example: $0 input.mp4 standard"
    echo "Profiles:"
    echo "  proxy    - ProRes Proxy (lowest quality, smallest size)"
    echo "  lt       - ProRes LT (light)"
    echo "  standard - ProRes 422 (default)"
    echo "  hq       - ProRes 422 HQ"
    echo "  4444     - ProRes 4444 with alpha channel"
    exit 1
fi

INPUT="$1"
PROFILE="${2:-standard}"
FILENAME="${INPUT%.*}"

case "$PROFILE" in
    proxy)
        OUTPUT="${FILENAME}-prores-proxy.mov"
        ffmpeg -i "$INPUT" -c:v prores -profile:v 0 "$OUTPUT"
        ;;
    lt)
        OUTPUT="${FILENAME}-prores-lt.mov"
        ffmpeg -i "$INPUT" -c:v prores -profile:v 1 "$OUTPUT"
        ;;
    standard)
        OUTPUT="${FILENAME}-prores.mov"
        ffmpeg -i "$INPUT" -c:v prores -profile:v 2 "$OUTPUT"
        ;;
    hq)
        OUTPUT="${FILENAME}-prores-hq.mov"
        ffmpeg -i "$INPUT" -c:v prores -profile:v 3 "$OUTPUT"
        ;;
    4444)
        OUTPUT="${FILENAME}-prores-4444-alpha.mov"
        ffmpeg -i "$INPUT" -vcodec prores_ks -pix_fmt yuva444p10le -alpha_bits 16 -profile:v 4444 -f mov "$OUTPUT"
        ;;
    *)
        echo "Invalid profile: $PROFILE"
        echo "Valid profiles: proxy, lt, standard, hq, 4444"
        exit 1
        ;;
esac

echo "ProRes conversion complete: $OUTPUT"
