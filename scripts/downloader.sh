#!/bin/bash

###############################################################################
# Universal Video Downloader for Clawdbot/Moltbot
# Downloads videos from 1000+ websites with keyframe extraction
# Version: 2.0.0
###############################################################################

set -euo pipefail

#=============================================================================
# CONFIGURATION
#=============================================================================

# Download directory (CHANGE THIS to your preferred location)
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/media/wdisk/downloads}"

# Keyframe timestamps to extract (in seconds)
# Examples: KEYFRAMES=("10" "30") or KEYFRAMES=("5" "15" "30" "60")
KEYFRAMES=("10" "30")

# Video quality: "best", "worst", "bestvideo+bestaudio"
QUALITY="best"

# Output format: "mp4", "mkv", "best" (keep original)
FORMAT="best"

# Filename template
# Available placeholders: title, id, uploader, ext, etc.
FILENAME_TEMPLATE="%(title)s [%(id)s].%(ext)s"

# Temporary directory for downloads
TEMP_DIR="/tmp/vod-downloader"

# Enable aria2 for faster downloads (requires aria2)
USE_ARIA2=false

# Number of retries for failed downloads
MAX_RETRIES=3

# Timeout for downloads (in seconds)
TIMEOUT=600

# Export mode (set via --export-clips flag)
EXPORT_MODE=false
REVIEW_MODE=false

#=============================================================================
# FUNCTIONS
#=============================================================================

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

log_success() {
    echo "[SUCCESS] $*"
}

# Show usage
show_usage() {
    cat << EOF
Universal Video Downloader v2.0.0

Usage: $0 [OPTIONS] <URL>

Options:
    --export-clips        Export keyframes and metadata to review directory
    --review-mode         Enable agent review workflow (alias for --export-clips)
    --help, -h            Show this help message

Arguments:
    URL                   Video URL to download

Examples:
    $0 https://youtube.com/watch?v=xxx
    $0 --export-clips https://youtube.com/watch?v=xxx
    $0 --review-mode https://youtube.com/watch?v=xxx

Environment Variables:
    DOWNLOAD_DIR          Custom download directory (default: /media/wdisk/downloads)
EOF
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    command -v yt-dlp >/dev/null 2>&1 || missing_deps+=("yt-dlp")
    command -v ffmpeg >/dev/null 2>&1 || missing_deps+=("ffmpeg")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Install with: sudo apt install -y ${missing_deps[*]}"
        return 1
    fi

    return 0
}

# Validate URL
validate_url() {
    local url="$1"

    if [ -z "$url" ]; then
        log_error "No URL provided"
        return 1
    fi

    # Basic URL validation
    if [[ ! "$url" =~ ^https?:// ]]; then
        log_error "Invalid URL format: $url"
        return 1
    fi

    return 0
}

# Check if site is supported
check_site_support() {
    local url="$1"

    log_info "Checking if site is supported..."
    local domain
    domain=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|')

    # Check if yt-dlp supports this site
    if yt-dlp --list-extractors 2>/dev/null | grep -qi "$(echo "$domain" | cut -d'.' -f1)"; then
        log_success "Site supported: $domain"
        return 0
    else
        log_error "Site might not be supported. Run 'yt-dlp --list-extractors' for full list."
        return 1
    fi
}

# Check disk space
check_disk_space() {
    local required_space_mb=500  # Require at least 500MB free
    local available_space_mb
    local check_dir="$DOWNLOAD_DIR"

    # If download directory doesn't exist yet, check parent or root
    if [ ! -d "$check_dir" ]; then
        check_dir=$(dirname "$check_dir")
        if [ ! -d "$check_dir" ]; then
            check_dir="/"
        fi
    fi

    available_space_mb=$(df -BM "$check_dir" 2>/dev/null | tail -1 | awk '{print $4}' | tr -d 'M' | tr -d ' ')

    # If df failed, assume we have enough space
    if [ -z "$available_space_mb" ] || [ "$available_space_mb" -eq 0 ]; then
        log_info "Could not check disk space, continuing anyway..."
        return 0
    fi

    if [ "$available_space_mb" -lt "$required_space_mb" ]; then
        log_error "Insufficient disk space. Available: ${available_space_mb}MB, Required: ${required_space_mb}MB"
        return 1
    fi

    log_info "Disk space check passed: ${available_space_mb}MB available"
    return 0
}

# Create output directory
create_output_dir() {
    if [ ! -d "$DOWNLOAD_DIR" ]; then
        log_info "Creating download directory: $DOWNLOAD_DIR"
        mkdir -p "$DOWNLOAD_DIR"
    fi

    mkdir -p "$TEMP_DIR"
}

# Get video metadata
get_video_info() {
    local url="$1"
    local info_file="$TEMP_DIR/video_info.json"

    log_info "Fetching video metadata..."
    if ! yt-dlp --dump-json "$url" > "$info_file" 2>/dev/null; then
        log_error "Failed to fetch video info"
        return 1
    fi

    # Extract key information
    VIDEO_TITLE=$(jq -r '.title // "Unknown"' "$info_file")
    VIDEO_ID=$(jq -r '.id // "unknown"' "$info_file")
    VIDEO_DURATION=$(jq -r '.duration // 0' "$info_file")
    VIDEO_UPLOADER=$(jq -r '.uploader // "Unknown"' "$info_file")
    VIDEO_VIEW_COUNT=$(jq -r '.view_count // 0' "$info_file")
    VIDEO_UPLOAD_DATE=$(jq -r '.upload_date // "Unknown"' "$info_file")

    log_info "Title: $VIDEO_TITLE"
    log_info "Duration: ${VIDEO_DURATION}s"
    log_info "Uploader: $VIDEO_UPLOADER"

    # Copy info file to output for export mode
    if [ "$EXPORT_MODE" = true ]; then
        cp "$info_file" "$TEMP_DIR/metadata.json"
    fi

    return 0
}

# Download video
download_video() {
    local url="$1"
    local output_file="$DOWNLOAD_DIR/$FILENAME_TEMPLATE"
    local retries=0

    log_info "Starting download..."

    # Build yt-dlp command
    local cmd="yt-dlp"
    cmd+=" -f \"$QUALITY\""

    # Only use --merge-output-format if FORMAT is not "best"
    if [ "$FORMAT" != "best" ]; then
        cmd+=" --merge-output-format \"${FORMAT}\""
    fi

    cmd+=" -o \"$output_file\""
    cmd+=" --write-info-json"
    cmd+=" --write-description"
    cmd+=" --write-thumbnail"
    cmd+=" --no-playlist"

    if [ "$USE_ARIA2" = true ] && command -v aria2c >/dev/null 2>&1; then
        cmd+=" --external-downloader aria2c"
        cmd+=" --external-downloader-args \"-x 16 -k 1M\""
    fi

    # Add cookies if available (for age-restricted content)
    if [ -f "$HOME/.config/yt-dlp/cookies.txt" ]; then
        cmd+=" --cookies $HOME/.config/yt-dlp/cookies.txt"
    fi

    cmd+=" \"$url\""

    # Attempt download with retries
    while [ $retries -lt $MAX_RETRIES ]; do
        if eval "$cmd"; then
            log_success "Download completed successfully"
            return 0
        else
            retries=$((retries + 1))
            if [ $retries -lt $MAX_RETRIES ]; then
                log_info "Retry $retries/$MAX_RETRIES..."
                sleep 5
            fi
        fi
    done

    log_error "Download failed after $MAX_RETRIES attempts"
    return 1
}

# Extract keyframes
extract_keyframes() {
    local video_file="$1"
    local video_name
    video_name=$(basename "$video_file" | sed 's/\.[^.]*$//')

    log_info "Extracting keyframes..."

    # Check video duration
    local duration
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null)
    duration=${duration%.*}  # Round down to integer

    if [ "$duration" -lt 10 ]; then
        log_info "Video too short (${duration}s), skipping keyframe extraction"
        return 0
    fi

    # Extract each keyframe
    for timestamp in "${KEYFRAMES[@]}"; do
        if [ "$duration" -lt "$timestamp" ]; then
            log_info "Timestamp ${timestamp}s exceeds video duration, skipping"
            continue
        fi

        local output_file="${DOWNLOAD_DIR}/${video_name}_${timestamp}s.jpg"
        log_info "Extracting frame at ${timestamp}s..."

        if ffmpeg -ss "${timestamp}" -i "$video_file" -vframes 1 -q:v 2 "$output_file" -y 2>/dev/null; then
            log_success "Extracted: $output_file"
            SCREENSHOTS+=("$output_file")
        else
            log_error "Failed to extract frame at ${timestamp}s"
            continue
        fi
    done

    return 0
}

# Export review package (for agent review workflow)
export_review_package() {
    local video_file="$1"
    local video_name
    video_name=$(basename "$video_file" | sed 's/\.[^.]*$//')

    local review_dir="$DOWNLOAD_DIR/review_${video_name}"
    mkdir -p "$review_dir"

    log_info "Creating review package: $review_dir"

    # Copy video
    cp "$video_file" "$review_dir/"

    # Copy keyframes
    if [ ${#SCREENSHOTS[@]} -gt 0 ]; then
        mkdir -p "$review_dir/keyframes"
        for screenshot in "${SCREENSHOTS[@]}"; do
            cp "$screenshot" "$review_dir/keyframes/"
        done
    fi

    # Copy metadata
    if [ -f "$TEMP_DIR/metadata.json" ]; then
        cp "$TEMP_DIR/metadata.json" "$review_dir/"

        # Create enhanced metadata JSON
        cat > "$review_dir/review_metadata.json" << EOF
{
  "video_title": "$VIDEO_TITLE",
  "video_id": "$VIDEO_ID",
  "video_uploader": "$VIDEO_UPLOADER",
  "duration_seconds": $VIDEO_DURATION,
  "view_count": $VIDEO_VIEW_COUNT,
  "upload_date": "$VIDEO_UPLOAD_DATE",
  "keyframes_extracted": ${#SCREENSHOTS[@]},
  "keyframe_timestamps": [${KEYFRAMES[@]}],
  "download_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "video_file": "$(basename "$video_file")",
  "file_size_mb": "$(du -m "$video_file" | cut -f1)"
}
EOF
    fi

    # Create index.html for quick preview (basic)
    cat > "$review_dir/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Review: $VIDEO_TITLE</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }
        .metadata { background: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .keyframes { display: flex; flex-wrap: wrap; gap: 10px; }
        .keyframe { flex: 1; min-width: 200px; }
        .keyframe img { width: 100%; border-radius: 5px; }
        .keyframe span { display: block; text-align: center; margin-top: 5px; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Video Review: $VIDEO_TITLE</h1>
    <div class="metadata">
        <h2>Metadata</h2>
        <p><strong>Uploader:</strong> $VIDEO_UPLOADER</p>
        <p><strong>Duration:</strong> $VIDEO_DURATION seconds</p>
        <p><strong>Views:</strong> $VIDEO_VIEW_COUNT</p>
        <p><strong>Upload Date:</strong> $VIDEO_UPLOAD_DATE</p>
    </div>
    <h2>Keyframes</h2>
    <div class="keyframes">
EOF

    # Add keyframes to HTML
    for screenshot in "${SCREENSHOTS[@]}"; do
        local filename
        filename=$(basename "$screenshot")
        local timestamp
        timestamp=$(echo "$filename" | grep -oP '\d+(?=s\.jpg)')
        echo "        <div class=\"keyframe\"><img src=\"keyframes/$filename\"><span>${timestamp}s</span></div>" >> "$review_dir/index.html"
    done

    cat >> "$review_dir/index.html" << EOF
    </div>
</body>
</html>
EOF

    log_success "Review package created: $review_dir"
    log_info "  - Video: $(basename "$video_file")"
    log_info "  - Keyframes: ${#SCREENSHOTS[@]}"
    log_info "  - Metadata: review_metadata.json"
    log_info "  - Preview: index.html"

    echo "REVIEW_DIR:$review_dir"
}

# Generate output message
generate_output() {
    local video_file="$1"
    local video_name
    video_name=$(basename "$video_file")

    local file_size
    file_size=$(du -h "$video_file" | cut -f1)

    echo ""
    echo "=================================="
    echo "Download Complete!"
    echo "=================================="
    echo ""
    echo "Video file: $video_name"
    echo "Size: $file_size"
    echo "Location: $DOWNLOAD_DIR"
    echo ""
    echo "Keyframes extracted: ${#SCREENSHOTS[@]}"
    for screenshot in "${SCREENSHOTS[@]}"; do
        echo "  - $(basename "$screenshot")"
    done
    echo ""

    if [ "$EXPORT_MODE" = true ]; then
        echo "Review package: $DOWNLOAD_DIR/review_${video_name}/"
        echo "  Open $DOWNLOAD_DIR/review_${video_name}/index.html for preview"
        echo ""
    fi

    echo "SCREENSHOTS:${SCREENSHOTS[*]}" | tr ' ' '|'
    echo ""
}

# Cleanup
cleanup() {
    log_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

#=============================================================================
# MAIN
#=============================================================================

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --export-clips|--review-mode)
                EXPORT_MODE=true
                REVIEW_MODE=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                URL="$1"
                shift
                ;;
        esac
    done

    # Validate URL
    if [ -z "${URL:-}" ]; then
        log_error "No URL provided"
        show_usage
        exit 1
    fi

    # Initialize
    SCREENSHOTS=()

    # Pre-flight checks
    check_dependencies || exit 1
    validate_url "$URL" || exit 1
    check_disk_space || exit 1
    create_output_dir

    # Get video info
    get_video_info "$URL" || exit 1

    # Download
    download_video "$URL" || exit 1

    # Find downloaded video file (newest mp4 file in download directory)
    VIDEO_FILE=$(find "$DOWNLOAD_DIR" -type f -name "*.mp4" -mmin -5 -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

    # Fallback: if no recent file found, try by ID
    if [ ! -f "$VIDEO_FILE" ]; then
        VIDEO_FILE=$(find "$DOWNLOAD_DIR" -type f -name "*[${VIDEO_ID}].*" 2>/dev/null | head -1)
    fi

    if [ ! -f "$VIDEO_FILE" ]; then
        log_error "Could not find downloaded video file"
        log_error "Tried finding by: recent mp4 files and ID [$VIDEO_ID]"
        exit 1
    fi

    log_info "Found video file: $(basename "$VIDEO_FILE")"

    # Extract keyframes
    extract_keyframes "$VIDEO_FILE"

    # Export review package if requested
    if [ "$EXPORT_MODE" = true ]; then
        export_review_package "$VIDEO_FILE"
    fi

    # Generate output
    generate_output "$VIDEO_FILE"

    # Cleanup
    cleanup

    return 0
}

# Run main function
main "$@"
