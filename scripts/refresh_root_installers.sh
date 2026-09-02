#!/usr/bin/env bash
# 刷新橙狐内置的 root 安装包（.ko 内核模块）：
#  1) KernelSU_Suki_Installer.zip  -> SukiSU-Ultra v4.2.0 最新 .ko
#  2) KernelSU_Installer.zip       -> 5ec1cff/KernelSU v9.9.9 最新 .ko（原版 tiann 已停更/不内置 .ko）
#
# 用法: bash refresh_root_installers.sh <fo_source根目录>
# 说明: 不 set -e —— 单个下载失败不应中断主构建（保留橙狐自带默认安装包）。
set -u

WORKINGDIR="${1:?需传 fo_source 根目录}"
VDIR="$WORKINGDIR/vendor/recovery/Files"
TMP="$(mktemp -d)"

SUKISU_VER="v4.2.0"
KSU_VER="v9.9.9"

KV_LIST="android12-5.10 android13-5.10 android13-5.15 android14-5.15 android14-6.1 android15-6.6 android16-6.12 android17-6.18"

# ---- 1) SukiSU-Ultra ----
if [ -f "$VDIR/KernelSU_Suki_Installer.zip" ]; then
  mkdir -p "$TMP/suki"
  ( cd "$TMP/suki" && unzip -q "$VDIR/KernelSU_Suki_Installer.zip" ) && {
    for kv in $KV_LIST; do
      if curl -fsSL -o "$TMP/lkm.zip" \
        "https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/download/${SUKISU_VER}/aarch64-${kv}-lkm.zip"; then
        ( cd "$TMP/suki" && unzip -o -q "$TMP/lkm.zip" )
      else
        echo "  [跳过] ${kv} SukiSU LKM 下载失败"
      fi
    done
    echo "https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/tag/${SUKISU_VER}" > "$TMP/suki/source.txt"
    rm -f "$TMP/lkm.zip"
    ( cd "$TMP/suki" && zip -q -r "$VDIR/KernelSU_Suki_Installer.zip" . )
    echo "[OK] KernelSU_Suki_Installer.zip -> SukiSU ${SUKISU_VER}"
  }
fi

# ---- 2) 5ec1cff/KernelSU（原版 tiann 已不再随 APK 附带 .ko） ----
if [ -f "$VDIR/KernelSU_Installer.zip" ]; then
  mkdir -p "$TMP/ksu"
  ( cd "$TMP/ksu" && unzip -q "$VDIR/KernelSU_Installer.zip" ) && {
    for kv in $KV_LIST; do
      if curl -fsSL -o "$TMP/ksu/${kv}_kernelsu.ko" \
        "https://github.com/5ec1cff/KernelSU/releases/download/${KSU_VER}/lkm-aarch64-${kv}_kernelsu.ko"; then
        :
      else
        echo "  [跳过] ${kv} KernelSU .ko 下载失败"
      fi
    done
    echo "https://github.com/5ec1cff/KernelSU/releases/tag/${KSU_VER}" > "$TMP/ksu/source.txt"
    ( cd "$TMP/ksu" && zip -q -r "$VDIR/KernelSU_Installer.zip" . )
    echo "[OK] KernelSU_Installer.zip -> 5ec1cff/KernelSU ${KSU_VER}"
  }
fi

rm -rf "$TMP"
echo "[完成] root 安装器刷新结束"
