# Configuration Guide

This guide explains all configuration options for the Universal Video Downloader skill.

## Table of Contents

1. [Basic Configuration](#basic-configuration)
2. [Download Directory](#download-directory)
3. [Keyframe Extraction](#keyframe-extraction)
4. [Video Quality](#video-quality)
5. [Output Format](#output-format)
6. [Filename Templates](#filename-templates)
7. [Advanced Options](#advanced-options)
8. [Performance Tuning](#performance-tuning)

## Basic Configuration

All configuration is done in `scripts/downloader.sh`.

Open the file in your editor:
```bash
nano scripts/downloader.sh
```

## Download Directory

### Default
```bash
DOWNLOAD_DIR="/media/wdisk/downloads"
```

### Examples

#### Adult Content
```bash
DOWNLOAD_DIR="/media/wdisk/18+"
```

#### Home Directory
```bash
DOWNLOAD_DIR="$HOME/downloads"
```

#### External Drive
```bash
DOWNLOAD_DIR="/mnt/usb/videos"
```

#### Network Storage
```bash
DOWNLOAD_DIR="/mnt/nas/shared/videos"
```

### Automatic Categorization (Coming Soon)

```bash
# Enable automatic categorization by site
AUTO_CATEGORIZE=true

# Results in:
# ${DOWNLOAD_DIR}/pornhub/Video Title [id].mp4
# ${DOWNLOAD_DIR}/youtube/Video Title [id].mp4
# ${DOWNLOAD_DIR}/twitter/Video Title [id].mp4
```

## Keyframe Extraction

### Default (10s and 30s)
```bash
KEYFRAMES=("10" "30")
```

### Examples

#### Single Frame
```bash
KEYFRAMES=("15")
```

#### Multiple Frames
```bash
KEYFRAMES=("5" "15" "30" "60" "120")
```

#### Disabled
```bash
KEYFRAMES=()
```

#### For Long Videos
```bash
# Extract frames at 5%, 25%, 50%, 75%, 95% (coming soon)
KEYFRAMES_AUTO=true
```

### Keyframe Quality

To change screenshot quality, modify the ffmpeg command:
```bash
# In extract_keyframes() function
ffmpeg -ss "${timestamp}" -i "$video_file" -vframes 1 -q:v 2 "$output_file" -y
#                                                          ^^^^
#                                                          1 = highest, 31 = lowest
```

## Video Quality

### Best Available (Default)
```bash
QUALITY="best"
```
Downloads the best quality available (video + audio combined)

### Best Video + Audio
```bash
QUALITY="bestvideo+bestaudio"
```
Downloads best video and audio separately, then merges. Higher quality but slower.

### Worst Quality
```bash
QUALITY="worst"
```
Downloads lowest quality (faster, smaller file)

### Specific Resolution
```bash
QUALITY="bestvideo[height<=1080]+bestaudio"
```
Best 1080p video + best audio

### More Examples
```bash
# 720p maximum
QUALITY="bestvideo[height<=720]+bestaudio"

# 480p maximum (faster for slow connections)
QUALITY="bestvideo[height<=480]+bestaudio"

# Audio only (for music videos)
QUALITY="bestaudio"
```

## Output Format

### Keep Original (Default)
```bash
FORMAT="best"
```

### Force MP4
```bash
FORMAT="mp4"
```

### Force MKV
```bash
FORMAT="mkv"
```

### WebM
```bash
FORMAT="webm"
```

## Filename Templates

### Default
```bash
FILENAME_TEMPLATE="%(title)s [%(id)s].%(ext)s"
```

### Available Placeholders

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `%(title)s` | Video title | "My Video Title" |
| `%(id)s` | Video ID | "ph6123456789" |
| `%(uploader)s` | Uploader name | "Channel Name" |
| `%(ext)s` | File extension | "mp4" |
| `%(duration)s` | Duration in seconds | "530" |
| `%(view_count)s` | View count | "12345" |
| `%(like_count)s` | Like count | "1234" |
| `%(upload_date)s` | Upload date | "20230130" |
| `%(playlist_title)s` | Playlist name | "My Playlist" |
| `%(playlist_index)s` | Position in playlist | "1" |

### Examples

#### Uploader + Title
```bash
FILENAME_TEMPLATE="%(uploader)s - %(title)s [%(id)s].%(ext)s"
# Result: Channel Name - Video Title [ph6123456789].mp4
```

#### Date + Title
```bash
FILENAME_TEMPLATE="%(upload_date)s - %(title)s.%(ext)s"
# Result: 20230130 - Video Title.mp4
```

#### With Duration
```bash
FILENAME_TEMPLATE="[%(duration)ss] %(title)s.%(ext)s"
# Result: [530s] Video Title.mp4
```

#### Sanitized Filename
```bash
FILENAME_TEMPLATE="%(title)s.%(ext)s"
# Result: Video_Title.mp4 (special chars removed)
```

## Advanced Options

### Retry Settings
```bash
# Number of retries for failed downloads
MAX_RETRIES=3

# Timeout for downloads (in seconds)
TIMEOUT=600
```

### Concurrent Downloads (Coming Soon)
```bash
# Maximum concurrent downloads
MAX_CONCURRENT=3
```

### User Agent
```bash
# Custom user agent (if sites block you)
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
```

### Proxy Support
```bash
# HTTP/HTTPS proxy
export HTTP_PROXY="http://proxy.example.com:8080"
export HTTPS_PROXY="http://proxy.example.com:8080"

# SOCKS5 proxy
export ALL_PROXY="socks5://127.0.0.1:1080"
```

### Cookies (for Premium Content)
```bash
# Use cookies for premium sites
# Export cookies from browser using:
# https://chrome.google.com/webstore/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc

COOKIES_FILE="/path/to/cookies.txt"
```

### Authentication
```bash
# For sites requiring login
USERNAME="your_username"
PASSWORD="your_password"
```

### Subtitle Download
```bash
# Download subtitles (if available)
WRITE_SUBS=true
SUBS_LANGS="en,zh-Hans,zh-Hant"  # English, Simplified Chinese, Traditional Chinese
```

### Metadata
```bash
# Write metadata files
WRITE_INFO_JSON=true      # Write video info JSON
WRITE_DESCRIPTION=true    # Write description
WRITE_THUMBNAIL=true      # Write thumbnail
```

## Performance Tuning

### Enable aria2 (Faster Downloads)
```bash
USE_ARIA2=true
```

Requires aria2 installation:
```bash
sudo apt install -y aria2
```

Benefits:
- Up to 16 concurrent connections
- Significantly faster for large files
- Better retry mechanism

### aria2 Settings
```bash
# In yt-dlp command
--external-downloader aria2c
--external-downloader-args "-x 16 -k 1M"
```

Options:
- `-x 16`: 16 connections per file
- `-k 1M`: Split file into 1MB chunks
- `-s 16`: Split into 16 segments

### Buffer Size
```bash
# Increase buffer for faster downloads (in yt-dlp command)
--buffer-size 16K
```

### Throttle Speed
```bash
# Limit download speed (useful for slow connections)
--limit-rate 1M  # 1 MB/s
```

### Reduce CPU Usage
```bash
# Skip keyframe extraction
KEYFRAMES=()

# Use lower quality (faster processing)
QUALITY="worst"

# Keep original format (no conversion)
FORMAT="best"
```

## Disk Space Management

### Minimum Free Space
```bash
# Check disk space before download
MIN_FREE_SPACE=500  # MB
```

### Cleanup After Download
```bash
# Remove temporary files
CLEANUP_TEMP=true

# Remove metadata files (keep only video)
CLEANUP_METADATA=true
```

### Auto-Delete Old Files (Coming Soon)
```bash
# Delete downloads older than X days
AUTO_DELETE_DAYS=30

# Delete when disk space is low
DELETE_WHEN_FULL=true
MIN_FREE_PERCENT=10
```

## Logging

### Enable Verbose Logging
```bash
# In yt-dlp command
--verbose
```

### Log to File
```bash
LOG_FILE="/var/log/vod-downloader.log"

# In download function
yt-dlp ... 2>&1 | tee -a "$LOG_FILE"
```

### Error Logging
```bash
# Log errors only
ERROR_LOG="/var/log/vod-downloader-errors.log"
```

## Integration with Other Skills

### + Video Frames Skill
After download, automatically extract more frames:
```bash
# Trigger video-frames skill
if [ -x /root/clawd/skills/video-frames/extract.sh ]; then
    /root/clawd/skills/video-frames/extract.sh "$VIDEO_FILE"
fi
```

### + Notion Skill
Log downloads to Notion:
```bash
# Create Notion page with metadata
if [ -x /root/clawd/skills/notion/log.sh ]; then
    /root/clawd/skills/notion/log.sh "$VIDEO_FILE"
fi
```

### + Telegram/Discord
Send notifications:
```bash
# Send download progress
# Send completion notification
# Send keyframe previews
```

## Testing Configuration

### Test Without Downloading
```bash
yt-dlp --skip-download "URL"
```

### Test with Sample URL
```bash
bash scripts/downloader.sh "https://www.pornhub.com/view_video.php?viewkey=ph6123456789"
```

### Dry Run
```bash
# See what would happen without downloading
yt-dlp --print-to-file "title: %(title)s\nid: %(id)s\n" -
```

## Troubleshooting

### Download Fails

1. **Update yt-dlp**
   ```bash
   pip install --upgrade yt-dlp
   ```

2. **Check site support**
   ```bash
   yt-dlp --list-extractors | grep pornhub
   ```

3. **Try different quality**
   ```bash
   QUALITY="worst"
   ```

### Keyframe Extraction Fails

1. **Check ffmpeg**
   ```bash
   ffmpeg -version
   ```

2. **Verify video duration**
   ```bash
   ffprobe "$VIDEO_FILE"
   ```

3. **Adjust timestamps**
   ```bash
   KEYFRAMES=("5" "10")  # Earlier timestamps
   ```

### Permission Errors

```bash
# Fix directory permissions
sudo chown -R $USER:$USER "$DOWNLOAD_DIR"
chmod -R 755 "$DOWNLOAD_DIR"
```

## Example Configurations

### Minimal (Fast & Simple)
```bash
DOWNLOAD_DIR="$HOME/downloads"
KEYFRAMES=()
QUALITY="worst"
FORMAT="best"
```

### Balanced (Default)
```bash
DOWNLOAD_DIR="/media/wdisk/downloads"
KEYFRAMES=("10" "30")
QUALITY="best"
FORMAT="best"
```

### Maximum Quality
```bash
DOWNLOAD_DIR="/media/wdisk/downloads"
KEYFRAMES=("5" "15" "30" "60" "120")
QUALITY="bestvideo+bestaudio"
FORMAT="mp4"
USE_ARIA2=true
```

### Archival (Metadata Preserved)
```bash
DOWNLOAD_DIR="/media/archives/videos"
KEYFRAMES=("30")
QUALITY="bestvideo+bestaudio"
FORMAT="mkv"
WRITE_INFO_JSON=true
WRITE_DESCRIPTION=true
WRITE_THUMBNAIL=true
```

---

**Last Updated:** 2026-01-30
**Skill Version:** 1.0.0
