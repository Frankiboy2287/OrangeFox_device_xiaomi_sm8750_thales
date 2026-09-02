# OrangeFox Recovery device tree for Xiaomi SM8750 (thales)

支持设备（SM8750 / 骁龙8至尊版 / 平台代号 sun / GPU Adreno830）：

| 变体 SKU | 机型 |
|---|---|
| `dada` | 小米 15 |
| `haotian` | 小米 15 Pro |
| `xuanyuan` | 小米 15 Ultra |

基于 OrangeFox R12（fox_14.1 / Android 14 基座）。

## Features

- [X] ADB / FastbootD
- [X] Decryption
- [X] Display
- [X] Flashing
- [X] MTP
- [X] Sideload
- [X] USB-OTG
- [X] Vibrator
- [X] WLAN

## 构建（云端一键）

本仓库自带 `.github/workflows/build.yml`，在 GitHub 仓库 **Actions** 页手动运行
**"OFRP 14.1 Builder (SM8750 thales)"** 即可在云端同步源码、编译并发布 recovery 镜像。

本地构建步骤同 workflow：
```bash
git clone https://gitlab.com/OrangeFox/sync.git && cd sync
./orangefox_sync.sh --branch 14.1 --path ~/android/fox_14.1
cd ~/android/fox_14.1/device && mkdir -p xiaomi && cd xiaomi
git clone <本仓库> -b main sm8750_thales
cd ~/android/fox_14.1
# 打补丁 + 换 bionic（见下「来源与致谢」）
source build/envsetup.sh && lunch twrp_sm8750_thales-ap2a-eng
mka adbd recoveryimage
```

## 来源与致谢（重要）

本设备树及构建方案**并非从零编写**，来自以下开源作者的成果，特此致谢并注明来源：

- **设备树 / 补丁 / 构建 recipe 来源**：[@adontoo](https://github.com/adontoo) 的
  [device_xiaomi_sm8750_OFRP](https://github.com/adontoo/device_xiaomi_sm8750_OFRP)
  （分支 `fox_14.1`）。其中：
  - `patches/ofox_bootable_recovery.patch` —— 直接取自该仓库的 `patches/` 目录
    （针对 OrangeFox `bootable/recovery` 的补丁：openaes C23 修复 + WLAN/microhttpd 功能）。
  - 开机卡 logo 的根因修复：构建时需**用其 fork 的 bionic 替换原版**：
    [OrangeFox-android_platform_bionic](https://github.com/adontoo/OrangeFox-android_platform_bionic)
  - 额外依赖：[android_external_libmicrohttpd](https://github.com/adontoo/android_external_libmicrohttpd)（分支 `ofox-14.1`）
- **上游 TWRP 设备树**：[YuKongA/twrp_device_xiaomi_sm8750_thales](https://github.com/YuKongA/twrp_device_xiaomi_sm8750_thales)
- **OrangeFox Recovery Project**：[OrangeFox](https://gitlab.com/OrangeFox)（fox_14.1）

> 许可证说明：本仓库 device tree 沿用 Apache-2.0（沿用上游头）；`patches/` 中的补丁
> 作用于 OrangeFox `bootable/recovery`（GPL-3.0），相应版权归 OrangeFox / adontoo 所有。
> 若你要再分发，请保留本「来源与致谢」段落并遵守对应许可证。

## 风险自担

刷恢复前请备份数据并解锁 bootloader；建议先 `fastboot boot` 临时启动验证，错误操作可能导致变砖。
