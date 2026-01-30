# Universal Video Downloader - Skill Definition

## Name
`downloader`

## Description
Professional video downloader skill for Clawdbot/Moltbot. Downloads videos from 1000+ websites with automatic keyframe extraction, resume support, and organized storage.

## Category
Utilities / Media

## Version
1.0.0

## Author
Clawdbot Community

## Requirements

### System Dependencies
- **yt-dlp** (latest version recommended)
  ```bash
  sudo apt install -y yt-dlp
  # or: pip install yt-dlp
  ```
- **ffmpeg** (for video processing)
  ```bash
  sudo apt install -y ffmpeg
  ```

### Minimum Versions
- yt-dlp: >= 2023.1.1
- ffmpeg: >= 4.0
- Bash: >= 4.0

## Installation

### 1. Install Dependencies
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y yt-dlp ffmpeg

# Verify installation
yt-dlp --version
ffmpeg -version
```

### 2. Add to Clawdbot Skills
```bash
cd /root/clawd/skills/
git clone https://github.com/yourusername/skill-downloader.git downloader
```

### 3. Configure
Edit `scripts/downloader.sh`:
```bash
# Set your download directory
DOWNLOAD_DIR="/media/wdisk/downloads"

# Set keyframe timestamps (seconds)
KEYFRAMES=("10" "30")
```

### 4. Test
Send a video URL to your bot to test.

## Supported Websites

This skill uses yt-dlp, which supports **1000+ websites**:

### Adult Content (500+ sites)
- PornHub (including premium)
- XVideos
- xHamster
- RedTube
- YouPorn
- Brazzers
- Reality Kings
- And 500+ more

### Mainstream Video (500+ sites)
- YouTube (including playlists, channels)
- Vimeo
- Dailymotion
- Twitch (clips, VODs)
- Twitter/X
- Instagram (stories, reels, posts)
- Facebook (videos, reels)
- TikTok
- Reddit
- And 500+ more

**Full list:** Run `yt-dlp --list-extractors` or see [docs/SUPPORTED_SITES.md](docs/SUPPORTED_SITES.md)

## Usage

### Basic Usage
Send any supported video URL to your bot:

```
https://www.pornhub.com/view_video.php?viewkey=ph6123456789
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://twitter.com/user/status/123456789
```

### What Happens
1. Bot detects video URL
2. Extracts video metadata
3. Downloads video to configured directory
4. Extracts keyframes at 10s and 30s
5. Sends screenshots to chat
6. Notifies when complete

### Resume Interrupted Downloads
If download fails or is interrupted, just send the same URL again. The skill will automatically resume from where it left off.

## Configuration Options

### Download Directory
```bash
# In scripts/downloader.sh
DOWNLOAD_DIR="/media/wdisk/downloads"     # Default
DOWNLOAD_DIR="/media/wdisk/18+"            # Adult content
DOWNLOAD_DIR="/home/user/downloads"        # Home directory
```

### Keyframe Extraction
```bash
# Extract screenshots at specific timestamps (seconds)
KEYFRAMES=("10" "30")      # Default: 10s and 30s
KEYFRAMES=("5" "15" "30")  # More frames
KEYFRAMES=()               # Disable keyframes
```

### Video Quality
```bash
QUALITY="best"                    # Best available quality
QUALITY="worst"                   # Lowest quality (faster)
QUALITY="bestvideo+bestaudio"     # Best video + audio separately
```

### Output Format
```bash
FORMAT="mp4"          # Force MP4 format
FORMAT="mkv"          # Force MKV format
FORMAT="best"         # Keep original format
```

### Filename Template
```bash
FILENAME_TEMPLATE="%(title)s [%(id)s].%(ext)s"
# Available placeholders: title, id, uploader, date, etc.
```

## File Organization

### Directory Structure
```
${DOWNLOAD_DIR}/
├── Video Title [videoID].mp4
├── Video Title [videoID]_10s.jpg
└── Video Title [videoID]_30s.jpg
```

### Automatic Categorization (Optional)
```bash
# Enable in configuration
AUTO_CATEGORIZE=true

# Results in:
${DOWNLOAD_DIR}/
├── adult/
│   └── Video Title [videoID].mp4
├── youtube/
│   └── Video Title [videoID].mp4
└── tiktok/
    └── Video Title [videoID].mp4
```

## Safety & Privacy

### URL Detection
- Automatically detects supported URLs
- Ignores non-supported URLs
- Validates URL before download

### Download Safety
- Checks for sufficient disk space
- Validates downloaded files
- Removes partial downloads on failure

### Privacy
- No tracking or analytics
- Downloads directly to your storage
- No cloud intermediaries

## Troubleshooting

### Download Fails
```bash
# Update yt-dlp
pip install --upgrade yt-dlp

# Check if site is supported
yt-dlp --list-extractors | grep pornhub
```

### FFmpeg Not Found
```bash
# Install ffmpeg
sudo apt install -y ffmpeg

# Verify
ffmpeg -version
```

### Permission Errors
```bash
# Fix download directory permissions
sudo chown -R $USER:$USER /media/wdisk/
chmod -R 755 /media/wdisk/
```

### Keyframe Extraction Fails
```bash
# Verify ffmpeg is installed and working
ffmpeg -version

# Check video duration
ffprobe video.mp4
```

## Advanced Features

### Playlist Download
```bash
# Download entire playlist (coming soon)
# Auto-detects playlists and asks for confirmation
```

### Batch Download
```bash
# Download multiple URLs (coming soon)
# Send URLs separated by newlines
```

### Custom Post-Processing
```bash
# Add custom commands after download
POST_DOWNLOAD_CMD="notify-send 'Download Complete' '%(title)s'"
```

## Integration with Other Skills

### + Video Frames Skill
Automatically extracts more detailed keyframes:
```bash
# After download, triggers video-frames skill
# Extracts 10+ evenly distributed frames
```

### + Notion Skill
Log downloads to Notion database:
```bash
# Auto-creates page with video metadata
```

### + Telegram/Discord
Automatic notifications:
```bash
# Sends download progress
# Sends completion notification
# Sends keyframe previews
```

## Performance Tips

### Speed Up Downloads
```bash
# Use aria2 for faster downloads (optional)
sudo apt install -y aria2

# Enable in downloader.sh
USE_ARIA2=true
```

### Reduce CPU Usage
```bash
# Lower quality for faster processing
QUALITY="worst"

# Disable keyframes
KEYFRAMES=()
```

### Concurrent Downloads
```bash
# Enable concurrent downloads (coming soon)
MAX_CONCURRENT=3
```

## Limitations

### Network Speed
Download speed depends on:
- Your internet connection
- Source server speed
- Time of day

### Disk Space
Videos can be large (100MB - 5GB typical):
```bash
# Check available space
df -h /media/wdisk/
```

### Site Restrictions
Some sites may:
- Require authentication (not supported yet)
- Have geo-restrictions
- Rate-limit downloads
- Require premium accounts

## Updates

### Update yt-dlp Regularly
```bash
# Update to latest version
pip install --upgrade yt-dlp

# Or using apt
sudo apt update && sudo apt upgrade yt-dlp
```

### Update This Skill
```bash
cd /root/clawd/skills/downloader
git pull origin main
```

## Support

### Issues
- GitHub Issues: https://github.com/yourusername/skill-downloader/issues
- Discord: https://discord.gg/clawd

### Documentation
- Full docs: https://github.com/yourusername/skill-downloader#readme
- yt-dlp docs: https://github.com/yt-dlp/yt-dlp

## License

MIT License - Free to use, modify, and distribute.

---

**Last Updated:** 2026-01-30
**Skill Version:** 1.0.0
**Compatible With:** Clawdbot 2.x, Moltbot 1.x
