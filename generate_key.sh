#!/bin/bash

function keygen() {
    local certs_dir=~/.android-certs
    [ -z "$1" ] || certs_dir=$1
    rm -rf "$certs_dir"
    mkdir -p "$certs_dir"

    local subject=""
    echo "Sample subject: '/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'"
    echo "Now enter subject details for your keys:"
    for entry in C ST L O OU CN emailAddress; do
        echo -n "$entry: "
        read -r val
        subject+="/$entry=$val"
    done

    # Generate keys for standard certificates
    for key in bluetooth certs cyngn-app media networkstack platform releasekey sdk_sandbox shared testcert testkey verity; do
        ./development/tools/make_key "$certs_dir/$key" "$subject"
    done

    # Modify make_key script to use 4096 bits instead of 2048 bits
    sed -i 's|2048|4096|g' ./development/tools/make_key

    # Generate keys for APEX modules
    for apex in com.android.adbd com.android.adservices com.android.adservices.api com.android.appsearch com.android.art com.android.bluetooth com.android.btservices com.android.cellbroadcast com.android.compos com.android.configinfrastructure com.android.connectivity.resources com.android.conscrypt com.android.devicelock com.android.extservices com.android.graphics.pdf com.android.hardware.biometrics.face.virtual com.android.hardware.biometrics.fingerprint.virtual com.android.hardware.boot com.android.hardware.cas com.android.hardware.wifi com.android.healthfitness com.android.hotspot2.osulogin com.android.i18n com.android.ipsec com.android.media com.android.media.swcodec com.android.mediaprovider com.android.nearby.halfsheet com.android.networkstack.tethering com.android.neuralnetworks com.android.ondevicepersonalization com.android.os.statsd com.android.permission com.android.resolv com.android.rkpd com.android.runtime com.android.safetycenter.resources com.android.scheduling com.android.sdkext com.android.support.apexer com.android.telephony com.android.telephonymodules com.android.tethering com.android.tzdata com.android.uwb com.android.uwb.resources com.android.virt com.android.vndk.current com.android.vndk.current.on_vendor com.android.wifi com.android.wifi.dialog com.android.wifi.resources com.google.pixel.camera.hal com.google.pixel.vibrator.hal com.qorvo.uwb; do
        ./development/tools/make_key "$certs_dir/$apex" "$subject"
        openssl pkcs8 -in "$certs_dir/$apex.pk8" -inform DER -nocrypt -out "$certs_dir/$apex.pem"
    done
}

keygen "$1"
