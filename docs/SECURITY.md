# Security Policy

## Credential Handling

### Cookie Security

The downloader uses yt-dlp's secure credential handling for authentication (age-restricted content, premium accounts, etc.).

**Security Features**:
- ✅ Tokens never appear in logs
- ✅ Cookies stored with `600` permissions (owner read/write only)
- ✅ Default storage location: `~/.config/yt-dlp/cookies.txt`
- ✅ No credentials passed via command-line arguments

**Best Practices**:

1. **Cookie File Permissions**
   ```bash
   # Set correct permissions
   chmod 600 ~/.config/yt-dlp/cookies.txt
   
   # Verify permissions
   ls -la ~/.config/yt-dlp/cookies.txt
   # Should show: -rw------- (600)
   ```

2. **Never Commit Cookies**
   ```bash
   # Add to .gitignore
   echo ".config/yt-dlp/cookies.txt" >> .gitignore
   
   # Verify it's ignored
   git check-ignore .config/yt-dlp/cookies.txt
   ```

3. **Rotate Cookies Regularly**
   ```bash
   # Export fresh cookies from browser
   # Overwrite old file
   chmod 600 ~/.config/yt-dlp/cookies.txt
   ```

### API Keys

For Clawdbot/OpenClaw integration with AI services:

**Storage**:
- Location: `~/.openclaw/agents/main/agent/auth-profiles.json`
- Format: JSON with provider profiles
- Permissions: `600` required

**Configuration Example**:
```json
{
  "version": 1,
  "profiles": {
    "google:default": {
      "type": "api_key",
      "provider": "google",
      "key": "YOUR_API_KEY_HERE"
    }
  }
}
```

**Best Practices**:
1. Never include API keys in code
2. Use environment variables when possible
3. Rotate keys periodically
4. Monitor usage for anomalies

---

## Log Security

### What IS Logged

- ✅ Download progress (percentages, speed)
- ✅ Video metadata (title, duration, uploader)
- ✅ Success/error messages
- ✅ File paths (local only)

### What is NOT Logged

- ❌ API keys or tokens
- ❌ Cookie contents
- ❌ Passwords
- ❌ Authentication credentials
- ❌ Sensitive URL parameters

### Log File Locations

**Clawdbot**:
```
~/.clawdbot/logs/
```

**OpenClaw**:
```
~/.openclaw/logs/
```

**Systemd**:
```
journalctl -u clawdbot -f
journalctl -u openclaw-gateway -f
```

---

## File Permissions

### Download Directory

**Recommended**:
```bash
# Create directory
mkdir -p /media/wdisk/downloads

# Set permissions
chmod 755 /media/wdisk/downloads  # rwxr-xr-x

# Verify
ls -ld /media/wisk/downloads
```

**Explanation**:
- `755` = Owner can write, group/others can read
- Prevents accidental deletion by other users
- Allows sharing of downloaded files

### Credentials Directory

**Critical**:
```bash
# Credentials directory
chmod 700 ~/.config/yt-dlp

# Cookie file
chmod 600 ~/.config/yt-dlp/cookies.txt

# Auth profiles
chmod 600 ~/.openclaw/agents/main/agent/auth-profiles.json
```

---

## Network Security

### HTTPS vs HTTP

**Default Behavior**: ✅ Always prefers HTTPS

**Fallback**: HTTP only if:
- Site doesn't support HTTPS
- Explicitly requested by user
- Behind trusted proxy

### Proxy Usage

**With Proxy**:
```bash
export https_proxy=http://proxy.example.com:8080
export http_proxy=http://proxy.example.com:8080
./downloader.sh "URL"
```

**Security Considerations**:
- Trust your proxy operator
- Use HTTPS proxy when possible
- Don't send credentials through untrusted proxies

### Tor/VPN

**For Privacy**:
```bash
# Via Tor SOCKS proxy
export all_proxy=socks5://127.0.0.1:9050
./downloader.sh "URL"

# Via VPN
# System-wide routing through VPN interface
```

---

## Code Security

### Input Validation

**URL Validation**:
```bash
# Checks performed:
- URL format (https?://)
- DNS resolution
- Site support
- File type checks
```

**Path Sanitization**:
- All filenames sanitized
- No path traversal allowed
- Directory traversal blocked

### Command Injection Prevention

**Safe Practices**:
```bash
# ✅ GOOD: Variables quoted
yt-dlp -o "$output_file" "$url"

# ❌ BAD: Unquoted variables
yt-dlp -o $output_file $url

# ✅ GOOD: Parameter expansion
cmd=("yt-dlp" "-o" "$output_file")
"${cmd[@]}"

# ❌ BAD: eval with user input
eval "yt-dlp $user_input"
```

---

## Download Safety

### Malicious Files

**Risk Mitigation**:
- No automatic execution of downloaded files
- File type detection before download
- Size limits configurable
- Scan before opening

**Recommendations**:
```bash
# After download, scan with clamav
clamscan /media/wdisk/downloads/

# Or use VirusTotal API
# Upload suspicious files for analysis
```

### Archive Safety (Zip, Tar, etc.)

**Best Practices**:
1. Never auto-extract archives
2. Review contents before extraction
3. Scan for malware
4. Beware of zip bombs (nested archives)

```bash
# List contents first
unzip -l suspicious.zip

# Extract to isolated directory
mkdir /tmp/isolated
unzip suspicious.zip -d /tmp/isolated

# Scan before opening
clamscan -r /tmp/isolated
```

---

## Dependency Security

### Keeping Dependencies Updated

**Critical Dependencies**:
```bash
# Update yt-dlp regularly
pip install --upgrade yt-dlp

# Or via apt
sudo apt update && sudo apt install yt-dlp

# Update ffmpeg
sudo apt install ffmpeg

# Update jq
sudo apt install jq
```

**Check for Vulnerabilities**:
```bash
# Check yt-dlp version
yt-dlp --version

# Check for security updates
sudo apt list --upgradable

# Run security audit (if using npm)
npm audit
```

---

## Reporting Security Issues

### Found a Vulnerability?

**Do NOT**:
- ❌ Publicly disclose the issue
- ❌ Create a public GitHub issue
- ❌ Discuss in public channels

**DO**:
- ✅ Email: security@oikewll.com
- ✅ Include detailed description
- ✅ Provide reproduction steps
- ✅ Allow reasonable time to fix

### Security Contact

- **Email**: security@oikewll.com
- **PGP Key**: Available on request
- **Response Time**: Within 48 hours

---

## Compliance and Legal

### Download Legality

**Your Responsibility**:
- ✅ Respect copyright laws
- ✅ Follow Terms of Service
- ✅ Only download content you have rights to
- ❌ Do not use for piracy

### Privacy

**Data Collected**:
- None. This tool runs locally.

**Data Shared**:
- None. No telemetry or tracking.

### DMCA

**Policy**:
- Tool itself is legal (like a VCR)
- Usage is user's responsibility
- Complies with legitimate use cases
- Not responsible for misuse

---

## Security Checklist

Before deploying:

- [ ] Cookie files have `600` permissions
- [ ] API keys stored securely, not in code
- [ ] Log files don't contain credentials
- [ ] Download directory has correct permissions
- [ ] Dependencies are up-to-date
- [ ] No hardcoded secrets in source
- [ ] Input validation enabled
- [ ] TLS/HTTPS preferred
- [ ] Proxy configured if needed
- [ ] Virus scanner installed (optional)

---

## Version History

| Version | Date | Security Changes |
|---------|------|------------------|
| 2.0.0 | 2026-02-02 | Added security docs, credential handling improvements |
| 1.0.0 | 2026-01-30 | Initial release |

---

**Last Updated**: 2026-02-02

**Security Team**: oikewll

**License**: MIT (See LICENSE file)
