# Troubleshooting Guide

## Table of Contents
- [Common Issues](#common-issues)
- [Minimal Checklist](#minimal-checklist)
- [Failure Modes](#failure-modes)
- [Platform-Specific Issues](#platform-specific-issues)
- [Getting Help](#getting-help)

---

## Common Issues

### 1. "No API key found" error

**Symptom**: Error message about missing API keys for Google or other providers

**Solution**:
This error occurs when using the downloader in a Clawdbot/OpenClaw environment. Configure auth profiles:

```bash
# For Clawdbot
clawdbot agents add google --api-key YOUR_KEY

# For OpenClaw
openclaw agents add google --api-key YOUR_KEY
```

### 2. "Site not supported" error

**Symptom**: yt-dlp cannot extract from the provided URL

**Solution**:
Check if the site is supported:
```bash
yt-dlp --list-extractors | grep -i site_name
```

If not supported, check [yt-dlp supported sites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)

### 3. Download fails mid-way

**Symptom**: Download starts but stops before completion

**Solutions**:
- **Network issues**: Script auto-resumes by default. Just re-run the same command
- **Geo-blocking**: Use a proxy:
  ```bash
  export https_proxy=http://proxy.example.com:8080
  ./downloader.sh "URL"
  ```
- **Rate limiting**: Wait a few minutes and retry

### 4. Keyframe extraction fails

**Symptom**: Video downloads but keyframes are not extracted

**Solutions**:
- Check ffmpeg is installed: `which ffmpeg`
- Verify video duration is > 10 seconds
- Check available disk space
- Look for error messages in the output

### 5. "Insufficient disk space" error

**Symptom**: Download fails with disk space warning

**Solution**:
```bash
# Check disk space
df -h /media/wdisk/downloads

# Clean up old files
find /media/wdisk/downloads -type f -mtime +30 -delete

# Or change DOWNLOAD_DIR in script
export DOWNLOAD_DIR="/path/to/more/space"
```

---

## Minimal Checklist

Before reporting an issue, verify:

- [ ] **Dependencies installed**
  ```bash
  which yt-dlp ffmpeg jq
  ```
  Install with: `sudo apt install -y yt-dlp ffmpeg jq`

- [ ] **Download directory writable**
  ```bash
  ls -ld /media/wdisk/downloads
  # Should show drwxr-xr-x or similar
  ```
  Fix with: `chmod 755 /media/wdisk/downloads`

- [ ] **URL supported**
  ```bash
  yt-dlp --list-extractors | grep -i "site_domain"
  ```

- [ ] **Network connectivity**
  ```bash
  curl -I "YOUR_URL"
  ```

- [ ] **Sufficient disk space**
  ```bash
  df -h /media/wdisk/downloads
  # Need at least 500MB free
  ```

- [ ] **Permissions on cookies file** (if using auth)
  ```bash
  ls -la ~/.config/yt-dlp/cookies.txt
  # Should be -rw------- (600)
  ```
  Fix with: `chmod 600 ~/.config/yt-dlp/cookies.txt`

---

## Failure Modes

### 1. Geo-blocked Content

**Symptoms**:
- "This video is not available in your country"
- Download fails immediately

**Solutions**:
1. Use a VPN or proxy
2. Use cookies from a browser in the correct region
3. Find alternative sources

### 2. Age-Restricted Content

**Symptoms**:
- "Sign in to confirm you're old enough"
- Download returns no video

**Solutions**:
1. Export cookies from browser:
   ```bash
   # Using browser cookies.txt extension
   # Export to ~/.config/yt-dlp/cookies.txt
   chmod 600 ~/.config/yt-dlp/cookies.txt
   ```

2. Use account authentication:
   ```bash
   yt-dlp --username USERNAME --password PASSWORD "URL"
   ```

### 3. Corrupted Download

**Symptoms**:
- Video file plays but glitches
- Incomplete duration

**Solutions**:
- Re-run the script (auto-resume)
- Manually delete corrupted file:
  ```bash
  rm "/media/wdisk/downloads/corrupted_file.mp4"
  ./downloader.sh "URL"
  ```

### 4. Rate Limiting

**Symptoms**:
- HTTP 429 errors
- "Too many requests"

**Solutions**:
1. Wait 5-10 minutes
2. Use different IP/VPN
3. Add delays:
   ```bash
  export DOWNLOAD_RATE_LIMIT=1M
  ```

### 5. DRM-Protected Content

**Symptoms**:
- Download succeeds but file won't play
- Very small file size

**Solutions**:
- DRM content cannot be downloaded
- Use screen recording instead
- Find non-DRM sources

---

## Platform-Specific Issues

### YouTube

**Issues**:
- Age-gated videos
- Members-only content
- 4K video requires authentication

**Solutions**:
- Use cookies for authentication
- For 4K: Sign in to YouTube cookies
- Consider lower quality options

### PornHub / Adult Sites

**Issues**:
- Geo-blocking
- Premium content
- Session requirements

**Solutions**:
- Check site accessibility in browser first
- Export cookies after logging in
- Verify free vs premium content

### Twitter / X

**Issues**:
- Login required for some videos
- Rate limiting
- GIF vs video confusion

**Solutions**:
- Use cookies from logged-in browser
- Download during off-peak hours
- Verify media type before download

### TikTok

**Issues**:
- Watermarked vs non-watermarked
- Region locks
- Private accounts

**Solutions**:
- Non-watermarked requires cookies
- Check account privacy
- Consider alternative downloaders for TikTok

---

## Debug Mode

Enable verbose output:

```bash
# Debug yt-dlp
yt-dlp -v "URL"

# Debug this script
bash -x downloader.sh "URL"

# Check version info
yt-dlp --version
ffmpeg -version | head -1
```

---

## Getting Help

If issues persist:

1. **Check logs**:
   ```bash
   # Clawdbot logs
   clawdbot logs --follow

   # OpenClaw logs
   openclaw logs --follow

   # System logs
   journalctl -u your-service -n 50
   ```

2. **Gather info**:
   - Script version
   - yt-dlp version (`yt-dlp --version`)
   - ffmpeg version (`ffmpeg -version`)
   - Exact error message
   - URL (or sanitized example)

3. **Report issues**:
   - GitHub: https://github.com/oikewll/skill-downloader/issues
   - Include: OS, versions, error messages, steps to reproduce

4. **Community**:
   - Clawdbot Discord: https://discord.com/invite/clawd
   - Moltbook: https://www.moltbook.com

---

## Quick Reference

| Error | Cause | Solution |
|-------|-------|----------|
| No API key | Missing auth config | Configure auth profiles |
| Site not supported | Unsupported platform | Check yt-dlp extractors |
| Download fails | Network/rate limit | Retry, use proxy |
| No keyframes | Video too short | Skip or adjust timestamps |
| Disk space full | No room | Clean up or change dir |
| Age-restricted | Need auth | Use cookies/login |
| Geo-blocked | Region lock | Use VPN/proxy |
| Corrupted file | Incomplete download | Re-run script |

---

Last updated: 2026-02-02
Version: 2.0.0
