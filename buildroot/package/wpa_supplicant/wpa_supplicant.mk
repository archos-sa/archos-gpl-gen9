#############################################################
#
# wpa_supplicant
#
#############################################################
WPA_SUPPLICANT_TARGET_NAME = wpa_supplicant_marvell

WPA_SUPPLICANT_VERSION:=0.4
WPA_SUPPLICANT_SUBVER:=7

WPA_SUPPLICANT_SOURCE:=wpa_supplicant-$(WPA_SUPPLICANT_VERSION).$(WPA_SUPPLICANT_SUBVER).tar.gz
WPA_SUPPLICANT_BUILD_DIR=$(BUILD_DIR)/wpa_supplicant-$(WPA_SUPPLICANT_VERSION).$(WPA_SUPPLICANT_SUBVER)

$(WPA_SUPPLICANT_BUILD_DIR)/.unpacked: 
	$(ZCAT) $(DL_DIR)/$(WPA_SUPPLICANT_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(WPA_SUPPLICANT_BUILD_DIR) $(TOPDIR)/../arcbuild/packages/wpa_supplicant/ \*.patch
	sed -i -e s:'strip':'$(STRIPCMD)':g $(WPA_SUPPLICANT_BUILD_DIR)/Makefile
	touch $(WPA_SUPPLICANT_BUILD_DIR)/.unpacked

$(WPA_SUPPLICANT_BUILD_DIR)/.configured: $(WPA_SUPPLICANT_BUILD_DIR)/.unpacked
	(cd $(WPA_SUPPLICANT_BUILD_DIR); \
	echo "CONFIG_WIRELESS_EXTENSION=y" > .config; \
	echo "CONFIG_DRIVER_WEXT=y" >> .config; \
	echo "CONFIG_DRIVER_MARVELL=y" >> .config; \
	echo "CONFIG_EAP_PSK=y" >> .config; \
	echo "CONFIG_CTRL_IFACE=y" >> .config)
ifeq ("$(strip $(ARCH))","i586")
	(cd $(WPA_SUPPLICANT_BUILD_DIR); \
	echo "CONFIG_DRIVER_TEST=y" >> .config)
endif
	touch $(WPA_SUPPLICANT_BUILD_DIR)/.configured

$(WPA_SUPPLICANT_BUILD_DIR)/$(WPA_SUPPLICANT_TARGET_NAME): $(WPA_SUPPLICANT_BUILD_DIR)/.configured
	$(MAKE) -C $(WPA_SUPPLICANT_BUILD_DIR) \
		CC=$(TARGET_CC)
	mv $(WPA_SUPPLICANT_BUILD_DIR)/wpa_supplicant $(WPA_SUPPLICANT_BUILD_DIR)/$(WPA_SUPPLICANT_TARGET_NAME)

$(TARGET_DIR)/usr/sbin/$(WPA_SUPPLICANT_TARGET_NAME): $(WPA_SUPPLICANT_BUILD_DIR)/$(WPA_SUPPLICANT_TARGET_NAME)
	rm -f $(TARGET_DIR)/sbin/wpa_supplicant
	mkdir -p $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 $(WPA_SUPPLICANT_BUILD_DIR)/$(WPA_SUPPLICANT_TARGET_NAME) $(TARGET_DIR)/usr/sbin/

wpa_supplicant: uclibc $(TARGET_DIR)/usr/sbin/$(WPA_SUPPLICANT_TARGET_NAME)
	rm -f $(STAGING_DIR)/$(WPA_SUPPLICANT_TARGET_NAME)
	ln -s $(WPA_SUPPLICANT_BUILD_DIR) $(STAGING_DIR)/$(WPA_SUPPLICANT_TARGET_NAME)

wpa_supplicant-source: $(WPA_SUPPLICANT_BUILD_DIR)/.unpacked

wpa_supplicant-clean:
	-rm -rf $(WPA_SUPPLICANT_BUILD_DIR)/.install/
	-$(MAKE) -C $(WPA_SUPPLICANT_BUILD_DIR) clean
	-rm $(WPA_SUPPLICANT_BUILD_DIR)/.configured
	-rm $(TARGET_DIR)/usr/sbin/$(WPA_SUPPLICANT_TARGET_NAME)

wpa_supplicant-dirclean:
	rm -rf $(WPA_SUPPLICANT_BUILD_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_WPA_SUPPLICANT)),y)
TARGETS+=wpa_supplicant
endif
