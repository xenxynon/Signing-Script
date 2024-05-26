# ROM Key Generation and Signing

## Generating Keys

1. Clone the signing script repository into the root directory of your ROM:
    ```bash
    croot
    git clone https://github.com/xenxynon/Signing-Script.git -b patch scripts
    bash scripts/generate_key.sh
    ```

## Generating Install Package

2. After generating the keys, instead of running `brunch`, run the following commands:
    ```bash
    lunch <codename>
    m target-files-package otatools
    ```

### [OG METHOD] Signing Target Files

**After the previous step, sign all the APKs with**

    
    croot 
    sign_target_files_apks -o -d ~/.android-certs \
        $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip \
        signed-target_files.zip
    

## APEX Signing

3. For APEX payload signing, use the following command to automatically sign all APKs:
 ```
    find $OUT/obj/APPS \( -name '*.apk' -o -name '*.apex' \) -exec \
    sign_target_files_apks -o -d ~/.android-certs \
    --extra_apks {}=$HOME/.android-certs/releasekey \; \
$OUT/obj/PACKAGING/target_files_intermediates/*-target_files*.zip \
signed-target_files.zip
```
4. To generate recovery installable zip, execute:

```
    ota_from_target_files -k ~/.android-certs/releasekey \
        signed-target_files.zip \
        signed-ota_update.zip
```

## References
- partly kanged from [AOSP-Krypton vendor](https://github.com/AOSP-Krypton/vendor_kosp/blob/A12/envsetup.sh#L432-L448)
- [AOSP](https://source.android.com/devices/tech/ota/sign_builds)
- [LineageOS](https://wiki.lineageos.org/signing_builds)
