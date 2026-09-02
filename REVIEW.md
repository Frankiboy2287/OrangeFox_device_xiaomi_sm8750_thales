# 审查报告：YuKongA TWRP 设备树 → OrangeFox 适配

> 审查对象：https://github.com/YuKongA/twrp_device_xiaomi_sm8750_thales (twrp-16.0)
> 适配目标：为 dada(小米15) / haotian(小米15 Pro) / xuanyuan(小米15 Ultra) 构建 OrangeFox Recovery
> 构建方式：GitHub Actions 云端编译（OrangeFox fox_14.1）
> 日期：本会话

## 一、设备信息（已确证）

- **平台**：高通 SM8750 = **骁龙 8 Elite（Snapdragon 8 Elite, SM8750-AB）**，芯片代号 **sun**，GPU **Adreno 830**。
- **变体 → 真机**（来自 variant-script.sh 与 Mi Code/固件渠道）：
  - `dada` = **小米 15**
  - `haotian` = **小米 15 Pro**
  - `xuanyuan` = **小米 15 Ultra**
- **thales**：是这套 SM8750 设备树的**统一工程代号**（`TARGET_DEVICE=sm8750_thales`），非独立消费机型代号。
- **分区特征**：Virtual A/B（`virtual_ab_ota` + `AB_OTA_UPDATER=true`）+ Dynamic Partitions（super≈11GB，组 `qti_dynamic_partitions`）+ AVB（`BOARD_AVB_ENABLE=true`）+ `boot/init_boot/vendor_boot/dtbo/vbmeta/vbmeta_system` + `metadata` 分区 + FBE（fscrypt policy 2）。无独立 recovery 分区（recovery 镜像 100MB，`EXCLUDE_KERNEL`，内核走 vendor_boot）。

## 二、原 TWRP 树亮点（适配时保留）

1. **单恢复镜像支持三机型**：`variant-script.sh` 读取 `ro.boot.hardware.sku`，设置机型/振动/显示属性，并从 `/odm/variant/<sku>/` 拷贝对应固件到 `/odm`。设计清晰、业界常见做法。
2. **完整解密链**：FBE 元数据解密 + fscrypt policy 2 + KeyMint/QTI + OMAPI + Weaver（ESE）+ `prepdecrypt.sh`（TWRP 标准脚本，先挂 system/vendor 读真实版本号再启动 KeyMint）。
3. **硬件特性**：`TW_SUPPORT_INPUT_AIDL_HAPTICS`(IVibrator/vibratorfeature)、`TW_LOAD_VENDOR_MODULES`(ADSP/NFC/触控/振动/WLAN 模块)、Wi-Fi(sun/cnss-peach)、USB-OTG(fastbootd)。
4. **内核/firmware 预编译**：`prebuilt/kernel` + `prebuilt/lib/firmware`(cs40l26) + `recovery/root/vendor/firmware_mnt`。

## 三、发现的问题 & 已做适配

| # | 问题/风险 | 说明 | 处理 |
|---|---|---|---|
| 1 | **API/VNDK 版本**：`PRODUCT_SHIPPING_API_LEVEL=35`、`PRODUCT_TARGET_VNDK_VERSION=35` | 原树面向 Android 16(API35)。OrangeFox `fox_14.1` 基于 Android 14(API34)。OnePlus15 参考树(SM8750 同款)用的是 API34。**这是构建冲突的最大风险点**。 | 若首次构建报版本相关错误，改为 34（参考 OnePlus15）。待首build验证。 |
| 2 | **老 AOSP 构建系统 break 校验** | 原树只设了 `BUILD_BROKEN_DUP_RULES`/`ELF_PREBUILT`。新 AOSP/SM8750 会触发 `NINJA_USES_ENV_VARS`/`PLUGIN_VALIDATION`。 | 已从 OnePlus15 参考树补齐 `BUILD_BROKEN_NINJA_USES_ENV_VARS += RTIC_MPGEN` 与 `BUILD_BROKEN_PLUGIN_VALIDATION := ...`。 |
| 3 | **`FOX_*` 与 `OF_*` 变量位置** | 原树全是 TWRP `TW_*`。OrangeFox 里 `FOX_*` 必须放 shell 脚本、`OF_*` 可放 .mk。 | 新增 `vendorsetup.sh`(FOX_*) + `fox_sm8750_thales.mk`(OF_*)，并在 `device.mk` 继承 fox 配置。 |
| 4 | **显示/触控偏移**：`variant-script.sh` 设置 `ro.twrp.y_offset`/`ro.twrp.h_offset` | 这是 **TWRP 特有** 的偏移属性；OrangeFox 用 `OF_SCREEN_H`/`OF_STATUS_H`/`OF_STATUS_INDENT_*` 控制布局。TWRP 的 offset 属性在 OrangeFox 不一定生效。 | 已按 OnePlus15 思路设置 `OF_SCREEN_H`/`OF_STATUS_H` 等；真机若出现显示错位需**逐机型校准**。 |
| 5 | **手电筒路径**：`OF_FL_PATH1` | 原树未提供闪光灯 LED 路径。（OnePlus15 用 `/sys/class/leds/white:flash-1`） | 已占位为 `/sys/class/leds/white:flash-1`，需真机校准。 |
| 6 | **`.gitignore` 误排除固件** | 我初次写 `.gitignore` 用了 `*.img`，会把触屏固件 `synaptics_spi_*.img` 一起排除。 | 已修正，仅忽略 `out/`、`.ccache/`、`INFO.txt`；确认 5 个 synaptics `.img` 已跟踪。 |
| 7 | **A/B 声明** | 原树为 Virtual A/B，但未对 OrangeFox 声明 A/B 标志。 | `vendorsetup.sh` 中 `FOX_AB_DEVICE=1`、`FOX_VIRTUAL_AB_DEVICE=1`。 |
| 8 | **开屏 logo 卡住风险** | 需设置默认 keymaster 版本。 | `vendorsetup.sh` 已设 `OF_DEFAULT_KEYMASTER_VERSION=4.1`。 |

## 四、构建流程（云端）

由 `.github/workflows/build.yml` 完成：
1. `orangefox_sync.sh --branch 14.1`（GitLab 官方 sync，基于 TWRP minimal manifest + OrangeFox 补丁+源码）。
2. 放入设备树于 `device/xiaomi/sm8750_thales`。
3. `<source> vendorsetup.sh` 导出 `FOX_*` → `lunch twrp_sm8750_thales-eng` → `mka recoveryimage`。
4. 出品 `OrangeFox-unofficial<device>.img` 上传到 Release。

## 五、待真机/首build 验证项

- （高）API 35 → 34 是否需要调整（见问题1）。
- （高）`recoveryimage` 出图名称与 `BOARD_RECOVERYIMAGE_PARTITION_SIZE=100MB` 是否放得下（可能需要 `LZ4`/压缩减小体积）。
- （中）不同变体的显示偏移/手电筒路径校准。
- （中）`vendor_boot` GKI 内核 + `recovery/root` 的 .ko/firmware 是否被正确加载。
- （低）`system_dlkm` 等新分区在 OFOX 构建系统是否被识别（必要时从动态分区列表移除的坑）。
