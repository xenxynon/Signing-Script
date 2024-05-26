#!/bin/bash

# Define colors
SIGN_GREEN='\033[0;32m'
SIGN_CYAN='\033[0;36m'
SIGN_YELLOW='\033[1;33m'
SIGN_NC='\033[0m' # No Color

# Pick up certs_dir from generate_key.sh if available
if [ -n "$certs_dir" ]; then
    CERTS_DIR="$certs_dir"
else
    CERTS_DIR="$HOME/.android-certs"
fi

# Fancy print functions for signing script
function sign_print_header() {
    echo -e "${SIGN_CYAN}"
    echo "========================================"
    echo "          BUILD SIGNING SCRIPT          "
    echo "========================================"
    echo -e "${SIGN_NC}"
}

function sign_print_footer() {
    echo -e "${SIGN_CYAN}"
    echo "========================================"
    echo "      BUILD SIGNING COMPLETED!          "
    echo "========================================"
    echo -e "${SIGN_NC}${SIGN_GREEN}Signed build stored as: signed-target_files.zip${SIGN_NC}"
}

# Sign Build Script
function sign_build() {
    sign_print_header
    echo "Signing build with certificates from: $CERTS_DIR"
    
    # Sign target files
    echo -e "${SIGN_YELLOW}Signing target files...${SIGN_NC}"
    croot 
    sign_target_files_apks -o -d "$CERTS_DIR" \
        $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip \
        signed-target_files.zip

    # Sign APEX modules
    echo -e "${SIGN_YELLOW}Signing APEX modules...${SIGN_NC}"
    find $OUT/obj/APPS -name '*.apk' -exec \
        sign_target_files_apks -o -d "$CERTS_DIR" \
        --extra_apks {}=$CERTS_DIR/releasekey \;

    sign_print_footer
}

# Ensure the script is executed with the correct permissions
if [ "$(basename "$0")" == "sign_build.sh" ]; then
    sign_build
fi
