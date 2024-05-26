#!/bin/bash

# Define colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Responses
positive_responses="yes|y|yep|sure|yeah|yup|ok|okay"
negative_responses="no|n|nope|nah|naw"

function print_header() {
    echo -e "${CYAN}"
    echo "------------------------------------------"
    echo "         ANDROID KEY GENERATOR            "
    echo "------------------------------------------"
    echo -e "${NC}"
}

function print_footer() {
    echo -e "${CYAN}"
    echo "------------------------------------------"
    echo "       KEY GENERATION COMPLETED!         "
    echo "       Welcome to the circus!             "
    echo "------------------------------------------"
    echo -e "${NC}${GREEN}Certificates are stored in: $1${NC}"
}

function print_section() {
    echo -e "${YELLOW}"
    echo "------------------------------------------"
    echo "|               $1                        |"
    echo "|        Generating APEX Keys             |"
    echo "------------------------------------------"
    echo -e "${NC}"
}

function execute_build_signing() {
    local certs_dir=$1
    echo -e "${YELLOW}Do you want to run the build signing script now? (yes/no): ${NC}"
    read -r response

    if [[ "$response" =~ ^($positive_responses)$ ]]; then
        echo -e "${YELLOW}Executing Build Signing Script...${NC}"
        ./sign_build.sh "$certs_dir"
    elif [[ "$response" =~ ^($negative_responses)$ ]]; then
        echo -e "${YELLOW}Skipping build signing.${NC}"
    fi
}

function keygen() {
    local default_certs_dir=~/.android-certs
    local certs_dir=${1:-$default_certs_dir}
    local response=$2

    print_header

    # Check if certificate directory exists and prompt the user if no response is given
    if [ -d "$certs_dir" ]; then
        echo -e "${RED}Warning: Found existing directory for keys: $certs_dir${NC}"
        echo "It is recommended to wipe the existing directory to avoid conflicts."
        if [ -z "$response" ]; then
            echo -n "Do you want to wipe the existing directory? (yes/no): "
            read -r response
        fi

        response=$(echo "$response" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase

        if [[ "$response" =~ ^($positive_responses)$ ]]; then
            echo "Cleaning and setting up certificate directory..."
            rm -rf "$certs_dir"
            mkdir -p "$certs_dir"
            echo "Directory setup at: $certs_dir"
        elif [[ "$response" =~ ^($negative_responses)$ ]]; then
            echo "Keeping existing directory: $certs_dir"
        else
            echo "Invalid response. Exiting."
            exit 1
        fi
    else
        echo "Setting up new certificate directory..."
        mkdir -p "$certs_dir"
        echo "Directory setup at: $certs_dir"
    fi
    echo

    local subject=""
    echo "Sample subject: '/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'"
    echo "Now enter subject details for your keys:"
    echo "----------------------------------------"

    # Read subject details from user input
    for entry in C ST L O OU CN emailAddress; do
        while true; do
            echo -n "$entry: "
            read -r val
            if [ -n "$val" ]; then
                subject+="/$entry=$val"
                break
            else
                echo "Value for $entry cannot be empty. Please try again."
            fi
        done
    done
    echo "----------------------------------------"
    echo "Subject details: $subject"
    echo

    # Generate keys for standard certificates
    print_section "Generating Standard Keys"
    local standard_keys=("bluetooth" "certs" "cyngn-app" "media" "networkstack" "platform" "releasekey" "sdk_sandbox" "shared" "testcert" "testkey" "verity")
    for key in "${standard_keys[@]}"; do
        echo "Generating key: $key"
        ./development/tools/make_key "$certs_dir/$key" "$subject"
    done

    # Modify make_key script to use 4096 bits instead of 2048 bits
    echo "Updating key length to 4096 bits..."
    sed -i 's|2048|4096|g' ./development/tools/make_key

    # Generate keys for APEX modules
    print_section "Generating APEX Keys"
    local apex_modules=("com.android.adbd" "com.android.adservices" "com.android.adservices.api" "com.android.appsearch" "com.android.art" "com.android.bluetooth" "com.android.btservices" "com.android.cellbroadcast" "com.android.compos" "com.android.configinfrastructure" "com.android.connectivity.resources" "com.android.conscrypt" "com.android.devicelock" "com.android.extservices" "com.android.graphics.pdf" "com.android.hardware.biometrics.face.virtual" "com.android.hardware.biometrics.fingerprint.virtual" "com.android.hardware.boot" "com.android.hardware.cas" "com.android.hardware.wifi" "com.android.healthfitness" "com.android.hotspot2.osulogin" "com.android.i18n" "com.android.ipsec" "com.android.media" "com.android.media.swcodec" "com.android.mediaprovider" "com.android.nearby.halfsheet" "com.android.networkstack.tethering" "com.android.neuralnetworks" "com.android.ondevicepersonalization" "com.android.os.statsd" "com.android.permission" "com.android.resolv" "com.android.rkpd" "com.android.runtime" "com.android.safetycenter.resources" "com.android.scheduling" "com.android.sdkext" "com.android.support.apexer" "com.android.telephony" "com.android.telephonymodules" "com.android.tethering" "com.android.tzdata" "com.android.uwb" "com.android.uwb.resources" "com.android.virt" "com.android.vndk.current" "com.android.vndk.current.on_vendor" "com.android.wifi" "com.android.wifi.dialog" "com.android.wifi.resources" "com.google.pixel.camera.hal" "com.google.pixel.vibrator.hal" "com.qorvo.uwb")
    for apex in "${apex_modules[@]}"; do
        echo "Generating APEX key: $apex"
        ./development/tools/make_key "$certs_dir/$apex" "$subject"
        openssl pkcs8 -in "$certs_dir/$apex.pk8" -inform DER -nocrypt -out "$certs_dir/$apex.pem"
    done

    print_footer "$certs_dir"
    execute_build_signing "$certs_dir"
}

# Ensure the script is executed with the correct permissions
if [ "$(basename "$0")" == "generate_key.sh" ]; then
    if [[ "$1" =~ ^--($positive_responses)$ ]]; then
        keygen "" "yes"  # Pass "yes" as the second argument
    elif [[ "$1" =~ ^--($negative_responses)$ ]]; then
        keygen "" "no"  # Pass "no" as the second argument
    else
        keygen "$1" "$2"
    fi
fi
