# patches/ 说明

## ofox_bootable_recovery.patch

- **来源**：[adontoo/device_xiaomi_sm8750_OFRP](https://github.com/adontoo/device_xiaomi_sm8750_OFRP)
  仓库（分支 `fox_14.1`）的 `patches/ofox_bootable_recovery.patch`，**原样复制**，未做改动。
- **作用对象**：OrangeFox `bootable/recovery` 源码（构建时由 workflow 执行
  `git apply patches/ofox_bootable_recovery.patch`）。
- **内容**：
  1. `openaes/src/isaac/rand.{c,h}` —— 把 K&R 风格 C 改为 ANSI-C 原型（**C23 编译器必需**，否则编译失败）；
  2. `Android.mk` / `prebuilt/Android.mk` —— 加入 `microhttpd`（WLAN 网页服务）相关模块；
  3. `gui/action.cpp` 等 —— 新增 `setvaluebyfile` 动作与 WLAN 页面（配合 libmicrohttpd 的 WiFi 功能）。
- **版权/许可证**：本补丁作用于 OrangeFox Recovery（GPL-3.0-or-later）的源码，
  版权归 OrangeFox Recovery Project 及补丁作者 [@adontoo](https://github.com/adontoo) 所有。
  再分发请保留此说明与 GPL 条款。

## 其它构建依赖（补丁配套，见 workflow）

- bionic 替换：[adontoo/OrangeFox-android_platform_bionic](https://github.com/adontoo/OrangeFox-android_platform_bionic)
- WLAN 网页服务：[adontoo/android_external_libmicrohttpd](https://github.com/adontoo/android_external_libmicrohttpd)（分支 `ofox-14.1`）
