#!/usr/bin/env bash
# 刷新橙狐内置的 SukiSU 安装包：用 SukiSU-Ultra v4.2.0 最新 .ko 重建
# KernelSU_Suki_Installer.zip（覆盖各 Android/内核版本）。
#
# 用法: bash refresh_root_installers.sh <fo_source根目录>
# 说明: 不 set -e —— 下载失败不应中断主构建（保留橙狐自带的默认安装包）。
set -u

WORKINGDIR="${1:?需传 fo_source 根目录}"

VDIR="$WORKINGDIR/vendor/recovery/Files"
TMP="$(mktemp -d)"
SUKISU_VER="v4.2.0"

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
else
  echo "[跳过] 未找到 $VDIR/KernelSU_Suki_Installer.zip"
fi

rm -rf "$TMP"
echo "[完成] SukiSU 安装器刷新结束"
