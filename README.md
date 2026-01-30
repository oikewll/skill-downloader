# Universal Video Downloader Skill

A professional video downloader skill for [Clawdbot](https://github.com/clawdbot/clawdbot) and Moltbot. Download videos from 1000+ websites with automatic keyframe extraction and resume support.

## ✨ Features

- 🎬 **Multi-Platform Support**: Downloads from 1000+ websites (YouTube, PornHub, XVideos, Twitter, etc.)
- 🔄 **Auto Resume**: Interrupted downloads automatically resume
- 📸 **Keyframe Extraction**: Automatic screenshot extraction at 10s and 30s
- 📁 **Organized Storage**: Customizable output directory with automatic categorization
- ⚡ **Fast & Efficient**: Uses yt-dlp for optimal download speed
- 🛡️ **Safe Downloads**: Built-in safety checks and validation

## 📋 Requirements

- **Clawdbot** or **Moltbot** installed
- **yt-dlp** (latest version recommended)
- **ffmpeg** (for video processing and keyframe extraction)
- Bash 4.0+

## 🚀 Quick Start

### 1. Install Dependencies

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y yt-dlp ffmpeg

# CentOS/RHEL
sudo yum install -y yt-dlp ffmpeg

# macOS
brew install yt-dlp ffmpeg
```

### 2. Clone This Skill

```bash
cd /root/clawd/skills/
git clone https://github.com/yourusername/skill-downloader.git downloader
```

### 3. Configure

Edit the script to set your preferred download directory:

```bash
nano scripts/downloader.sh
# Change: DOWNLOAD_DIR="/media/wdisk/downloads"
```

### 4. Usage

Send a video URL to your bot:

```
https://www.pornhub.com/view_video.php?viewkey=ph6123456789
```

The bot will automatically:
1. Detect the URL
2. Download the video
3. Extract keyframes (10s & 30s)
4. Send screenshots to your chat
5. Notify you when complete

## 📁 Project Structure

```
skill-downloader/
├── README.md              # This file
├── SKILL.md               # Clawdbot skill definition
├── install.sh             # Installation script
├── scripts/
│   └── downloader.sh      # Core download script
├── docs/
│   ├── SUPPORTED_SITES.md # List of supported websites
│   ├── CONFIGURATION.md   # Configuration options
│   └── TROUBLESHOOTING.md # Common issues
└── examples/
    └── usage-examples.sh  # Example usage
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

### See Full List

Check [docs/SUPPORTED_SITES.md](docs/SUPPORTED_SITES.md) for the complete list.

## ⚙️ Configuration

### Download Directory

Set your preferred download location:

```bash
# In downloader.sh
DOWNLOAD_DIR="/media/wdisk/downloads"  # Change this
```

### Keyframe Extraction

Configure which timestamps to extract:

```bash
# In downloader.sh
KEYFRAMES=("10" "30")  # Extract at 10s and 30s
```

### Supported File Types

By default, the skill downloads:
- MP4 videos
- MKV videos
- AVI videos
- And 100+ other formats

## 🔧 Advanced Usage

### Custom Output Directory

```bash
# In downloader.sh
CUSTOM_DIR="/media/wdisk/18+"  # For adult content
```

### Resume Interrupted Downloads

```bash
# The skill automatically resumes if download was interrupted
# Just send the same URL again
```

### Download Quality Selection

```bash
# In downloader.sh
QUALITY="best"  # Options: best, worst, bestvideo+bestaudio
```

## 📖 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Configuration Options](docs/CONFIGURATION.md)
- [Supported Sites](docs/SUPPORTED_SITES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - feel free to use this skill in your own projects.

## 🙏 Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The core download engine
- [ffmpeg](https://ffmpeg.org/) - Video processing
- [Clawdbot](https://github.com/clawdbot/clawdbot) - Bot framework

## 📞 Support

If you encounter any issues:

1. Check [Troubleshooting](docs/TROUBLESHOOTING.md)
2. Search existing [GitHub Issues](https://github.com/yourusername/skill-downloader/issues)
3. Create a new issue with details

---

**Made with ❤️ for the Clawdbot community**
