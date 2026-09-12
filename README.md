# Xiaomi MIX Flip 2 (`bixi`) TWRP device tree

This tree is derived from the unpacked HyperOS
`OS3.0.304.0.WOHCNXM` Android 16 images.


## Confirmed stock layout

| Item | Stock value |
| --- | --- |
| Device | Xiaomi MIX Flip 2 / `bixi` / `2505APX7BC` |
| SoC | Qualcomm SM8750 family, DT compatible `qcom,sun` / `qcom,sunp` |
| Kernel | GKI 6.6.77, arm64 only |
| Boot format | Header v4, 4096-byte pages, LZ4 ramdisk |
| Recovery | Dedicated A/B partition, 104857600 bytes, no embedded kernel |
| Display | 1224x2912 inner panel, `panel0-backlight` |
| Storage | UFS, dynamic logical partitions, EROFS/ext4, F2FS userdata |
| Android | 16 / API 36 (TWRP 35) |


## Build

Place this directory at `device/xiaomi/bixi` in a current Android compatible
TWRP source tree, then run:

```sh
export ALLOW_MISSING_DEPENDENCIES=true
source build/envsetup.sh
lunch twrp_bixi-bp2a-eng
m recoveryimage
```

The output should be `out/target/product/bixi/recovery.img`. Before device
testing, inspect it and confirm: header version 4, page size 4096, kernel size
0, LZ4 ramdisk, and total size no larger than 104857600 bytes.


## Data decryption bring-up

The recovery fstab declares FBE v2 with wrapped keys and metadata encryption.
The ramdisk includes bixi stock Qualcomm QSEECom, Gatekeeper, Secure Element,
KeyMint and SSGTZD components plus the device's NXP Weaver implementation.
Recovery mounts the active-slot modem firmware, keeps the vendor persist alias
isolated from TWRP's real `/persist` mount, loads `nxp-nci.ko`, starts the
trusted-app loader, and reads the installed system/vendor security patch levels
before starting KeyMint. The crypto coordinator verifies the required eSE and
GPQeSE trustlets are readable (with a bounded mount fallback) before SSGTZD and
Weaver start.

After flashing a new build, first verify that `vendor.qseecomd`,
`vendor.ssgtzd`, `vendor.gatekeeper_default`, `vendor.secure_element`,
`se_omapi`, `vendor.weaver_nxp`, and `vendor.keymint-qti` are running. A normal
cold start may spend a few seconds preparing this chain; repeated waits of tens
of seconds are not normal. Then test PIN/password decryption without formatting
`/data`.
