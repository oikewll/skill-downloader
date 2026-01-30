#!/bin/bash

###############################################################################
# Universal Video Downloader - Installation Script
# Automatically installs dependencies and configures the skill
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

print_header() {
    echo ""
    echo "=================================="
    echo "$*"
    echo "=================================="
    echo ""
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root. This is not recommended for normal use."
    fi
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    else
        print_error "Cannot detect OS. Exiting."
        exit 1
    fi

    print_info "Detected OS: $OS $OS_VERSION"
}

# Install yt-dlp
install_yt_dlp() {
    print_header "Installing yt-dlp..."

    if command -v yt-dlp >/dev/null 2>&1; then
        print_info "yt-dlp already installed: $(yt-dlp --version)"
        return 0
    fi

    case $OS in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y yt-dlp
            ;;
        centos|rhel|fedora)
            sudo dnf install -y yt-dlp || sudo yum install -y yt-dlp
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm yt-dlp
            ;;
        *)
            print_info "Installing yt-dlp via pip..."
            pip3 install --user yt-dlp
            ;;
    esac

    if command -v yt-dlp >/dev/null 2>&1; then
        print_info "yt-dlp installed successfully: $(yt-dlp --version)"
    else
        print_error "Failed to install yt-dlp"
        exit 1
    fi
}

# Install ffmpeg
install_ffmpeg() {
    print_header "Installing ffmpeg..."

    if command -v ffmpeg >/dev/null 2>&1; then
        print_info "ffmpeg already installed: $(ffmpeg -version | head -1)"
        return 0
    fi

    case $OS in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y ffmpeg
            ;;
        centos|rhel|fedora)
            sudo dnf install -y ffmpeg || sudo yum install -y ffmpeg
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm ffmpeg
            ;;
        *)
            print_error "Cannot install ffmpeg automatically on $OS"
            print_info "Please install ffmpeg manually:"
            print_info "  Ubuntu/Debian: sudo apt install ffmpeg"
            print_info "  CentOS/RHEL: sudo yum install ffmpeg"
            print_info "  macOS: brew install ffmpeg"
            exit 1
            ;;
    esac

    if command -v ffmpeg >/dev/null 2>&1; then
        print_info "ffmpeg installed successfully"
    else
        print_error "Failed to install ffmpeg"
        exit 1
    fi
}

# Install optional dependencies
install_optional() {
    print_header "Installing Optional Dependencies..."

    # Install jq for JSON parsing
    if ! command -v jq >/dev/null 2>&1; then
        print_info "Installing jq..."
        case $OS in
            ubuntu|debian)
                sudo apt install -y jq
                ;;
            centos|rhel|fedora)
                sudo dnf install -y jq || sudo yum install -y jq
                ;;
        esac
    else
        print_info "jq already installed"
    fi

    # Install aria2 for faster downloads
    if ! command -v aria2c >/dev/null 2>&1; then
        print_info "Installing aria2c (for faster downloads)..."
        case $OS in
            ubuntu|debian)
                sudo apt install -y aria2
                ;;
            centos|rhel|fedora)
                sudo dnf install -y aria2 || sudo yum install -y aria2
                ;;
        esac
    else
        print_info "aria2c already installed"
    fi
}

# Configure download directory
configure_download_dir() {
    print_header "Configure Download Directory"

    print_info "Default download directory: /media/wdisk/downloads"
    read -p "Enter your preferred download directory [press Enter for default]: " DOWNLOAD_DIR

    if [ -z "$DOWNLOAD_DIR" ]; then
        DOWNLOAD_DIR="/media/wdisk/downloads"
    fi

    # Create directory
    if [ ! -d "$DOWNLOAD_DIR" ]; then
        print_info "Creating directory: $DOWNLOAD_DIR"
        mkdir -p "$DOWNLOAD_DIR"
    fi

    # Update script with custom directory
    sed -i "s|DOWNLOAD_DIR=\"/media/wdisk/downloads\"|DOWNLOAD_DIR=\"$DOWNLOAD_DIR\"|" scripts/downloader.sh

    print_info "Download directory set to: $DOWNLOAD_DIR"
}

# Configure keyframes
configure_keyframes() {
    print_header "Configure Keyframe Extraction"

    print_info "Default keyframes: 10s and 30s"
    read -p "Enter keyframe timestamps (space-separated, e.g., '10 30') [press Enter for default]: " KEYFRAMES_INPUT

    if [ -n "$KEYFRAMES_INPUT" ]; then
        # Convert input to array format
        KEYFRAMES_ARRAY=$(echo "$KEYFRAMES_INPUT" | tr ' ' '\n' | sed "s/.*/'&'/" | tr '\n' ' ')
        sed -i "s|KEYFRAMES=(\"10\" \"30\")|KEYFRAMES=($KEYFRAMES_ARRAY)|" scripts/downloader.sh
        print_info "Keyframes set to: $KEYFRAMES_INPUT"
    else
        print_info "Using default keyframes: 10s and 30s"
    fi
}

# Test installation
test_installation() {
    print_header "Testing Installation"

    print_info "Testing yt-dlp..."
    if yt-dlp --version >/dev/null 2>&1; then
        print_info "✓ yt-dlp works"
    else
        print_error "✗ yt-dlp failed"
        exit 1
    fi

    print_info "Testing ffmpeg..."
    if ffmpeg -version >/dev/null 2>&1; then
        print_info "✓ ffmpeg works"
    else
        print_error "✗ ffmpeg failed"
        exit 1
    fi

    print_info "Testing download script..."
    if bash -n scripts/downloader.sh; then
        print_info "✓ Script syntax is valid"
    else
        print_error "✗ Script syntax error"
        exit 1
    fi

    print_info "Testing script permissions..."
    if [ -x scripts/downloader.sh ]; then
        print_info "✓ Script is executable"
    else
        print_warning "Script is not executable, fixing..."
        chmod +x scripts/downloader.sh
    fi
}

# Print next steps
print_next_steps() {
    print_header "Installation Complete!"

    echo ""
    print_info "Your Universal Video Downloader skill is ready!"
    echo ""
    echo "Next Steps:"
    echo "1. Add this skill to your Clawdbot:"
    echo "   cd /root/clawd/skills/"
    echo "   ln -s /home/wwwroot/skill-downloader downloader"
    echo ""
    echo "2. Or install in your existing Clawdbot skills directory:"
    echo "   cp -r /home/wwwroot/skill-downloader /root/clawd/skills/downloader"
    echo ""
    echo "3. Test by sending a video URL to your bot:"
    echo "   https://www.pornhub.com/view_video.php?viewkey=ph6123456789"
    echo ""
    echo "4. Update yt-dlp regularly for best results:"
    echo "   pip install --upgrade yt-dlp"
    echo "   # or: sudo apt upgrade yt-dlp"
    echo ""
    echo "Documentation: https://github.com/yourusername/skill-downloader"
    echo ""
}

#=============================================================================
# MAIN INSTALLATION
#=============================================================================

main() {
    print_header "Universal Video Downloader - Installation"

    print_info "This script will install all required dependencies"
    print_info "and configure your downloader skill."
    echo ""

    # Pre-flight checks
    check_root
    detect_os

    # Install dependencies
    install_yt_dlp
    install_ffmpeg
    install_optional

    # Configuration
    configure_download_dir
    configure_keyframes

    # Test
    test_installation

    # Print next steps
    print_next_steps

    print_info "Installation completed successfully!"
}

# Run main function
main "$@"
