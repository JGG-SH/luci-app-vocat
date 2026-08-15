include $(TOPDIR)/rules.mk

PKG_NAME:=vocat-core
VOCAT_VERSION?=0.1.16
PKG_VERSION:=$(VOCAT_VERSION)
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=MengMengCode

# 二进制唯一来源：JGG-SH/VoCat 是上游 MengMengCode/VoCat 的 fork，
# 通过 GitHub Actions 自动同步 Release（保持最新 + 防作者跑路清库）。
# 编译时从 fork 的 Release 动态下载，无需手动把二进制塞进本仓库。
# 单文件（无扩展名）不解包，直接从 DL_DIR 取。
PKG_SOURCE_URL:=https://github.com/JGG-SH/VoCat/releases/download/v$(PKG_VERSION)
PKG_SOURCE:=vocat-linux-aarch64
PKG_HASH:=3a56ea7ca1bf881259fce63a62f4800e8956716875d1d02a74da5975cf42d520

include $(INCLUDE_DIR)/package.mk

define Package/vocat-core-arm64
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=VoCat core binary (arm64)
  URL:=https://github.com/MengMengCode/VoCat
  PKGARCH:=all
endef

define Package/vocat-core-arm64/description
  VoCat linux-aarch64 core binary, downloaded at build time from the
  JGG-SH/VoCat fork release.
endef

define Build/Compile
endef

define Package/vocat-core-arm64/install
	$(INSTALL_DIR) $(1)/opt/vocat/bin $(1)/opt/vocat/data
	$(INSTALL_BIN) $(DL_DIR)/$(PKG_SOURCE) $(1)/opt/vocat/bin/vocat
	echo "$(PKG_VERSION)" > $(1)/opt/vocat/bin/version
	echo "arm64" > $(1)/opt/vocat/bin/arch
endef

define Package/vocat-core-arm64/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	mkdir -p /opt/vocat/data
	if [ -x /etc/init.d/vocat ] && /etc/init.d/vocat running >/dev/null 2>&1; then
		/etc/init.d/vocat restart || true
	fi
}
exit 0
endef

$(eval $(call BuildPackage,vocat-core-arm64))
