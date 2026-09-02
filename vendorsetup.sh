#!/bin/bash
#
# vendorsetup.sh  — OrangeFox (OFOX) build variables for Xiaomi SM8750 (thales)
#                   支持设备: dada(小米15) / haotian(15 Pro) / xuanyuan(15 Ultra)
#
# OrangeFox 的 FOX_* 变量必须放在 shell 脚本/vendorsetup.sh 中由环境导出，
# 不能写进 BoardConfig.mk（.mk 里不会被正确处理）。OF_*/TW_*/BOARD_* 可放 BoardConfig.mk。
# ref: https://wiki.orangefox.tech/en/dev/build_vars
#

export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"

# SM8750 是 (虚拟) A/B 设备 —— 必须声明，否则 fastboot/flash 相关行为会错
export FOX_AB_DEVICE=1
export FOX_VIRTUAL_AB_DEVICE=1

# 用预编译内核（不编译内核源码）
export OF_FORCE_PREBUILT_KERNEL=1

# 关闭 treble 兼容性检查（该检查在部分新平台会误判）
export OF_NO_TREBLE_COMPATIBILITY_CHECK=1

# 使用 TWRP recovery image 构建器（OrangeFox 底层仍用 TWRP 构建链路）
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1

# 小米设备带 frp 用
export OF_ENABLE_FRP_ADDON=1

# 推荐始终设置默认 keymaster 版本，否则可能卡在开机 logo
export OF_DEFAULT_KEYMASTER_VERSION=4.1

# 静态识别设备（lunch 目标用 twrp_sm8750_thales-eng）
FDEVICE="sm8750_thales"
