# Universal Video Downloader Skill

A professional video downloader skill for [Clawdbot](https://github.com/clawdbot/clawdbot) and Moltbot. Download videos from 1000+ websites with automatic keyframe extraction and resume support.

## ✨ Features

- 🎬 **Multi-Platform Support**: Downloads from 1000+ websites (YouTube, PornHub, XVideos, Twitter, TikTok, etc.)
- 🔄 **Auto Resume**: Interrupted downloads automatically resume using byte-level recovery
- 📸 **Keyframe Extraction**: Automatic screenshot extraction at customizable timestamps (default: 10s and 30s)
- 📁 **Organized Storage**: Customizable output directory with automatic categorization
- 🎯 **Agent Review Mode**: Export keyframes and metadata for AI agent review workflows
- ⚡ **Fast & Efficient**: Uses yt-dlp for optimal download speed with aria2 support
- 🛡️ **Safe Downloads**: Built-in safety checks and secure credential handling

## 🚀 Quick Start

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y yt-dlp ffmpeg jq

# CentOS/RHEL
sudo yum install -y yt-dlp ffmpeg jq

# macOS
brew install yt-dlp ffmpeg jq
```

### Installation

```bash
# Clone this repository
cd /root/clawd/skills/
git clone https://github.com/oikewll/skill-downloader.git downloader

# Or install via install script
cd skill-downloader
chmod +x install.sh
./install.sh
```

### Basic Usage

```bash
# Download a video
./scripts/downloader.sh "https://youtube.com/watch?v=VIDEO_ID"

# With keyframes extraction (default: 10s and 30s)
./scripts/downloader.sh "URL"

# Export review package for agent workflows
./scripts/downloader.sh --export-clips "URL"
./scripts/downloader.sh --review-mode "URL"
```

## 📋 Usage Examples

### Standard Download

```bash
./scripts/downloader.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

**Output**:
- Video file downloaded to `/media/wdisk/downloads/`
- Keyframes extracted at 10s and 30s
- Metadata and thumbnails saved

### Agent Review Workflow

```bash
./scripts/downloader.sh --review-mode "https://youtube.com/watch?v=xxx"
```

**Output**:
- Creates `/media/wdisk/downloads/review_<video>/` directory containing:
  - Original video file
  - Keyframes in `keyframes/` subdirectory
  - `review_metadata.json` with all metadata
  - `index.html` for quick preview

### Custom Configuration

```bash
# Set custom download directory
export DOWNLOAD_DIR="/path/to/storage"

# Set custom keyframe timestamps
export KEYFRAMES=("5" "15" "30" "60")

# Run download
./scripts/downloader.sh "URL"
```

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOWNLOAD_DIR` | `/media/wdisk/downloads` | Output directory for downloads |
| `KEYFRAMES` | `("10" "30")` | Timestamps to extract keyframes (seconds) |
| `QUALITY` | `best` | Video quality (best/worst/bestvideo+bestaudio) |
| `FORMAT` | `best` | Output format (mp4/mkv/best) |
| `USE_ARIA2` | `false` | Use aria2 for faster downloads |
| `MAX_RETRIES` | `3` | Number of download retries |

### Script Configuration

Edit `scripts/downloader.sh` to customize:

```bash
# Download directory
DOWNLOAD_DIR="/media/wdisk/downloads"

# Keyframe timestamps (in seconds)
KEYFRAMES=("10" "30")

# Video quality
QUALITY="best"

# Output format
FORMAT="best"
```

## 🌐 Supported Sites

This skill supports 1000+ websites including:

### Adult Content
- PornHub
- XVideos
- xHamster
- RedTube
- YouPorn
- And 500+ more adult sites

### Mainstream Video
- YouTube
- Vimeo
- Dailymotion
- Twitch
- Twitter/X
- Instagram
- Facebook
- TikTok
- And 400+ more sites

**Full list**: [docs/SUPPORTED_SITES.md](docs/SUPPORTED_SITES.md)

## 🔐 Security

### Credential Handling

The downloader uses yt-dlp's secure credential handling:

- ✅ Tokens never appear in logs
- ✅ Cookies stored with `600` permissions
- ✅ No credentials passed via command-line arguments
- ✅ Safe authentication for age-restricted content

**See [docs/SECURITY.md](docs/SECURITY.md)** for complete security documentation.

### Cookie Authentication

For age-restricted or premium content:

```bash
# Export cookies from browser (using browser extension)
# Save to ~/.config/yt-dlp/cookies.txt
chmod 600 ~/.config/yt-dlp/cookies.txt

# Download with authentication
./scripts/downloader.sh "URL"
```

## 🔧 Advanced Usage

### Auto-Resume

Interrupted downloads automatically resume. No manual intervention needed:

```bash
# If download is interrupted (Ctrl+C, network failure, etc.)
# Just run the same command again
./scripts/downloader.sh "URL"
# yt-dlp will continue from where it left off
```

**How it works**:
- yt-dlp uses HTTP Range requests
- Byte-level recovery (no re-downloading segments)
- Automatic integrity verification

### Custom Keyframes

Extract specific timestamps:

```bash
# Edit downloader.sh
KEYFRAMES=("5" "15" "30" "60" "120")

# Or use environment variable
export KEYFRAMES=("10" "20" "30")
./scripts/downloader.sh "URL"
```

### Export Clips for Review

Perfect for AI agent workflows:

```bash
# Create review package
./scripts/downloader.sh --export-clips "URL"

# Output directory structure:
# review_<video>/
# ├── video.mp4
# ├── keyframes/
# │   ├── 10s.jpg
# │   └── 30s.jpg
# ├── review_metadata.json
# └── index.html (preview)
```

**Review metadata JSON**:
```json
{
  "video_title": "Video Title",
  "video_id": "abc123",
  "duration_seconds": 180,
  "keyframes_extracted": 2,
  "download_timestamp": "2026-02-02T14:30:00Z"
}
```

## 📖 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Configuration Options](docs/CONFIGURATION.md)
- [Supported Sites](docs/SUPPORTED_SITES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Security](docs/SECURITY.md)
- [Usage Examples](docs/EXAMPLES.md)

## 🛠️ Troubleshooting

### Common Issues

**Issue**: "Site not supported"
```bash
# Check if site is supported
yt-dlp --list-extractors | grep -i site_name
```

**Issue**: "Age-restricted content"
```bash
# Use cookies
chmod 600 ~/.config/yt-dlp/cookies.txt
# Add cookies from browser
```

**Issue**: "Download fails mid-way"
```bash
# Just re-run - auto-resume handles it
./scripts/downloader.sh "URL"
```

**See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** for complete troubleshooting guide.

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/skill-downloader.git

# Make changes
cd skill-downloader
vim scripts/downloader.sh

# Test changes
./scripts/downloader.sh "TEST_URL"

# Commit and push
git add .
git commit -m "Add new feature"
git push origin main
```

## 📄 License

MIT License - feel free to use this skill in your own projects.

See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The core download engine
- [ffmpeg](https://ffmpeg.org/) - Video processing
- [Clawdbot](https://github.com/clawdbot/clawdbot) - Bot framework
- Moltbook community - Feedback and testing

## 📞 Support

If you encounter issues:

1. Check [Troubleshooting](docs/TROUBLESHOOTING.md)
2. Search existing [GitHub Issues](https://github.com/oikewll/skill-downloader/issues)
3. Create a new issue with details:
   - OS and version
   - yt-dlp version (`yt-dlp --version`)
   - Exact error message
   - Steps to reproduce

### Community

- **Clawdbot Discord**: https://discord.com/invite/clawd
- **Moltbook**: https://www.moltbook.com
- **GitHub Discussions**: https://github.com/oikewll/skill-downloader/discussions

## 🔗 Links

- **GitHub**: https://github.com/oikewll/skill-downloader
- **Clawdbot**: https://github.com/clawdbot/clawdbot
- **Moltbook**: https://www.moltbook.com

---

**Made with ❤️ for the Clawdbot community**

Version: 2.0.0 | Last Updated: 2026-02-02
