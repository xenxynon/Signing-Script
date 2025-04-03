## Signing Key Generator
  Use this script to generate keys to sign your ROMS

---

## How to Use
### 1. Run the Script
```sh
./keygen/keygen.sh
```

### 2. Choose Key Storage Directory
You can specify a custom directory or use the default (`~/.android-certs`).

### 3. Choose Subject Information
```sh
❯ Use this sample subject? (/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com) (Y/n): y
✔ Using sample subject.
```
- Use a predefined sample subject (recommended for quick setup)
- Or manually enter details (Country, State, Organization, etc.)

### 4. Password
- You can choose to password-protected the keys or generate them without a password (recommended).

### 5. Keys Are Generated
```sh
📌 Generating keys in: /home/user/.android-certs
──────────────────────────────────────────────
  🔑 Generating: platform... ✔ Done.
  🔑 Generating: media... ✔ Done.
  🔑 Generating: verity... ✔ Done.
✔ All keys generated successfully!
```

### 6. Include Generated Keys in Build System
A `keys.mk` file is automatically created.
To use it, add the following to your device tree or vendor makefile:
```make
include <your/key/path>/keys.mk
```

---

## MISC
- **Script not executable?**
  ```sh
  chmod +x keygen/keygen.sh
  ```
- **Make sure dependencies are installed.** The script requires openssl, python basic shell utilities.
- **If build fails due to keys**, check that the generated keys are correctly referenced in your build configuration.

---

# All the references are from:

[AOSP](https://source.android.com/devices/tech/ota/sign_builds) &
[LineageOS](https://wiki.lineageos.org/signing_builds)
