#############################################################
#
# wpa_supplicant_tiwlan
#
#############################################################
WPA_SUPPLICANT_TIWLAN_TARGET_NAME = wpa_supplicant_tiwlan

WPA_SUPPLICANT_TIWLAN_VERSION:=0.5
WPA_SUPPLICANT_TIWLAN_SUBVER:=10

WPA_SUPPLICANT_TIWLAN_SOURCE:=wpa_supplicant-$(WPA_SUPPLICANT_TIWLAN_VERSION).$(WPA_SUPPLICANT_TIWLAN_SUBVER).tar.gz
WPA_SUPPLICANT_TIWLAN_BUILD_DIR=$(BUILD_DIR)/wpa_supplicant-$(WPA_SUPPLICANT_TIWLAN_VERSION).$(WPA_SUPPLICANT_TIWLAN_SUBVER)

$(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.unpacked: 
	$(ZCAT) $(DL_DIR)/$(WPA_SUPPLICANT_TIWLAN_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR) $(TOPDIR)/../arcbuild/packages/wpa_supplicant_0_5_x/ \*.patch
	sed -i -e s:'strip':'$(STRIPCMD)':g $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/Makefile
	touch $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.unpacked

$(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.configured: $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.unpacked
	(cd $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR); \
	cp $(TOPDIR)../../../arcbuild/packages/wpa_supplicant_0_5_x/.config .)
	touch $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.configured

$(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME): $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.configured
	$(MAKE) -C $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR) \
		CC=$(TARGET_CC) \
		CROSS_COMPILE=$(subst gcc,,$(TARGET_CC)) \
		TI_WLAN_DRIVER=y
	mv $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/wpa_supplicant $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME)

$(TARGET_DIR)/usr/sbin/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME): $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME)
	rm -f $(TARGET_DIR)/sbin/wpa_supplicant
	rm -f $(TARGET_DIR)/usr/sbin/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME)
	mkdir -p $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME) $(TARGET_DIR)/usr/sbin/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME)

wpa_supplicant_tiwlan: uclibc $(TARGET_DIR)/usr/sbin/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME)
	rm -f $(STAGING_DIR)/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME)
	ln -s $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR) $(STAGING_DIR)/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME)

wpa_supplicant_tiwlan-source: $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.unpacked

wpa_supplicant_tiwlan-clean:
	-rm -rf $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.install/
	-$(MAKE) -C $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR) clean
	-rm $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)/.configured
	-rm $(TARGET_DIR)/usr/sbin/wpa_supplicant
	-rm $(TARGET_DIR)/usr/sbin/$(WPA_SUPPLICANT_TIWLAN_TARGET_NAME)

wpa_supplicant_tiwlan-dirclean:
	rm -rf $(WPA_SUPPLICANT_TIWLAN_BUILD_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_WPA_SUPPLICANT_TIWLAN)),y)
TARGETS+=wpa_supplicant_tiwlan
endif
