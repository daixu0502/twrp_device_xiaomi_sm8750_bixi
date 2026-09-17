# Xiaomi MIX Flip 2 (`bixi`) TWRP device tree


## Confirmed stock layout

| Item | Stock value |
| --- | --- |
| Device | Xiaomi MIX Flip 2 / `bixi` / `2505APX7BC` |
| SoC | Qualcomm SM8750 family, DT compatible `qcom,sun` / `qcom,sunp` |
| Kernel | GKI 6.6.77/6.6.118, arm64 only |
| Boot format | Header v4, 4096-byte pages, LZ4 ramdisk |
| Recovery | Dedicated A/B partition, 104857600 bytes, no embedded kernel |
| Display | 1224x2912 inner panel, `panel0-backlight` |
| Storage | UFS, dynamic logical partitions, EROFS/ext4, F2FS userdata |
| Android | 16/17 / API 36 (TWRP 35) |


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

## Wi-Fi bring-up

The Wi-Fi kernel modules are loaded asynchronously after TWRP stages the
installed ROM's vendor modules. The ramdisk carries bixi's stock peach_v2
configuration, matching rfkill module, stock wpa_supplicant/wpa_cli, and the
seven additional stock libraries needed by that supplicant. Its Android 15
binary uses the same compatibility preload approach as the crypto HALs. The
control socket stays under `/tmp/recovery/sockets` rather than `/data`. The
recovery ramdisk also includes the thales-tested ARM64 BusyBox at
`/system/bin/busybox` for the TWRP Wi-Fi test action, plus a minimal dhcpcd
hook to publish IP, gateway, and DNS properties. If a DHCP server omits DNS,
the hook uses its advertised gateway as the first DNS server.

After flashing a new build, check:

```sh
adb shell cat /tmp/bixi-wifi.log
adb shell getprop twrp.wifi.driver.ready
adb shell getprop init.svc.wpa_supplicant
adb shell wpa_cli -p /tmp/recovery/sockets -i wlan0 ping
```

A driver-ready status alone does not establish a Wi-Fi connection;
the stock AIDL supplicant must register and run. TWRP does not provide a Wi-Fi
connection screen in this tree, so use `wpa_cli` for network setup.
