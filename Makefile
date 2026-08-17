#
# Copyright (C) 2024-2025 JGG-SH
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-vocat
PKG_VERSION:=0.1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=JGG-SH

LUCI_TITLE:=LuCI interface for VoCat
LUCI_DEPENDS:=+vocat-core +luci-base +luci-compat +curl +ca-bundle

include $(TOPDIR)/feeds/luci/luci.mk

# 调用 LuCI 的默认构建规则
include $(INCLUDE_DIR)/package.mk

# 如果没有 feeds/luci/luci.mk，使用通用规则
define Package/luci-app-vocat
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=VoCat LuCI interface
  DEPENDS:=+vocat-core +luci-base +luci-compat +curl +ca-bundle
  PKGARCH:=all
endef

define Package/luci-app-vocat/description
  LuCI interface for VoCat - a web control panel for cellular modules.
  This package provides the web interface only.
  The core binary is provided by the vocat-core package.
endef

# 无需编译（Lua/JS 脚本直接安装）
define Build/Compile
endef

# 安装 LuCI 界面文件
define Package/luci-app-vocat/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	[ -d ./luasrc/view ] && cp -r ./luasrc/view/* $(1)/usr/lib/lua/luci/view/ || true
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	[ -d ./luasrc/i18n ] && cp -r ./luasrc/i18n/* $(1)/usr/lib/lua/luci/i18n/ || true
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view
	[ -d ./htdocs ] && cp -r ./htdocs/* $(1)/www/luci-static/resources/view/ || true
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./root/etc/config/vocat $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/vocat $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/usr/share/vocat
	[ -d ./root/usr/share/vocat ] && cp -r ./root/usr/share/vocat/* $(1)/usr/share/vocat/ || true
endef

# 后安装脚本（可选）
define Package/luci-app-vocat/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# 重启 rpcd 使 LuCI 菜单生效
	/etc/init.d/rpcd restart >/dev/null 2>&1 || true
	if [ -x /etc/init.d/vocat ]; then
		/etc/init.d/vocat enable >/dev/null 2>&1 || true
	fi
}
exit 0
endef

define Package/luci-app-vocat/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	if [ -x /etc/init.d/vocat ]; then
		/etc/init.d/vocat disable >/dev/null 2>&1 || true
		/etc/init.d/vocat stop >/dev/null 2>&1 || true
	fi
}
exit 0
endef

$(eval $(call BuildPackage,luci-app-vocat))
