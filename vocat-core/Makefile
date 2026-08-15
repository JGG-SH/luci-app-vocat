include $(TOPDIR)/rules.mk

PKG_NAME:=vocat-core
VOCAT_VERSION?=v0.1.16
PKG_VERSION:=$(patsubst v%,%,$(VOCAT_VERSION))
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=MengMengCode
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/vocat-core/Default
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=
  PKGARCH:=all
endef

define Package/vocat-core-arm64
  $(call Package/vocat-core/Default)
  TITLE:=VoCat core binary (arm64)
  CONFLICTS:=vocat-core vocat-core-amd64 vocat-core-armv7
endef

define Package/vocat-core-amd64
  $(call Package/vocat-core/Default)
  TITLE:=VoCat core binary (amd64)
  CONFLICTS:=vocat-core vocat-core-arm64 vocat-core-armv7
endef

define Package/vocat-core-armv7
  $(call Package/vocat-core/Default)
  TITLE:=VoCat core binary (armv7)
  CONFLICTS:=vocat-core vocat-core-arm64 vocat-core-amd64
endef

define Package/vocat-core-arm64/description
  Preinstalled VoCat linux-aarch64 core binary for luci-app-vocat.
endef

define Package/vocat-core-amd64/description
  Preinstalled VoCat linux-amd64 core binary for luci-app-vocat.
endef

define Package/vocat-core-armv7/description
  Preinstalled VoCat linux-armv7 core binary for luci-app-vocat.
endef

define Build/Compile
endef

define Package/vocat-core/install
	$(INSTALL_DIR) $(1)/opt/vocat/bin $(1)/opt/vocat/data
	$(INSTALL_BIN) ./files/vocat-linux-$(2) $(1)/opt/vocat/bin/vocat
	echo "$(VOCAT_VERSION)" > $(1)/opt/vocat/bin/version
	echo "$(3)" > $(1)/opt/vocat/bin/arch
endef

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

define Package/vocat-core-arm64/install
	$(call Package/vocat-core/install,$(1),aarch64,arm64)
endef

define Package/vocat-core-amd64/install
	$(call Package/vocat-core/install,$(1),amd64,amd64)
endef

define Package/vocat-core-armv7/install
	$(call Package/vocat-core/install,$(1),armv7,armv7)
endef

define Package/vocat-core-arm64/postinst
$(Package/vocat-core/postinst)
endef

define Package/vocat-core-amd64/postinst
$(Package/vocat-core/postinst)
endef

define Package/vocat-core-armv7/postinst
$(Package/vocat-core/postinst)
endef

$(eval $(call BuildPackage,vocat-core-arm64))
$(eval $(call BuildPackage,vocat-core-amd64))
$(eval $(call BuildPackage,vocat-core-armv7))
