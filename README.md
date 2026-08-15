# luci-app-vocat

VoCat 的 OpenWrt/LuCI 管理包。提供在 LuCI 界面中控制 VoCat 服务的功能。

VoCat 是一个面向 Quectel EC20/EC25 系列蜂窝模组的开源 Web 控制面板与工程工具包（WiFi Calling / IMS SMS / eSIM / AT 终端 / 短信 / 代理路由等）。

- 上游：https://github.com/MengMengCode/VoCat
- 二进制 fork（自动同步 Release）：https://github.com/JGG-SH/VoCat

## 目录结构

```
luci-app-vocat/           # LuCI 插件包
  root/etc/config/vocat   # UCI 配置
  root/etc/init.d/vocat   # procd 启动脚本 (vocat serve)
  root/usr/share/vocat/   # shell 脚本
  root/usr/share/luci/menu.d/luci-app-vocat.json
  root/usr/share/rpcd/acl.d/luci-app-vocat.json
  htdocs/luci-static/resources/view/vocat/index.js   # 管理页
vocat-core/               # 核心二进制包（预编译打进固件）
  Makefile
  files/vocat-linux-aarch64
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

- 核心二进制当前为 v0.1.16（`vocat-linux-aarch64`，arm64）。
- 启动方式为 `vocat serve`，配置通过环境变量 `VOCAT_ADDR` / `VOCAT_DATABASE_PATH` 传递。
- 管理员密码由 VoCat 首次启动时生成并存入内置 SQLite，不写入 env 文件。
