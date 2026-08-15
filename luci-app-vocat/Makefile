include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-vocat
PKG_VERSION?=0.1.16
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=JGG-SH
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-vocat
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for VoCat
  DEPENDS:=+luci-base +rpcd +rpcd-mod-file +curl +ca-bundle +jsonfilter
  PKGARCH:=all
endef

define Package/luci-app-vocat/description
  LuCI management page for controlling VoCat (start/stop/restart, driver integrity, status).
endef

define Build/Compile
endef

define Package/luci-app-vocat/conffiles
/etc/config/vocat
endef

define Package/luci-app-vocat/install
	$(CP) ./root/* $(1)/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/vocat
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/vocat/index.js $(1)/www/luci-static/resources/view/vocat/index.js
	$(INSTALL_DIR) $(1)/usr/share/vocat
	echo "$(PKG_VERSION)" > $(1)/usr/share/vocat/plugin_version
endef

define Package/luci-app-vocat/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	mkdir -p /opt/vocat/data /etc/vocat
	if [ -x /etc/init.d/rpcd ]; then
		/etc/init.d/rpcd reload >/dev/null 2>&1 || /etc/init.d/rpcd restart >/dev/null 2>&1 || true
	fi
}
exit 0
endef

$(eval $(call BuildPackage,luci-app-vocat))
