#!/bin/bash
# ◢◢ mosaic.sh - Arrange images in a grid mosaic (no resolution loss by default)
# Usage: ./mosaic.sh [options] <images... | directory>
# Examples:
#   ./mosaic.sh photos/                        3 cols, cell = size of 1st image
#   ./mosaic.sh -c 4 -o wall.jpg *.jpg         4 cols, JPG output
#   ./mosaic.sh -q photos/                     square cells (largest side of 1st image)
#   ./mosaic.sh -s 800x600 -g 20 photos/       800x600 cells, 20px gap
#   ./mosaic.sh -s 500 -q -b black photos/     500x500 cells, black background
#
# Images are placed in CONTAIN mode: scaled to fit the cell (never cropped),
# centered, with the background color filling the rest.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <images... | directory>

Options:
  -c, --cols N        Number of columns (default: 3; rows are automatic)
  -s, --size WxH      Cell size. Just W keeps the 1st image's aspect ratio
                      (default: size of the 1st image)
  -q, --square        Square cells (side = largest side of 1st image, or W from --size)
  -g, --gap PX        Gap between cells (default: 0)
  -m, --margin PX     Outer margin (default: 0)
  -b, --bg COLOR      Background color, "none" for transparent (default: white)
  -n, --no-upscale    Don't enlarge images smaller than the cell
  -o, --output FILE   Output file (default: mosaic.png)
  -Q, --quality N     JPG/WebP quality (default: 92)
  -h, --help          Show this help
EOF
}

# --- Args ---
COLS=3
SIZE=""
SQUARE=0
GAP=0
MARGIN=0
BG="white"
UPSCALE=1
OUTPUT="mosaic.png"
QUALITY=92
INPUTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--cols)       COLS="${2:?--cols needs a value}"; shift 2 ;;
    -s|--size)       SIZE="${2:?--size needs a value}"; shift 2 ;;
    -q|--square)     SQUARE=1; shift ;;
    -g|--gap)        GAP="${2:?--gap needs a value}"; shift 2 ;;
    -m|--margin)     MARGIN="${2:?--margin needs a value}"; shift 2 ;;
    -b|--bg)         BG="${2:?--bg needs a value}"; shift 2 ;;
    -n|--no-upscale) UPSCALE=0; shift ;;
    -o|--output)     OUTPUT="${2:?--output needs a value}"; shift 2 ;;
    -Q|--quality)    QUALITY="${2:?--quality needs a value}"; shift 2 ;;
    -h|--help)       usage; exit 0 ;;
    --)              shift; while [[ $# -gt 0 ]]; do INPUTS+=("$1"); shift; done ;;
    -*)              echo "❌ Unknown option: $1"; usage; exit 1 ;;
    *)               INPUTS+=("$1"); shift ;;
  esac
done

if [[ ${#INPUTS[@]} -eq 0 ]]; then
  usage
  exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
  echo "❌ Command not found: magick"
  echo "   Install with: brew install imagemagick"
  exit 1
fi

for VAR in COLS GAP MARGIN QUALITY; do
  if [[ ! "${!VAR}" =~ ^[0-9]+$ ]]; then
    echo "❌ Invalid number for $VAR: ${!VAR}"
    exit 1
  fi
done
if (( COLS < 1 )); then
  echo "❌ --cols must be at least 1"
  exit 1
fi
if [[ -n "$SIZE" && ! "$SIZE" =~ ^[0-9]+(x[0-9]+)?$ ]]; then
  echo "❌ Invalid --size: $SIZE (use WxH or W)"
  exit 1
fi

# --- Collect images (directories are expanded, sorted naturally) ---
FILES=()
for IN in "${INPUTS[@]}"; do
  if [[ -d "$IN" ]]; then
    while IFS= read -r F; do
      FILES+=("$F")
    done < <(find "$IN" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
         -o -iname '*.tif' -o -iname '*.tiff' -o -iname '*.gif' -o -iname '*.heic' \
         -o -iname '*.bmp' -o -iname '*.avif' \) | sort -V)
  elif [[ -f "$IN" ]]; then
    FILES+=("$IN")
  else
    echo "❌ Not found: $IN"
    exit 1
  fi
done

# Never include a previous output in the mosaic
IMAGES=()
for F in ${FILES[@]+"${FILES[@]}"}; do
  [[ "$F" -ef "$OUTPUT" ]] || IMAGES+=("$F")
done

COUNT=${#IMAGES[@]}
if (( COUNT == 0 )); then
  echo "❌ No images found"
  exit 1
fi

# --- Cell size (from 1st image unless --size) ---
read -r FIRST_W FIRST_H < <(magick "${IMAGES[0]}[0]" -auto-orient -format '%w %h\n' info:)

if [[ "$SIZE" == *x* ]]; then
  CELL_W="${SIZE%x*}"
  CELL_H="${SIZE#*x}"
elif [[ -n "$SIZE" ]]; then
  CELL_W="$SIZE"
  CELL_H=$(( (SIZE * FIRST_H + FIRST_W / 2) / FIRST_W ))
else
  CELL_W="$FIRST_W"
  CELL_H="$FIRST_H"
fi

if (( SQUARE )); then
  if [[ -z "$SIZE" ]]; then
    CELL_W=$(( FIRST_W > FIRST_H ? FIRST_W : FIRST_H ))
  fi
  CELL_H="$CELL_W"
fi

if (( CELL_W < 1 || CELL_H < 1 )); then
  echo "❌ Invalid cell size: ${CELL_W}x${CELL_H}"
  exit 1
fi

(( COLS > COUNT )) && COLS="$COUNT"
ROWS=$(( (COUNT + COLS - 1) / COLS ))
TOTAL_W=$(( COLS * CELL_W + (COLS - 1) * GAP + 2 * MARGIN ))
TOTAL_H=$(( ROWS * CELL_H + (ROWS - 1) * GAP + 2 * MARGIN ))

echo "◢◢ mosaic.sh"
echo "   Images:  $COUNT"
echo "   Grid:    ${COLS} cols x ${ROWS} rows"
echo "   Cell:    ${CELL_W}x${CELL_H}"
echo "   Output:  $OUTPUT (${TOTAL_W}x${TOTAL_H})"
echo ""

# --- Build ---
# Each cell: contain + center. Every cell carries the gap on its right/bottom,
# and the surplus gap of the last col/row is cropped off at the end.
RESIZE="${CELL_W}x${CELL_H}"
(( UPSCALE )) || RESIZE="${RESIZE}>"
STEP_W=$(( CELL_W + GAP ))
STEP_H=$(( CELL_H + GAP ))

CMD=(magick -background "$BG")
for (( I = 0; I < COUNT; I++ )); do
  (( I % COLS == 0 )) && CMD+=("(")
  CMD+=("(" "${IMAGES[$I]}[0]" -auto-orient -resize "$RESIZE"
        -gravity center -extent "${CELL_W}x${CELL_H}"
        -gravity northwest -extent "${STEP_W}x${STEP_H}" ")")
  if (( (I + 1) % COLS == 0 || I + 1 == COUNT )); then
    CMD+=(+append ")")
  fi
done
CMD+=(-gravity northwest -append
      -extent "$(( TOTAL_W - 2 * MARGIN ))x$(( TOTAL_H - 2 * MARGIN ))"
      -gravity center -extent "${TOTAL_W}x${TOTAL_H}"
      +repage -quality "$QUALITY" "$OUTPUT")

echo "⏳ Building mosaic..."
"${CMD[@]}"
echo "✅ Saved: $OUTPUT"
