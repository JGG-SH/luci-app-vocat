# luci-app-vocat

VoCat 的 OpenWrt/LuCI 管理包。提供在 LuCI 界面中控制 VoCat 服务的功能。

VoCat 是一个面向 Quectel EC20/EC25 系列蜂窝模组的开源 Web 控制面板与工程工具包（WiFi Calling / IMS SMS / eSIM / AT 终端 / 短信 / 代理路由等）。

## 仓库架构（三仓两线）

| 仓库 | 定位 |
|------|------|
| [MengMengCode/VoCat](https://github.com/MengMengCode/VoCat) | 上游源码 + 官方 Release |
| [JGG-SH/VoCat](https://github.com/JGG-SH/VoCat) | **fork**：自动同步上游 Release，防作者跑路清库 + 保持最新版 |
| **JGG-SH/luci-app-vocat**（本仓库） | LuCI 界面 + shell 脚本 + Makefile，**不含死二进制** |

**二进制唯一来源 = fork 的 Release**。`vocat-core` 在编译时从 fork 动态下载，不手动塞二进制。

## 目录结构

```
luci-app-vocat/           # LuCI 插件包
  root/etc/config/vocat   # UCI 配置
  root/etc/init.d/vocat   # procd 启动脚本 (vocat serve)
  root/usr/share/vocat/   # shell 脚本
  root/usr/share/luci/menu.d/luci-app-vocat.json
  root/usr/share/rpcd/acl.d/luci-app-vocat.json
  htdocs/luci-static/resources/view/vocat/index.js   # 管理页
vocat-core/               # 核心二进制包（编译时从 fork Release 下载）
  Makefile
```

## 功能

- 启动 / 停止 / 重启
- 服务状态（运行/PID/内存/版本/架构）
- 驱动完整性检查（option / qmi_wwan / Quectel 识别 / ttyUSB）
- 端口配置

## 打包

在 OpenWrt 源码树中，把本仓库作为 feed 或直接复制到 `package/` 下：

```
git clone https://github.com/JGG-SH/luci-app-vocat.git package/luci-app-vocat
make menuconfig   # 勾选 LuCI → Applications → luci-app-vocat
```

## 说明

- 核心二进制当前为 v0.1.16（`vocat-linux-aarch64`，arm64），编译时从 fork Release 下载。
- 启动方式为 `vocat serve`，配置通过环境变量 `VOCAT_ADDR` / `VOCAT_DATABASE_PATH` 传递。
- 管理员密码由 VoCat 首次启动时生成并存入内置 SQLite，不写入 env 文件。
