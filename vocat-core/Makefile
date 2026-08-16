# ============================================================
# Package: vocat-core
# 描述: VoCat 核心二进制文件下载包
# 设计思路:
#   1. 编译时从 JGG-SH/VoCat 的 GitHub Releases 动态下载最新版本
#   2. 自动适配编译目标的 CPU 架构 (arm64/armv7/amd64/386)
#   3. 与 JGG-SH/VoCat 仓库的自动同步机制联动，保证始终使用最新稳定版
#   4. 二进制安装到 /opt/vocat/bin/vocat (VoCat 默认路径)
# ============================================================

include $(TOPDIR)/rules.mk

# ------------------------------------------------------------
# 包基本信息（包名不带架构后缀，由 TITLE 显示架构信息）
# ------------------------------------------------------------
PKG_NAME:=vocat-core
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=MengMengCode

# ------------------------------------------------------------
# 版本获取: 从 JGG-SH/VoCat 仓库动态查询最新 Release 版本
# 工作原理:
#   1. git ls-remote 查询所有 v* 标签
#   2. sort -V 按版本号排序 (如 v0.1.0 < v0.2.0)
#   3. tail -1 取最新版本
#   4. 若查询失败 (网络/仓库不可用)，直接报错终止构建
# ------------------------------------------------------------
PKG_VERSION:=$(shell git ls-remote --tags --refs https://github.com/JGG-SH/VoCat.git 'v*' 2>/dev/null | awk '{print $$2}' | sed 's|refs/tags/v||' | sort -V | tail -1)
ifeq ($(PKG_VERSION),)
  $(error 无法从 JGG-SH/VoCat 获取最新版本，请检查网络或仓库是否可访问)
endif

# ------------------------------------------------------------
# 架构映射: 将 OpenWrt 的 ARCH 变量映射为 Release 文件名后缀
# 支持架构:
#   aarch64 (ARM 64位)   → arm64   (IPQ60xx 系列路由器)
#   arm    (ARM 32位)    → armv7   (旧款路由器)
#   x86_64 (64位 x86)    → amd64   (软路由)
#   i386   (32位 x86)    → 386     (旧款软路由)
# 若 ARCH 不在支持列表中，直接报错终止构建
# ------------------------------------------------------------
ifeq ($(ARCH),aarch64)
  ARCH_SUFFIX:=arm64
else ifeq ($(ARCH),arm)
  ARCH_SUFFIX:=armv7
else ifeq ($(ARCH),x86_64)
  ARCH_SUFFIX:=amd64
else ifeq ($(ARCH),i386)
  ARCH_SUFFIX:=386
else
  $(error 不支持的架构: $(ARCH)，请联系开发者添加支持)
endif

# ------------------------------------------------------------
# 下载源配置
# 来源: JGG-SH/VoCat (自动同步上游的 fork 仓库)
# 文件名格式: vocat-linux-{架构后缀}
# 示例: vocat-linux-arm64, vocat-linux-amd64
# 注意: 由于版本动态变化，无法预知哈希值，故跳过校验
# ------------------------------------------------------------
PKG_SOURCE_URL:=https://github.com/JGG-SH/VoCat/releases/download/v$(PKG_VERSION)
PKG_SOURCE:=vocat-linux-$(ARCH_SUFFIX)
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

# ------------------------------------------------------------
# 包定义: 提供给 OpenWrt 的包元信息
# 包名: vocat-core (不带架构后缀)
# TITLE: 显示实际架构信息 (如 VoCat core binary (arm64))
# ------------------------------------------------------------
define Package/vocat-core
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=VoCat core binary ($(ARCH_SUFFIX))
  URL:=https://github.com/MengMengCode/VoCat
  DEPENDS:=+curl +ca-bundle          # curl: 下载工具, ca-bundle: SSL 证书
  PKGARCH:=all                        # 所有架构通用 (因为二进制下载是动态的)
endef

define Package/vocat-core/description
  VoCat 核心二进制文件，编译时从 JGG-SH/VoCat 的 Release 动态下载。
  版本: v$(PKG_VERSION) ($(ARCH_SUFFIX))
  来源: https://github.com/JGG-SH/VoCat
endef

# ------------------------------------------------------------
# 准备阶段: 将下载的二进制文件复制到构建目录并设置执行权限
# 为什么要独立出 Build/Prepare:
#   1. 确保二进制文件存在，避免后续步骤因文件缺失而失败
#   2. 提前设置 +x 权限，解决 Permission denied 问题
#   3. 将文件从 DL_DIR 迁移到 PKG_BUILD_DIR，便于统一管理
# ------------------------------------------------------------
define Build/Prepare
  mkdir -p $(PKG_BUILD_DIR)
  if [ -f "$(DL_DIR)/$(PKG_SOURCE)" ]; then \
    cp $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/vocat; \
    chmod +x $(PKG_BUILD_DIR)/vocat; \
  else \
    echo "错误: $(PKG_SOURCE) 未在 $(DL_DIR) 中找到"; \
    echo "请检查版本 v$(PKG_VERSION) 是否存在于 JGG-SH/VoCat 的 Release 中"; \
    exit 1; \
  fi
endef

# ------------------------------------------------------------
# 编译阶段: 无需编译，仅验证二进制文件存在
# （Go 已预编译为二进制，直接使用即可）
# ------------------------------------------------------------
define Build/Compile
  # 空操作，仅用于验证文件存在
  [ -f "$(PKG_BUILD_DIR)/vocat" ] || { echo "vocat 二进制文件缺失，请检查 Build/Prepare"; exit 1; }
endef

# ------------------------------------------------------------
# 安装阶段: 将文件安装到最终固件中的目标位置
# 安装路径: /opt/vocat/bin/vocat (VoCat 默认路径)
# 额外文件:
#   version - 记录当前安装的版本号，便于升级时判断
#   arch    - 记录当前安装的架构，便于排查问题
# ------------------------------------------------------------
define Package/vocat-core/install
	$(INSTALL_DIR) $(1)/opt/vocat/bin $(1)/opt/vocat/data
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/vocat $(1)/opt/vocat/bin/vocat
	echo "$(PKG_VERSION)" > $(1)/opt/vocat/bin/version
	echo "$(ARCH_SUFFIX)" > $(1)/opt/vocat/bin/arch
endef

# ------------------------------------------------------------
# 后安装脚本: 在 opkg 安装完成后执行
# 功能:
#   1. 创建数据目录 /opt/vocat/data (若不存在)
#   2. 如果 vocat 服务正在运行，自动重启以加载新版本
# ------------------------------------------------------------
define Package/vocat-core/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	mkdir -p /opt/vocat/data
	if [ -x /etc/init.d/vocat ] && /etc/init.d/vocat running >/dev/null 2>&1; then
		/etc/init.d/vocat restart || true
	fi
}
exit 0
endef

# ------------------------------------------------------------
# 生成最终 .ipk 包
# ------------------------------------------------------------
$(eval $(call BuildPackage,vocat-core))
