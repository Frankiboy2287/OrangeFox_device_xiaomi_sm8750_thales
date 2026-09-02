# OrangeFox Recovery device tree for Xiaomi SM8750 (thales)

支持设备（SM8750 / 骁龙8至尊版 / 平台代号 sun / GPU Adreno830）：

| 变体 SKU | 机型 |
|---|---|
| `dada` | 小米 15 |
| `haotian` | 小米 15 Pro |
| `xuanyuan` | 小米 15 Ultra |

本树为 **OrangeFox Recovery (OFOX)** 适配，基于
[YuKongA/twrp_device_xiaomi_sm8750_thales](https://github.com/YuKongA/twrp_device_xiaomi_sm8750_thales)
（TWRP 16 设备树）改造。设备通过 `ro.boot.hardware.sku` 自动识别三个变体，
并由 `recovery/root/odm/bin/variant-script.sh` 在启动时设置机型/振动/显示相关
属性并从 `/odm/variant/<sku>/` 拷贝对应固件。

## Features

- [X] ADB / FastbootD
- [X] Decryption (FBE metadata)
- [X] Display
- [X] MTP
- [X] Flashing (install)
- [X] Sideload
- [X] USB-OTG
- [X] Vibrator
- [X] WLAN

## 构建（OrangeFox fox_14.1）

本树上 **仅使用预编译内核**（`prebuilt/kernel`），不在本地编译内核源码。

```bash
mkdir -p ~/android/OrangeFox && cd ~/android/OrangeFox
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
./orangefox_sync.sh --branch 14.1 --path ~/android/fox_14.1
cd ~/android/fox_14.1/device && mkdir -p xiaomi && cd xiaomi
git clone <本仓库> -b <branch> sm8750_thales
cd ~/android/fox_14.1
source build/envsetup.sh
lunch twrp_sm8750_thales-eng
mka recoveryimage
```

产物：`out/target/product/sm8750_thales/OrangeFox-unofficial-sm8750_thales.img`

> **一键云端构建**：本仓库自带 `.github/workflows/build.yml`，在 GitHub 仓库
> **Actions** 页手动运行（workflow_dispatch）即可在云端产出并上传到 Release。

## 说明与重要警告

- 构建依赖 OrangeFox 官方 **fox_14.1**（Android 14+ 启动设备分支）。SM8750 为
  Android 15/16（HyperOS 2）启动器，需用 `fox_14.1` 而非 `fox_12.1`。
- `FOX_*` 变量放 `vendorsetup.sh`，`OF_*` 变量放 `fox_sm8750_thales.mk`。
- 开机 logo 卡住症状：确认已设置 `OF_DEFAULT_KEYMASTER_VERSION`（见 vendorsetup.sh）。
- 手电筒路径 `OF_FL_PATH1` 与状态栏偏移值（`OF_STATUS_*`/`OF_SCREEN_H`）需要
  真机校准，不同变体面板分辨率不同。
- 刷入方式：fastboot / OrangeFox 内安装。请务必先解锁 bootloader。
- **风险自担**：刷恢复前请备份数据；错误操作可能导致变砖。

## 上游参考

- https://github.com/YuKongA/twrp_device_xiaomi_sm8750_thales (TWRP 16 base)
- https://github.com/koaaN/android_device_oneplus_infiniti-orangefox (fox_14.1 同款模式)
- https://wiki.orangefox.tech (OrangeFox 官方 Wiki)
