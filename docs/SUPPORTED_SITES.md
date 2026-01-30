# Supported Websites

This skill uses [yt-dlp](https://github.com/yt-dlp/yt-dlp), which supports **1000+ websites**. Below is a categorized list of popular sites.

## Adult Content (500+ Sites)

### Most Popular
- **PornHub** (including premium content)
- **XVideos**
- **xHamster** (including premium)
- **RedTube**
- **YouPorn**
- **SpankBang**
- **Tube8**
- **PornMD**
- **YouJizz**

### Premium Sites
- **Brazzers**
- **Reality Kings**
- **Mofos**
- **Babes**
- **Digital Playground**
- **Twistys**
- **Sexy Hub**

### Hentai & Anime
- **Hanime**
- **Hentai Haven**
- **Animeidhentai**
- **Hentaistream**
- **Hentai.xxx**

### Asian Content
- **JAVHub**
- **Caribbeancom**
- **1Pondo**
- **Heyzo**
- **Tokyo Hot**
- **FC2**
- **Duga**

### Other Popular Sites
- Motherless
- XVideos RED
- PornHD
- PornTrex
- DaftSex
- Eporner
- TubeGalore
- PornOne
- HClips
- HDSex
- HotMovs
- Movs.Porn
- PornGo
- Txxx
- VPorn
- VoyeurHit
- Upornia
- YesPornPlease
- YouPorn

## Mainstream Video (500+ Sites)

### Video Platforms
- **YouTube** (videos, playlists, channels)
- **Vimeo**
- **Dailymotion**
- **Metacafe**
- **Veoh**
- **Break**
- **Funny or Die**

### Social Media
- **Twitter/X** (videos, GIFs)
- **Instagram** (posts, reels, stories, IGTV)
- **Facebook** (videos, reels)
- **TikTok** (videos, user profiles)
- **Reddit** (videos, GIFs)
- **Pinterest** (videos)
- **Tumblr**
- **Snapchat**

### Live Streaming
- **Twitch** (clips, VODs)
- **YouTube Live**
- **Facebook Live**
- **Periscope**
- **LiveLeak** (archive)

### Adult Social (NSFW)
- **OnlyFans** (requires authentication - not directly supported)
- **ManyVids**
- **Clips4Sale**
- **JustForFans**

### News & Media
- **CNN**
- **BBC**
- **Fox News**
- **MSNBC**
- **ESPN**
- **CBS News**
- **ABC News**

### Educational
- **Khan Academy**
- **TED Talks**
- **Coursera**
- **Udemy**
- **edX**
- **CrashCourse**

### Gaming
- **YouTube Gaming**
- **Twitch Clips**
- **IGN**
- **GameSpot**
- **Kotaku**

### Music
- **SoundCloud**
- **Bandcamp**
- **Spotify** (some content)
- **Apple Music** (some content)
- **Deezer**
- **Mixcloud**
- **Audius**

## Complete List

To get the complete list of supported websites:

```bash
# List all supported extractors
yt-dlp --list-extractors

# Search for specific sites
yt-dlp --list-extractors | grep -i porn
yt-dlp --list-extractors | grep -i tube
```

## Format Support

### Video Formats
- MP4
- MKV
- AVI
- MOV
- WMV
- FLV
- WebM
- 3GP
- And 100+ more formats

### Audio Formats
- MP3
- M4A
- AAC
- FLAC
- WAV
- OGG
- OPUS
- And 50+ more formats

### Quality Options

#### Video Quality
- 4K (2160p)
- 2K (1440p)
- Full HD (1080p)
- HD (720p)
- SD (480p)
- Low (360p, 240p)

#### Audio Quality
- 320kbps
- 256kbps
- 192kbps
- 128kbps
- 96kbps

## Special Features

### Playlists
- YouTube playlists
- Vimeo albums
- SoundCloud sets
- And many more

### Live Streams
- Twitch (VODs and clips)
- YouTube Live
- Facebook Live
- And many more

### Age-Restricted Content
This skill **can** download age-restricted content from:
- YouTube (age-restricted videos)
- PornHub (premium content with login)
- xHamster
- And many others

**Note:** Some sites require authentication or premium accounts.

## Geo-Restricted Content

Some sites have geo-restrictions. You may need to:
- Use a VPN
- Configure proxy in yt-dlp
- Use regional-specific URLs

### Example: Proxy Configuration
```bash
# In downloader.sh, add:
--proxy "socks5://127.0.0.1:1080"
```

## Site-Specific Notes

### PornHub
- Supports free and premium content
- Supports 1080p, 4K quality
- Supports multiple quality options

### YouTube
- Supports all video qualities
- Supports playlists and channels
- Supports age-restricted content
- Supports subtitles

### XVideos
- Supports up to 4K quality
- Fast download speeds
- Reliable service

### Twitter/X
- Supports videos and GIFs
- Requires authentication for some content
- Quality up to 1080p

### Instagram
- Supports posts, reels, stories
- Requires authentication for private accounts
- High quality downloads

### TikTok
- Supports videos and user profiles
- No watermark option
- High quality downloads

## Testing Site Support

To test if a site is supported:

```bash
# Test without downloading
yt-dlp --skip-download "URL"

# Test with verbose output
yt-dlp -v "URL"

# Check available formats
yt-dlp -F "URL"
```

## Unsupported Sites

These sites are **NOT supported**:
- Netflix (DRM protected)
- Hulu (DRM protected)
- Disney+ (DRM protected)
- Amazon Prime Video (DRM protected)
- HBO Max (DRM protected)
- OnlyFans (requires authentication)
- Patreon (requires authentication)

**Why?** These sites use DRM (Digital Rights Management) which prevents downloading.

## Regular Updates

yt-dlp is updated frequently to add new sites and fix broken extractors:

```bash
# Update yt-dlp
pip install --upgrade yt-dlp

# Or using package manager
sudo apt update && sudo apt upgrade yt-dlp

# Check version
yt-dlp --version
```

## Requesting Site Support

If a site is not supported:

1. Check yt-dlp GitHub: https://github.com/yt-dlp/yt-dlp/issues
2. Search for existing feature requests
3. Create a new issue if none exists
4. Be patient - yt-dlp is community-driven

---

**Last Updated:** 2026-01-30
**yt-dlp Version:** 2023.1.1+
