#############################################################
#
# audiocompress
#
#############################################################

AUDIOCOMPRESS_SOURCE_DIR:=../packages/audiocompress
AUDIOCOMPRESS_DIR:=$(BUILD_DIR)/audiocompress

AUDIOCOMPRESS_TARGET_DIR:=$(TARGET_DIR)

$(AUDIOCOMPRESS_DIR)/.unpacked:
	cp -a $(AUDIOCOMPRESS_SOURCE_DIR) $(BUILD_DIR)
	-$(MAKE) -C $(AUDIOCOMPRESS_DIR) clean
	touch $(AUDIOCOMPRESS_DIR)/.unpacked

$(AUDIOCOMPRESS_DIR)/.compiled: $(AUDIOCOMPRESS_DIR)/.unpacked
	$(MAKE) -C $(AUDIOCOMPRESS_DIR) ARCH=arm CROSS=$(TARGET_CROSS) REL=$(ARCHOS_CONFIG_FLAG) arm/audiocompress.so
	touch $(AUDIOCOMPRESS_DIR)/.compiled

$(AUDIOCOMPRESS_TARGET_DIR)/usr/lib/libaudiocompress.so: $(AUDIOCOMPRESS_DIR)/.compiled
	cp -dpf $(AUDIOCOMPRESS_DIR)/arm/audiocompress.so $(STAGING_DIR)/usr/lib/libaudiocompress.so
	cp -dpf $(AUDIOCOMPRESS_DIR)/arm/audiocompress.so $(AUDIOCOMPRESS_TARGET_DIR)/usr/lib/libaudiocompress.so

audiocompress: uclibc $(AUDIOCOMPRESS_TARGET_DIR)/usr/lib/libaudiocompress.so

audiocompress-clean:
	-$(MAKE) -C $(AUDIOCOMPRESS_DIR) clean
	-rm $(AUDIOCOMPRESS_DIR)/.unpacked
	-rm $(AUDIOCOMPRESS_TARGET_DIR)/usr/lib/libaudiocompress.so
	-rm $(STAGING_DIR)/usr/lib/libaudiocompress.so

audiocompress-dirclean:
	rm -rf $(AUDIOCOMPRESS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_AUDIOCOMPRESS)),y)
TARGETS+=audiocompress
endif
