##
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/sm8750_bixi

# Inherit from device.mk configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

## Device identifier
PRODUCT_DEVICE := xiaomi_bixi
PRODUCT_NAME := twrp_xiaomi_bixi
PRODUCT_BRAND := xiaomi
PRODUCT_MODEL := 2505APX7BC
PRODUCT_MANUFACTURER := xiaomi

# Theme
TW_STATUS_ICONS_ALIGN := center