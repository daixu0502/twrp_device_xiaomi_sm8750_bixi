# Xiaomi MIX Flip 2 (`bixi`) TWRP Recovery device tree

This tree is derived from the unpacked HyperOS
`OS3.0.304.0.WOHCNXM` Android 16 images.

Download the compiled version:[Release](https://github.com/daixu0502/twrp_device_xiaomi_sm8750_bixi/releases)

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

The output should be `out/target/product/bixi/recovery.img`. 
