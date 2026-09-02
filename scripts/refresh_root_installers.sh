#!/usr/bin/env bash
# 刷新橙狐内置的 root 安装器：
#  1) 用 SukiSU-Ultra v4.2.0 最新 .ko 重建 KernelSU_Suki_Installer.zip（各 Android/内核版本）
#  2) 下载最新 FolkPatch / KernelSU / SukiSU 的 APK 放入 recovery 的 FFiles
#
# 用法: bash refresh_root_installers.sh <fo_source根目录> <device相对路径>
# 说明: 不 set -e —— 下载失败不应中断主构建（保留橙狐自带的默认安装包）。
set -u

WORKINGDIR="${1:?需传 fo_source 根目录}"
DEVICE="${2:?需传 device 相对路径}"

VDIR="$WORKINGDIR/vendor/recovery/Files"
TMP="$(mktemp -d)"
SUKISU_VER="v4.2.0"
KSU_VER="v3.3.0"
FOX_VER="kp0.13.8"

# ---- 1) 重建 KernelSU_Suki_Installer.zip（SukiSU 最新 .ko） ----
if [ -f "$VDIR/KernelSU_Suki_Installer.zip" ]; then
  mkdir -p "$TMP/suki"
  ( cd "$TMP/suki" && unzip -q "$VDIR/KernelSU_Suki_Installer.zip" ) && {
    for kv in android12-5.10 android13-5.10 android13-5.15 android14-5.15 \
              android14-6.1 android15-6.6 android16-6.12 android17-6.18; do
      if curl -fsSL -o "$TMP/lkm.zip" \
        "https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/download/${SUKISU_VER}/aarch64-${kv}-lkm.zip"; then
        ( cd "$TMP/suki" && unzip -o -q "$TMP/lkm.zip" ) || echo "解压 ${kv} LKM 失败"
      else
        echo "下载 ${kv} LKM 失败，保留旧版 .ko"
      fi
    done
    echo "https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/tag/${SUKISU_VER}" > "$TMP/suki/source.txt"
    rm -f "$TMP/lkm.zip"
    ( cd "$TMP/suki" && zip -q -r "$VDIR/KernelSU_Suki_Installer.zip" . )
    echo "[OK] 已更新 KernelSU_Suki_Installer.zip -> SukiSU ${SUKISU_VER}"
  }
fi

# ---- 2) 下载最新 APK 到 root_tools/（构建后作为 Release 附件发布，不塞进 ramdisk 以免超 100MB） ----
OUT="$WORKINGDIR/root_tools"
mkdir -p "$OUT/KernelSU" "$OUT/FolkPatch"

curl -fsSL -o "$OUT/KernelSU/SukiSU_${SUKISU_VER}.apk" \
  "https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/download/${SUKISU_VER}/SukiSU_v4.2.0_40900_releases.apk" \
  && echo "[OK] SukiSU APK ${SUKISU_VER}" || echo "[跳过] SukiSU APK 下载失败"

curl -fsSL -o "$OUT/KernelSU/KernelSU_${KSU_VER}.apk" \
  "https://github.com/tiann/KernelSU/releases/download/${KSU_VER}/KernelSU_v3.3.0_32601-release.apk" \
  && echo "[OK] KernelSU APK ${KSU_VER}" || echo "[跳过] KernelSU APK 下载失败"

curl -fsSL -o "$OUT/FolkPatch/FolkPatch_${FOX_VER}.apk" \
  "https://github.com/LyraVoid/FolkPatch/releases/download/${FOX_VER}/FolkPatch_115032_5.0_on_main-release.apk" \
  && echo "[OK] FolkPatch APK ${FOX_VER}" || echo "[跳过] FolkPatch APK 下载失败"

rm -rf "$TMP"
echo "[完成] root 安装器刷新结束"
