#!/bin/bash
set -ex

cd /yocto

# Set default branch if not provided
BRANCH="${BRANCH:-scarthgap}"
echo "Using branch: ${BRANCH}"

# Configure Git globally
echo "Configuring Git..."
git config --global user.email "yocto.builder@example.com"
git config --global user.name "Yocto Builder"

# Initialize repo if not already done
if [ ! -d .repo ]; then
    echo "Initializing repo..."
    git config --global color.ui false
    repo init -u https://github.com/nxp-imx/imx-manifest.git -b imx-linux-scarthgap -m imx-6.6.23-2.0.0.xml
    repo sync
fi

# Clone required layers if not present
clone_layer() {
    local name=$1
    local branch=$2
    local repo_url=$3
    local path=$4

    if [ ! -d "$path" ]; then
        echo "Cloning $name layer..."
        git clone -b "$branch" "$repo_url" "$path"
    else
        cd "$path"
        # Hard reset and clean first
        git clean -fdx
        git reset --hard HEAD
        if [ -f .git/MERGE_HEAD ]; then
            git merge --abort
        fi
        git checkout -f "$branch"
        git fetch origin
        git reset --hard "origin/$branch"
        git pull || true
        cd -
    fi
}

git config --global --add safe.directory /yocto/sources/meta-librescoot

clone_layer "meta-mender" "scarthgap" "https://github.com/mendersoftware/meta-mender" "sources/meta-mender"
clone_layer "meta-flutter" "scarthgap" "https://github.com/meta-flutter/meta-flutter.git" "sources/meta-flutter"
clone_layer "meta-librescoot" "${BRANCH}" "https://github.com/librescoot/meta-librescoot" "sources/meta-librescoot"
clone_layer "meta-openjdk-temurin" "scarthgap" "https://github.com/lucimber/meta-openjdk-temurin" "sources/meta-openjdk-temurin"

# UPDATE SCOOTUI VERSION - NEW FUNCTIONALITY
echo "Check whether to update scootui version in bitbake recipe..."
if [ -n "${SCOOTUI_VERSION_UPDATE}" ]; then
    echo "Updating scootui version in bitbake recipe..."
    SCOOTUI_BB_FILE="sources/meta-librescoot/recipes-graphics/scootui/scootui.bb"
    
    if [ -f "$SCOOTUI_BB_FILE" ]; then
        echo "Found scootui.bb file: $SCOOTUI_BB_FILE"
        echo "Current PV line:"
        grep "^PV = " "$SCOOTUI_BB_FILE" || echo "No PV line found"
        
        # Backup the original file
        cp "$SCOOTUI_BB_FILE" "$SCOOTUI_BB_FILE.backup"
        
        # Update the PV line with the new timestamped version
        sed -i "s/^PV = \".*\"/PV = \"$SCOOTUI_VERSION_UPDATE\"/" "$SCOOTUI_BB_FILE"
        
        echo "Updated PV version to: $SCOOTUI_VERSION_UPDATE"
        echo "New PV line:"
        grep "^PV = " "$SCOOTUI_BB_FILE"
    else
        echo "Warning: scootui.bb file not found at $SCOOTUI_BB_FILE"
        echo "Directory contents:"
        ls -la sources/meta-librescoot/recipes-graphics/scootui/ || echo "Directory not found"
    fi
fi

# Determine LIBRESCOOT_VERSION - use environment variable if set, otherwise from meta-librescoot repository
if [ -z "${LIBRESCOOT_VERSION}" ]; then
    cd "sources/meta-librescoot"
    META_LIBRESCOOT_VERSION=$(git describe --always --long --tags --dirty 2>/dev/null || echo "0.0.1-dev")
    cd -
    LIBRESCOOT_VERSION="${META_LIBRESCOOT_VERSION}"
    echo "Using LibreScoot version from meta-librescoot: ${LIBRESCOOT_VERSION}"
else
    echo "Using LibreScoot version from environment variable: ${LIBRESCOOT_VERSION}"
fi

echo "Setting up build environment..."
DISTRO=librescoot-mdb source ./imx-setup-release.sh -b build

# Update local.conf based on the TARGET environment variable
TARGET="${TARGET:-mdb}"
# Overwrite bblayers.conf
echo "Overwriting bblayers.conf..."

if [ "$TARGET" == "dbc" ]; then
    # dbc
    cat > /yocto/build/conf/bblayers.conf << 'EOL'
LCONF_VERSION = "7"

BBPATH = "${TOPDIR}"
BSPDIR := "${@os.path.abspath(os.path.dirname(d.getVar('FILE', True)) + '/../..')}"

BBFILES ?= ""
BBLAYERS = " \
  ${BSPDIR}/sources/poky/meta \
  ${BSPDIR}/sources/poky/meta-poky \
  ${BSPDIR}/sources/meta-openembedded/meta-oe \
  ${BSPDIR}/sources/meta-openembedded/meta-multimedia \
  ${BSPDIR}/sources/meta-openembedded/meta-python \
  ${BSPDIR}/sources/meta-freescale \
  ${BSPDIR}/sources/meta-freescale-3rdparty \
  ${BSPDIR}/sources/meta-freescale-distro \
  ${BSPDIR}/sources/meta-mender/meta-mender-core \
  ${BSPDIR}/sources/meta-flutter \
  ${BSPDIR}/sources/meta-librescoot \
  ${BSPDIR}/sources/meta-openjdk-temurin \
  "

BBLAYERS += "${BSPDIR}/sources/meta-openembedded/meta-initramfs"

# i.MX Yocto Project Release layers
BBLAYERS += "${BSPDIR}/sources/meta-imx/meta-imx-bsp"
BBLAYERS += "${BSPDIR}/sources/meta-imx/meta-imx-sdk"
BBLAYERS += "${BSPDIR}/sources/meta-imx/meta-imx-ml"
BBLAYERS += "${BSPDIR}/sources/meta-imx/meta-imx-v2x"
BBLAYERS += "${BSPDIR}/sources/meta-nxp-demo-experience"

BBLAYERS += "${BSPDIR}/sources/meta-arm/meta-arm"
BBLAYERS += "${BSPDIR}/sources/meta-arm/meta-arm-toolchain"
BBLAYERS += "${BSPDIR}/sources/meta-browser/meta-chromium"
BBLAYERS += "${BSPDIR}/sources/meta-clang"
BBLAYERS += "${BSPDIR}/sources/meta-openembedded/meta-gnome"
BBLAYERS += "${BSPDIR}/sources/meta-openembedded/meta-networking"
BBLAYERS += "${BSPDIR}/sources/meta-openembedded/meta-filesystems"
BBLAYERS += "${BSPDIR}/sources/meta-qt6"
BBLAYERS += "${BSPDIR}/sources/meta-security/meta-parsec"
BBLAYERS += "${BSPDIR}/sources/meta-security/meta-tpm"
BBLAYERS += "${BSPDIR}/sources/meta-virtualization"
EOL
    echo "Overwriting local.conf..."
    cat > /yocto/build/conf/local.conf << EOL
MACHINE ??= 'unu-dbc'
DISTRO ?= 'librescoot-dbc'
MENDER_ARTIFACT_NAME = "release-1"
INHERIT += "mender-full"
INHERIT += "image-buildinfo" 
ARTIFACTIMG_FSTYPE = "ext4"
INIT_MANAGER = "systemd"
LIBRESCOOT_VERSION = "${LIBRESCOOT_VERSION:-0.0.1}"
PRSERV_HOST = "localhost:0"

PREFERRED_PROVIDER_u-boot = "u-boot-imx"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-imx"
PREFERRED_VERSION_u-boot-imx = "2017.03"
PREFERRED_VERSION_linux-imx = "6.6.3+git"

# EXTRA_IMAGE_FEATURES ?= "debug-tweaks"
USER_CLASSES ?= "buildstats"
PACKAGE_CLASSES ?= "package_rpm"
PATCHRESOLVE = "noop"
PACKAGECONFIG:append:pn-qemu-system-native = " sdl"
CONF_VERSION = "2"
DL_DIR ?= "/yocto/downloads/"
ACCEPT_FSL_EULA = "1"
HOSTTOOLS += "x86_64-linux-gnu-gcc git-lfs python"
# EXTRA_IMAGE_FEATURES = "debug-tweaks"
DEFAULT_TIMEZONE = "Europe/Berlin"
EOL
else
    # mdb
    cat > /yocto/build/conf/bblayers.conf << 'EOL'
LCONF_VERSION = "7"

BBPATH = "${TOPDIR}"
BSPDIR := "${@os.path.abspath(os.path.dirname(d.getVar('FILE', True)) + '/../..')}"

BBFILES ?= ""
BBLAYERS = " \
  ${BSPDIR}/sources/poky/meta \
  ${BSPDIR}/sources/poky/meta-poky \
  ${BSPDIR}/sources/meta-openembedded/meta-oe \
  ${BSPDIR}/sources/meta-openembedded/meta-multimedia \
  ${BSPDIR}/sources/meta-openembedded/meta-networking \
  ${BSPDIR}/sources/meta-openembedded/meta-python \
  ${BSPDIR}/sources/meta-freescale \
  ${BSPDIR}/sources/meta-freescale-3rdparty \
  ${BSPDIR}/sources/meta-freescale-distro \
  ${BSPDIR}/sources/meta-mender/meta-mender-core \
  ${BSPDIR}/sources/meta-librescoot \
  ${BSPDIR}/sources/meta-flutter \
"
EOL
    echo "Overwriting local.conf..."
    cat > /yocto/build/conf/local.conf << EOL
MACHINE ??= 'unu-mdb'
DISTRO ?= 'librescoot-mdb'
MENDER_ARTIFACT_NAME = "release-1"
INHERIT += "mender-full"
INHERIT += "image-buildinfo" 
ARTIFACTIMG_FSTYPE = "ext4"
INIT_MANAGER = "systemd"
LIBRESCOOT_VERSION = "${LIBRESCOOT_VERSION:-0.0.1}"
PRSERV_HOST = "localhost:0"
OLDEST_KERNEL = "5.4.24"
PREFERRED_PROVIDER_u-boot = "u-boot-imx"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-imx"
PREFERRED_PROVIDER_virtual/kernel="linux-imx"
PREFERRED_VERSION_linux-imx = "5.4.24+git"
PREFERRED_VERSION_linux-libc-headers = "5.4.25"
PREFERRED_VERSION_u-boot-imx = "2017.03"
EXTRA_IMAGE_FEATURES ?= "debug-tweaks"
USER_CLASSES ?= "buildstats"
PACKAGE_CLASSES ?= "package_rpm"
PATCHRESOLVE = "noop"
PACKAGECONFIG:append:pn-qemu-system-native = " sdl"
CONF_VERSION = "2"
DL_DIR ?= "/yocto/downloads/"
ACCEPT_FSL_EULA = "1"
HOSTTOOLS += "x86_64-linux-gnu-gcc git-lfs python"
EXTRA_IMAGE_FEATURES = "debug-tweaks"
DEFAULT_TIMEZONE = "Europe/Berlin"
EOL
fi

echo "Starting build process..."

# Check if PACKAGE is set to build only specific packages
if [ -n "${PACKAGE}" ]; then
    echo "Building specific package: ${PACKAGE}"
    bitbake "${PACKAGE}" --continue
else
    echo "Building full image: librescoot-${TARGET}-image"
    bitbake "librescoot-${TARGET}-image" --continue
fi
