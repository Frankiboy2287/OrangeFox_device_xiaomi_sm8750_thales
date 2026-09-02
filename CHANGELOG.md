# 更新日志 / Changelog

> 小米 SM8750（thales，即小米 15 / 15 Pro / 15 Ultra）OrangeFox Recovery 设备树。

## 2026-09-02

### 修复：橙狐开机卡 logo → 黑屏重启（核心）
- **根因**：骁龙8 Elite（Oryon 自研核）与 fox_14.1 原版 `bionic`（C 库）不兼容，导致 recovery 早期崩溃。
- **解决**：采用 [@adontoo](https://github.com/adontoo) 实测可用的构建 recipe：
  1. 构建时**用其 fork 的 bionic 替换原版**（`adontoo/OrangeFox-android_platform_bionic`）；
  2. 对 `bootable/recovery` 打补丁 `patches/ofox_bootable_recovery.patch`（openaes C23 修复 + WLAN/microhttpd）；
  3. 加入 `external/libmicrohttpd`；
  4. 构建目标改为 `mka adbd recoveryimage`。
- 设备树整体切换为 adontoo 的 `device_xiaomi_sm8750_OFRP`（分支 fox_14.1，支持 dada/haotian/xuanyuan 三变体）。

### 更新：内置 root 安装器（`.ko` 内核模块）
- **KernelSU_Suki_Installer.zip** → 更新到 **SukiSU-Ultra v4.2.0**（最新 `.ko`，含 SM8750 用的 android15-6.6 / android16-6.12）。
- **KernelSU_Installer.zip** → 更新到 **5ec1cff/KernelSU v9.9.9**（原版 tiann 已不随 APK 附带 `.ko`；改用此维护版预编译 `.ko`）。
- 实现方式：构建时执行 `scripts/refresh_root_installers.sh`，从官方 Release 拉取最新 `.ko` 重建安装包（非致命，失败保留橙狐默认）。
- KernelSU-Next 已停更，未更新（保留橙狐自带）。

### 构建流程（cloud CI）
- workflow：`OFRP 14.1 Builder (SM8750 thales)`，云端同步 fox_14.1 → 换 bionic/打补丁 → 刷新 root 安装器 → 编译 → 发布。
- lunch：`twrp_sm8750_thales-ap2a-eng`；`mka adbd recoveryimage`。
- ccache：跨轮缓存（max 4G）；Release 只上传 `OrangeFox-*.img` + `recovery.img`。
- API/VNDK = 34（fox_14.1 为 Android 14 基座；与真机 HyperOS Android15/16 无冲突）。

### 来源与致谢
- 设备树/补丁/recipe：[adontoo/device_xiaomi_sm8750_OFRP](https://github.com/adontoo/device_xiaomi_sm8750_OFRP)（fox_14.1）
- bionic：[adontoo/OrangeFox-android_platform_bionic](https://github.com/adontoo/OrangeFox-android_platform_bionic)
- libmicrohttpd：[adontoo/android_external_libmicrohttpd](https://github.com/adontoo/android_external_libmicrohttpd)（ofox-14.1）
- 上游 TWRP 树：[YuKongA/twrp_device_xiaomi_sm8750_thales](https://github.com/YuKongA/twrp_device_xiaomi_sm8750_thales)
- OrangeFox：[OrangeFox Recovery Project](https://gitlab.com/OrangeFox)
- SukiSU：[SukiSU-Ultra](https://github.com/SukiSU-Ultra/SukiSU-Ultra)
- KernelSU（维护版）：[5ec1cff/KernelSU](https://github.com/5ec1cff/KernelSU)
