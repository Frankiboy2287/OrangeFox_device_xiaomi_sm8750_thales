#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Configure base.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Configure core_64_bit_only.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Configure virtual_ab_ota compression_with_xor.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)

# Configure emulated_storage.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Configure twrp config common.mk
$(call inherit-product, vendor/twrp/config/common.mk)

# API
# OrangeFox fox_14.1 基底为 Android 14 (SDK 34)，必须 ≤ BOARD_SYSTEMSDK_VERSIONS(34)，
# 否则报 config.mk:865 错误（原树按 TWRP16/API35 编写，此处下调为 34）
BOARD_SHIPPING_API_LEVEL := 34
PRODUCT_SHIPPING_API_LEVEL := 34
PRODUCT_TARGET_VNDK_VERSION := 34

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Enable Fuse Passthrough
PRODUCT_PROPERTY_OVERRIDES += persist.sys.fuse.passthrough.enable=true

# Otacert
PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(DEVICE_PATH)/security/releasekey

# Required modules
TWRP_REQUIRED_MODULES += \
    prebuilt

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# OrangeFox-specific settings (OF_* build variables)
$(call inherit-product, $(DEVICE_PATH)/fox_sm8750_thales.mk)
