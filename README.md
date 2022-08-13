# Generating the keys
On root directory of your rom, run:

    croot
    git clone https://github.com/baka-hokage/Signing-Script.git -b master scripts
    bash scripts/generate_key.sh


# Generating an install package
After Generating the keys, instead of running brunch , run the following: 

    lunch <codename>
    mka target-files-package otatools


# Signing target files

After it’s finished, you just need to sign all the APKs: 

    croot 
    sign_target_files_apks -o -d ~/.android-certs \
        $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip \
        signed-target_files.zip


# Generating the install package

Now, to generate the installable zip, run:

    ota_from_target_files -k ~/.android-certs/releasekey \
        signed-target_files.zip \
        signed-ota_update.zip


# All the references are from:

[AOSP](https://source.android.com/devices/tech/ota/sign_builds) &
[LineageOS](https://wiki.lineageos.org/signing_builds)
