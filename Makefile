ROUTER ?= 192.168.10.1
SSH ?= ssh
SCP ?= scp
REMOTE ?= root@$(ROUTER)
PKG_DIR ?= bin/packages
CORE_ARCH ?= arm64

.PHONY: deploy deploy-core

deploy:
	$(SCP) $$(find $(PKG_DIR) -name 'luci-app-vocat_*.ipk' | head -n 1) $(REMOTE):/tmp/
	$(SSH) $(REMOTE) 'opkg install /tmp/luci-app-vocat_*.ipk'

deploy-core:
	$(SCP) $$(find $(PKG_DIR) -name 'vocat-core-$(CORE_ARCH)_*.ipk' | head -n 1) $(REMOTE):/tmp/
	$(SSH) $(REMOTE) 'opkg install /tmp/vocat-core-$(CORE_ARCH)_*.ipk'
