#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
BOLD="\e[1m"
RESET="\e[0m"

DEFAULT_CERTS_DIR="$HOME/.android-certs"

get_yes_no() {
    local prompt="$1"
    local choice
    while true; do
        echo -en "$prompt"
        read -r choice </dev/tty
        case "$choice" in
            [Yy]* ) return 0 ;;  # Yes
            [Nn]* ) return 1 ;;  # No
            * ) echo -e "${RED}❌ Invalid choice. Please enter 'y' or 'n'.${RESET}" ;;
        esac
    done
}

clear
echo -e "${MAGENTA}══════════════════════════════════════════${RESET}"
echo -e "        ${BOLD}${CYAN}✦ AOSP Signing Key Generator ✦${RESET}"
echo -e "${MAGENTA}══════════════════════════════════════════${RESET}"
echo -e "${BOLD}${YELLOW}🔹 Android signing keys ensure system integrity & prevent unauthorized changes.${RESET}"
echo -e "${BOLD}${YELLOW}🔹 Each key signs different system components (platform, media, etc.).${RESET}"
echo -e "${RED}⚠ DO NOT share these keys—leaking them allows attackers to sign system apps!${RESET}"
echo

echo -en "${BOLD}${BLUE}❯ Enter key output directory [Default: ${DEFAULT_CERTS_DIR}]: ${RESET}"
read -r certs_dir
[ -z "$certs_dir" ] && certs_dir="$DEFAULT_CERTS_DIR"


if [ -d "$certs_dir" ]; then
    echo
    echo -e "${YELLOW}⚠ The directory ${BOLD}$certs_dir${RESET}${YELLOW} already exists.${RESET}"
    
    if get_yes_no "${BOLD}${RED}❯ Remove and generate fresh keys? (y/N): ${RESET}"; then
        rm -rf "$certs_dir"
        echo -e "${GREEN}✔ Old keys removed.${RESET}"
    else
        echo -e "${CYAN}✔ Keeping existing keys. Exiting.${RESET}"
        exit 0
    fi
fi

mkdir -p "$certs_dir"

SAMPLE_SUBJECT="/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com"
echo
echo -en "${BOLD}${BLUE}❯ Use this sample subject? ${RESET}(${YELLOW}$SAMPLE_SUBJECT${RESET}) (Y/n): "
read -r use_sample </dev/tty

if [[ "$use_sample" =~ ^[Yy]?$ ]]; then
    subject="$SAMPLE_SUBJECT"
    echo -e "${GREEN}✔ Using sample subject.${RESET}"
else
    echo -e "${BOLD}${MAGENTA}Now enter subject details for your keys:${RESET}"
    subject=""
    for entry in C ST L O OU CN emailAddress; do
        echo -en "${BOLD}${BLUE}$entry: ${RESET}"
        read -r val
        subject+="/$entry=$val"
    done
fi

echo
if get_yes_no "${BOLD}${BLUE}❯ Do you want to set a password for your keys?${RESET} (Recommended: No) (y/N): "; then
    password_flag=""
    echo -e "${GREEN}✔ Password will be required for keys.${RESET}"
else
    password_flag="-newkeypass ''"
    echo -e "${YELLOW}⚠ Generating keys without a password.${RESET}"
fi

echo -e "\n📌 ${BOLD}${CYAN}Generating keys in:${RESET} ${BOLD}$certs_dir${RESET}"
echo -e "${MAGENTA}──────────────────────────────────────────────${RESET}"

keys=("bluetooth" "certs" "cyngn-app" "media" "networkstack" "otakey" "nfc" "platform" "releasekey" "sdk_sandbox" "shared" "testcert" "testkey" "verity")

for key in "${keys[@]}"; do
    echo -en "   ${BOLD}${BLUE}Generating:${RESET} ${BOLD}${YELLOW}$key${RESET}..."
    ./development/tools/make_key "$certs_dir/$key" "$subject" $password_flag > /dev/null 2>&1
    echo -e " ${GREEN}✔ Done.${RESET}"
done

echo -e "${MAGENTA}──────────────────────────────────────────────${RESET}"
echo -e "${GREEN}✔ All keys generated successfully!${RESET}"
echo -e "${RED}⚠ Keep this folder safe. Losing these keys means you cannot update signed builds!${RESET}"
echo

MAKEFILE_PATH="$certs_dir/keys.mk"

echo -e "${BOLD}${BLUE}Generating Makefile: ${RESET}${BOLD}$MAKEFILE_PATH${RESET}"
cat <<EOF > "$MAKEFILE_PATH"
# Include this in your device tree or vendor makefile
SIGNING_KEY_PATH ?= $certs_dir
RELEASE_KEY := \$(SIGNING_KEY_PATH)/releasekey
PRODUCT_DEFAULT_DEV_CERTIFICATE := \$(RELEASE_KEY)
PRODUCT_OTA_PUBLIC_KEYS := \$(RELEASE_KEY)
EOF

echo -e "${GREEN}✔ Makefile generated.${RESET}"
echo
echo -e "${BOLD}${BLUE} Now include the Makefile in your device tree/vendor:${RESET}"
echo -e "    ${BOLD}include \$(SIGNING_KEY_PATH)/keys.mk${RESET}"
echo
echo -e "${MAGENTA}══════════════════════════════════════════${RESET}"
echo -e "${BOLD}✔ Setup Complete.${RESET} You can now build your ROM using the new keys :)"
echo -e "${MAGENTA}══════════════════════════════════════════${RESET}"
