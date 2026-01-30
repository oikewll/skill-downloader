# Usage Examples

This document provides practical examples of using the Universal Video Downloader skill.

## Basic Usage

### Download a Single Video

Send this URL to your bot:
```
https://www.pornhub.com/view_video.php?viewkey=ph6123456789
```

**What happens:**
1. Bot detects the URL
2. Downloads the video
3. Extracts keyframes at 10s and 30s
4. Sends screenshots to your chat
5. Notifies you when complete

## Examples by Site

### PornHub

**Regular video:**
```
https://www.pornhub.com/view_video.php?viewkey=ph6123456789
```

**Premium video (requires authentication):**
```
https://www.pornhub.com/premium/view_video.php?viewkey=ph6123456789
```

**Playlist:**
```
https://www.pornhub.com/playlist/123456
```

### XVideos

**Single video:**
```
https://www.xvideos.com/video.1234567/video_title
```

### YouTube

**Single video:**
```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
```

**Playlist:**
```
https://www.youtube.com/playlist?list=PLxxxxxxxxxxxxxxxx
```

**Entire channel:**
```
https://www.youtube.com/@ChannelName
```

**Short video:**
```
https://youtube.com/shorts/xxxxxxxxx
```

### Twitter/X

**Video tweet:**
```
https://twitter.com/user/status/123456789
```

### Instagram

**Post with video:**
```
https://www.instagram.com/p/xxxxxxxxx/
```

**Reel:**
```
https://www.instagram.com/reel/xxxxxxxxx/
```

**Story (requires authentication):**
```
https://www.instagram.com/stories/username/123456789/
```

### TikTok

**Single video:**
```
https://www.tiktok.com/@username/video/123456789
```

**User profile (all videos):**
```
https://www.tiktok.com/@username
```

### Reddit

**Video post:**
```
https://reddit.com/r/subreddit/comments/xxxxxx/video_title/
```

### Twitch

**Clip:**
```
https://clips.twitch.tv/ExampleClipName
```

**VOD:**
```
https://www.twitch.tv/videos/123456789
```

### Facebook

**Public video:**
```
https://www.facebook.com/watch?v=123456789
```

## Advanced Usage

### Resume Interrupted Download

If download was interrupted, just send the same URL again:
```
https://www.pornhub.com/view_video.php?viewkey=ph6123456789
```

The skill will automatically resume from where it left off.

### Download Specific Quality

**Edit `scripts/downloader.sh`:**
```bash
# Force 720p maximum
QUALITY="bestvideo[height<=720]+bestaudio"

# Force 480p (faster for slow connections)
QUALITY="bestvideo[height<=480]+bestaudio"
```

### Custom Keyframe Extraction

**Edit `scripts/downloader.sh`:**
```bash
# Extract at multiple timestamps
KEYFRAMES=("5" "15" "30" "60" "120")

# Extract only one frame
KEYFRAMES=("30")
```

### Download to Specific Directory

**Edit `scripts/downloader.sh`:**
```bash
# Adult content
DOWNLOAD_DIR="/media/wdisk/18+"

# YouTube videos
DOWNLOAD_DIR="/media/wdisk/youtube"

# External drive
DOWNLOAD_DIR="/mnt/usb/videos"
```

## Batch Download (Coming Soon)

### Multiple URLs

Send multiple URLs separated by newlines:
```
https://www.pornhub.com/view_video.php?viewkey=ph6123456789
https://www.pornhub.com/view_video.php?viewkey=ph6987654321
https://www.xvideos.com/video.1234567/video_title
```

### From Text File

Create a file with URLs:
```bash
cat > /tmp/download_list.txt << EOF
https://www.pornhub.com/view_video.php?viewkey=ph6123456789
https://www.pornhub.com/view_video.php?viewkey=ph6987654321
https://www.xvideos.com/video.1234567/video_title
EOF
```

Then process the file:
```bash
while IFS= read -r url; do
    bash scripts/downloader.sh "$url"
done < /tmp/download_list.txt
```

## Integration Examples

### + Video Frames Skill

After download, automatically extract more detailed frames:

```bash
# After download completes
if [ -x /root/clawd/skills/video-frames/extract.sh ]; then
    /root/clawd/skills/video-frames/extract.sh "$VIDEO_FILE" 10
fi
```

This extracts 10 evenly distributed frames from the video.

### + Notion Skill

Log downloads to a Notion database:

```bash
# After download completes
if [ -x /root/clawd/skills/notion/create-page.sh ]; then
    /root/clawd/skills/notion/create-page.sh \
        --title "$VIDEO_TITLE" \
        --url "$VIDEO_URL" \
        --duration "$VIDEO_DURATION" \
        --size "$VIDEO_SIZE"
fi
```

### + Telegram/Discord

**Send progress updates:**
```bash
# During download
curl -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d "chat_id=$CHAT_ID" \
    -d "text=Downloading: $VIDEO_TITLE (${PROGRESS}%)"
```

**Send completion notification:**
```bash
# After download completes
curl -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" \
    -F "chat_id=$CHAT_ID" \
    -F "photo=@$SCREENSHOT_1" \
    -F "caption=Download complete: $VIDEO_TITLE"
```

## CLI Usage

### Direct Script Usage

You can also use the script directly from CLI:

```bash
# Download a video
bash /home/wwwroot/skill-downloader/scripts/downloader.sh \
    "https://www.pornhub.com/view_video.php?viewkey=ph6123456789"

# Download to custom directory
DOWNLOAD_DIR="/tmp/downloads" \
    bash /home/wwwroot/skill-downloader/scripts/downloader.sh \
    "https://www.pornhub.com/view_video.php?viewkey=ph6123456789"
```

### With Custom Configuration

```bash
# Set quality
QUALITY="bestvideo[height<=720]+bestaudio" \
    bash scripts/downloader.sh "$URL"

# Set keyframes
KEYFRAMES=("5" "15" "30") \
    bash scripts/downloader.sh "$URL"
```

## Troubleshooting Examples

### Download Stuck

**Kill and retry:**
```bash
# Find process
ps aux | grep yt-dlp

# Kill it
kill -9 <PID>

# Retry download
bash scripts/downloader.sh "$URL"
```

### Wrong Video Title

**If video title has encoding issues:**
```bash
# Edit filename template
FILENAME_TEMPLATE="%(id)s.%(ext)s"
# Result: ph6123456789.mp4
```

### File Too Large

**If disk space is limited:**
```bash
# Download lower quality
QUALITY="worst"

# Or split video (manual)
ffmpeg -i input.mp4 -t 00:30:00 -c copy part1.mp4
ffmpeg -i input.mp4 -ss 00:30:00 -c copy part2.mp4
```

## Automation Examples

### Cron Job (Auto-Download)

Download from a RSS feed hourly:
```bash
# Add to crontab
0 * * * * /usr/bin/python3 /path/to/rss_downloader.py
```

### Watch Directory

Automatically download new URLs from a text file:
```bash
#!/bin/bash
WATCH_FILE="/tmp/download_queue.txt"
PROCESSED_FILE="/tmp/processed.txt"

while true; do
    while IFS= read -r url; do
        if ! grep -q "$url" "$PROCESSED_FILE"; then
            bash scripts/downloader.sh "$url"
            echo "$url" >> "$PROCESSED_FILE"
        fi
    done < "$WATCH_FILE"
    sleep 60
done
```

## Performance Tips

### Faster Downloads

```bash
# Enable aria2
USE_ARIA2=true

# Increase connections
--external-downloader-args "-x 16 -k 1M"
```

### Reduce CPU Usage

```bash
# Skip keyframes
KEYFRAMES=()

# Lower quality
QUALITY="worst"
```

### Parallel Downloads (Coming Soon)

```bash
MAX_CONCURRENT=3
```

## Testing

### Test Site Support

```bash
# Test without downloading
yt-dlp --skip-download "$URL"

# Test with verbose output
yt-dlp -v "$URL"

# Check available formats
yt-dlp -F "$URL"
```

### Test Configuration

```bash
# Dry run
bash scripts/downloader.sh --dry-run "$URL"

# Validate configuration
bash scripts/downloader.sh --validate
```

---

**Last Updated:** 2026-01-30
**Skill Version:** 1.0.0
