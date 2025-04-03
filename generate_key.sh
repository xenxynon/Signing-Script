function keygen() {
    local certs_dir=~/.android-certs
    [ -n "$1" ] && certs_dir=$1

    if [ -d "$certs_dir" ]; then
        read -p "Directory $certs_dir already exists. Remove it? (y/N): " choice </dev/tty
        case "$choice" in
            [Yy]*) rm -rf "$certs_dir";;
            *) echo "Using existing directory."; return;;
        esac
    fi

    mkdir -p "$certs_dir"

    local subject=""
    echo "Sample subject: '/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'"
    echo "Now enter subject details for your keys:"

    for entry in C ST L O OU CN emailAddress; do
        read -p "$entry: " val </dev/tty
        subject+="/$entry=$val"
    done

    for key in bluetooth certs cyngn-app media networkstack otakey nfc platform releasekey sdk_sandbox shared testcert testkey verity; do
        ./development/tools/make_key "$certs_dir"/$key "$subject"
    done
}
keygen
