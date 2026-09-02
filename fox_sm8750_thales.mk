#
#	This file is part of the OrangeFox Recovery Project
# 	Copyright (C) 2025 The OrangeFox Recovery Project
#
#	OrangeFox is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	any later version.
#
#	OrangeFox is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
# 	This software is released under GPL version 3 or any later version.
#	See <http://www.gnu.org/licenses/>.
#
# 	Please maintain this if you use this script or any part of it
#
# X93 支持二厂设备（小米15 / 小米15 Pro / 小米15 Ultra (=SM8750 thales)）的 OrangeFox 设备树
# 参考：https://github.com/YuKongA/twrp_device_xiaomi_sm8750_thales (TWRP 16 基座)
# 构建模式：fox_14.1（OnePlus15 同款模式，见 README）
#

# --- 维护者 ---
OF_MAINTAINER := YuKongA

# --- 显示 / 状态栏布局 ---
# 面板分辨率：小米15 1200x2670(1080P+) / 15 Pro & Ultra 1440x3200(2K)
# 恢复用统一视口，此处取小米15 面板高度作为基准；如定制形态有偏，请在真机按需调整下列值。
OF_SCREEN_H := 2670
OF_STATUS_H := 141
OF_HIDE_NOTCH := 1
OF_STATUS_INDENT_LEFT := 70
OF_STATUS_INDENT_RIGHT := 50
OF_OPTIONS_LIST_NUM := 6
OF_USE_GREEN_LED := 0

# --- 手电筒（Flash）--- 需要真机校准，符号路径以实机 sysfs 为准，先占位
OF_FL_PATH1 := /sys/class/leds/white:flash-1

# --- 分区 / 动态分区 ---
# super 分区大小需与 BoardConfig.mk 的 BOARD_SUPER_PARTITION_SIZE 一致 (11811160064)
OF_DYNAMIC_FULL_SIZE := 11811160064
OF_ENABLE_ALL_PARTITION_TOOLS := 1
OF_WORKAROUND_BACKUP_BUG := 1
OF_USE_AIDL_BOOT_CONTROL := 1

# --- 数据格式 ---
# SM8750 默认 data 分区为 F2FS（HyperOS 2）
OF_FORCE_DATA_FORMAT_F2FS := 1
OF_UNBIND_SDCARD_F2FS := 1
OF_WIPE_METADATA_AFTER_DATAFORMAT := 1

# --- 通用构建开关 ---
OF_DISPLAY_FORMAT_FILESYSTEMS_DEBUG_INFO := 1
OF_FORCE_PREBUILT_KERNEL := 1
OF_NO_RELOAD_AFTER_DECRYPTION := 1
OF_NO_TREBLE_COMPATIBILITY_CHECK := 1
OF_ENABLE_FRP_ADDON := 1
OF_USE_LZ4_COMPRESSION := 1
OF_ENABLE_FS_COMPRESSION := 1

# --- 小米 / HyperOS 专有特性的相关开关 ---
# SM8750 为 VAB（虚拟 A/B）设备，A/B 自动检测在构建脚本中由 FOX_AB_DEVICE 控制（vendersetup.sh）
