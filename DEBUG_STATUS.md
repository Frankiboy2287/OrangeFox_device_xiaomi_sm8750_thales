# OFOX 调试结论与可复现方案（2026-09-02 已解决）

## 结论：能跑的橙狐 = 采用 adontoo 的树 + 他的构建 recipe

用户从酷安拿到一个**能正常启动**的橙狐镜像
`OrangeFox-R12.0_260812_Xiaomi_SM8750_thales-90abccfd.img`，作者 **adontoo**
（github.com/adontoo）。逆向分析该镜像 + 找到作者仓库后确认：

- 能跑版也是 **fox_14.1（Android 14 / API34）基座**，`lunch twrp_sm8750_thales-ap2a-eng`
  —— 与我们一致，**基座不是问题**；
- 关键差异在**构建 recipe**（我们缺了这些，导致开机卡 logo → 黑屏重启）：
  1. **替换 bionic**：`rm -rf bionic && git clone github.com/adontoo/OrangeFox-android_platform_bionic bionic`
     —— 骁龙8 Elite（Oryon 自研核）相关修复，**开机卡 logo 的根因**；
  2. **对 bootable/recovery 打补丁** `patches/ofox_bootable_recovery.patch`
     —— 含 openaes 的 C23 编译修复 + WLAN/microhttpd 功能；
  3. **加入 external/libmicrohttpd**（adontoo/android_external_libmicrohttpd，分支 ofox-14.1）；
  4. **`mka adbd recoveryimage`**（显式编 adbd）。

## 本仓库现状

- 设备树内容已换成 **adontoo/device_xiaomi_sm8750_OFRP**（分支 fox_14.1，383 文件，
  含 patches/、strongbox keymint、se_omapi、umountvendor、三变体 dada/haotian/xuanyuan）。
- workflow（.github/workflows/build.yml）已按上面 recipe 适配，并保留两个无害改进：
  ccache 由 ccache-action 托管（不覆盖 CCACHE_DIR），Release 只传成品镜像。
- 支持三设备：`TARGET_DEVICE_ALT="dada,haotian,xuanyuan"`（小米15/15 Pro/15 Ultra）。

## 待验证（明天晚上）

在仓库 Actions 触发 **"OFRP 14.1 Builder (SM8750 thales)"**（Run workflow），
应产出与酷安镜像同源的可用橙狐 `recovery.img`。刷 A 槽 recovery 分区验证：
启动 / adb / 解密 / 触控。

## 关键参考

- 作者设备树：github.com/adontoo/device_xiaomi_sm8750_OFRP （分支 fox_14.1）
- bionic fork：github.com/adontoo/OrangeFox-android_platform_bionic
- libmicrohttpd fork：github.com/adontoo/android_external_libmicrohttpd （分支 ofox-14.1）
- 上游 TWRP 树：github.com/YuKongA/twrp_device_xiaomi_sm8750_thales

## 网络要点（本环境）

- 推送/访问 github：优先 socks5h://127.0.0.1:7894（git 走代理可能 gnutls 失败时可临时直连）。
- 令牌：~/.dsh/plugins/dsh-github-connect/.github-auth.json（OAuth, repo+workflow）。
