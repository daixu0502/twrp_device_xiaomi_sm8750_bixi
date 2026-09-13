DEVICE_PATH := device/xiaomi/bixi

PRODUCT_SHIPPING_API_LEVEL := 35
PRODUCT_TARGET_VNDK_VERSION := 35
PRODUCT_CHARACTERISTICS := nosdcard
PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# Release the bootloader's secondary-panel continuous splash before TWRP takes
# DRM master. This prevents the static Xiaomi logo from remaining on the OLED.
PRODUCT_PACKAGES += \
    bixi-cover-display-cleanup \
    libbixi_haptic_log_redirect
