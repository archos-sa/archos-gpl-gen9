ifeq ($(ARCH),arm)
#############################################################
#
# libav_arm
#
#############################################################
LIBAV_ARM_SOURCE_DIR=../packages/libav
LIBAV_ARM_CAT:=$(ZCAT)
LIBAV_ARM_DIR:=$(BUILD_DIR)/libav_arm

LIBAV_ARM_LIBAVCODEC_REV=54
LIBAV_ARM_LIBAVFORMAT_REV=54
LIBAV_ARM_LIBAVUTIL_REV=51

include $(LIBAV_ARM_SOURCE_DIR)/configure_common.mk

$(LIBAV_ARM_DIR)/.unpacked: 
	mkdir -p $(LIBAV_ARM_DIR)
	touch $@

$(LIBAV_ARM_DIR)/.configured: $(LIBAV_ARM_DIR)/.unpacked
	(cd $(LIBAV_ARM_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		../../$(LIBAV_ARM_SOURCE_DIR)/configure \
		--arch=$(ARCH) \
		--cc=$(TARGET_CC) \
		--target-os=linux \
		--enable-cross-compile \
		--extra-cflags="-fPIC -DPIC -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp" \
		--prefix=/usr  \
		--libdir=/usr/lib \
		${CONFIG_LIBAV} \
		--disable-avconv --disable-avplay --disable-avserver --disable-avprobe \
	)
	touch $@

$(LIBAV_ARM_DIR)/.compiled: $(LIBAV_ARM_DIR)/.configured
	$(MAKE) -C $(LIBAV_ARM_DIR)
	touch $@

$(TARGET_DIR)/usr/lib/libavcodec.so.$(LIBAV_ARM_LIBAVCODEC_REV): $(LIBAV_ARM_DIR)/.compiled
	cp $(LIBAV_ARM_DIR)/libavcodec/libavcodec.so.$(LIBAV_ARM_LIBAVCODEC_REV) $@
	rm -f $(TARGET_DIR)/usr/lib/libavcodec.so && ln -s $(@F) $(TARGET_DIR)/usr/lib/libavcodec.so

$(TARGET_DIR)/usr/lib/libavformat.so.$(LIBAV_ARM_LIBAVFORMAT_REV): $(LIBAV_ARM_DIR)/.compiled
	cp $(LIBAV_ARM_DIR)/libavformat/libavformat.so.$(LIBAV_ARM_LIBAVFORMAT_REV) $@
	rm -f $(TARGET_DIR)/usr/lib/libavformat.so && ln -s $(@F) $(TARGET_DIR)/usr/lib/libavformat.so

$(TARGET_DIR)/usr/lib/libavutil.so.$(LIBAV_ARM_LIBAVUTIL_REV): $(LIBAV_ARM_DIR)/.compiled
	cp $(LIBAV_ARM_DIR)/libavutil/libavutil.so.$(LIBAV_ARM_LIBAVUTIL_REV) $@
	rm -f $(TARGET_DIR)/usr/lib/libavutil.so && ln -s $(@F) $(TARGET_DIR)/usr/lib/libavutil.so

$(LIBAV_ARM_DIR)/.installed: $(TARGET_DIR)/usr/lib/libavcodec.so.$(LIBAV_ARM_LIBAVCODEC_REV) $(TARGET_DIR)/usr/lib/libavformat.so.$(LIBAV_ARM_LIBAVFORMAT_REV) $(TARGET_DIR)/usr/lib/libavutil.so.$(LIBAV_ARM_LIBAVUTIL_REV)
	DESTDIR=$(STAGING_DIR) $(MAKE) -C $(LIBAV_ARM_DIR) install
	touch $@

libav_arm: uclibc $(LIBAV_ARM_DIR)/.installed

libav_arm-clean:
	-$(MAKE) -C $(LIBAV_ARM_DIR) clean

libav_arm-dirclean:
	rm -rf $(LIBAV_ARM_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBAV_ARM)),y)
TARGETS+=libav_arm
endif
endif
