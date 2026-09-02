# OFOX 调试状态与明日计划（2026-09-02 存档）

> 本文件记录小米 15 Pro (SKU `haotian`) 上 OrangeFox R12 无法启动的调试进度，
> 供续接时快速恢复上下文。设备：小米15 Pro，HyperOS2 (Android15/16)，A/B VAB。

## 已确认的事实（用户实测）

1. **YuKongA TWRP-3.7.1-16** 在 15 Pro 上**一切正常**（进 rec / 解密 / 触控 / 刷机）。
   刷入位置：**A 槽 recovery 分区**（系统当前在 A 槽）。
2. **我们的 OrangeFox R12 (fox_14.1 基座) 崩**：卡橙狐 logo →（许久）→ 黑屏 → 重启；
   **logo 期间电脑无 adb 设备**（说明在 USB/adbd 起来前就挂了）。
3. `/sys/fs/pstore` 空、`/data/recovery` 无 last_log → 无内核崩溃现场可读。

## 根因判断

- 设备树内容与能跑的 TWRP-16 **完全相同**；唯一差异 = 构建基座
  （fox_14.1 = Android14/API34 vs twrp-16 = Android16/API35）。
- 对比 koaaN（OnePlus15，SM8850，**fox_14.1 上能正常启动**）与 YuKongA 的
  `init.recovery.qcom.rc`：YuKongA 的链在早期(on fs)就拉起 qseecomd/等 ssd/
  绑 persist/install_keyring，并在 post-fs 起 odm.variant-script + 自动拉起
  weaver/vibrator/touch HAL —— 这套重链极可能在 14.1 用户态某步卡死。
- 橙狐官方最新基座就是 fox_14.1（GitLab 分支无更新）。

## 调试路线

### Track 1（已触发，run 33641731681，commit 12a5586）
「最小启动」诊断版：`init.recovery.qcom.rc` 剪成 koaaN 同款（停用 qseecomd 提前
启动 / ssd wait / persist bind / install_keyring / odm.variant-script / odm HAL /
modem 挂载 / wifi import）。构建自动完成后镜像会发布到 Release。

**用户待测（明天晚上，拿到线刷包后）**：刷 A 槽 recovery，回答——
1. 能进橙狐主界面吗？ 2. adb 出现了吗？ 3. 还黑屏重启吗？
- 能进 → 逐块加回被停用的步骤二分定位 → 对症修（目标是恢复解密）。
- 仍崩 → fox_14.1 基座带不动 → 转 Track 2。

### Track 2（若 Track 1 失败）：橙狐 on 16 基座
- 基座：TWRP-Test/platform_manifest_twrp_aosp `twrp-16.0`
  （= 全量 AOSP android-16.0.0_r1 + include twrp-default.xml；vendor/twrp 来自
  twrp-default.xml）——与能启动的 TWRP-16 同一套。
- 做法：repo sync 该基座 → 把 bootable/recovery 换成橙狐 R12 源码
  (GitLab: OrangeFox/bootable/Recovery, 分支 fox_14.1) + 放 vendor/recovery
  (OrangeFox/vendor/recovery fox_14.1) → 保留 YuKongA 设备树 → 构建。
- 风险：橙狐 R12 源码按 A14 写，A16 平台可能编译不兼容，需多轮修编译错。

## 网络要点（本环境）

- 推送/访问 github：优先 `socks5h://127.0.0.1:7894`（curl 可用；git 走代理可能
  gnutls 握手失败时，可临时直连重试——直连时好时坏）。
- 本地令牌：`~/.dsh/plugins/dsh-github-connect/.github-auth.json`（OAuth, repo+workflow）。
- 设备树本地路径：`/root/chenghui/OFOX_device_sm8750_thales`（git origin 指向
  Frankiboy2287/OrangeFox_device_xiaomi_sm8750_thales, main）。
- 远端仓库：github.com/Frankiboy2287/OrangeFox_device_xiaomi_sm8750_thales
- 最近成功出图：run 33621448250 → Release `2026-09-02-33621448250`
  `OrangeFox-R12.0-Unofficial-sm8750.img`（100MB）。

## 真机日志抓取（明天若仍需）

卡 logo 期 adb 不起来 → 主要靠行为观察（能否进界面/adb/黑屏时序）。
若 Track1 能到 adb 阶段：`adb shell cat /tmp/recovery.log` + `dmesg` + `logcat -d`。
