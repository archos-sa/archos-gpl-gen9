ifeq ($(ARCH),i586)
#############################################################
#
# libav
#
#############################################################
LIBAV_SOURCE_DIR=../packages/libav
LIBAV_CAT:=$(ZCAT)
LIBAV_DIR:=$(BUILD_DIR)/libav

LIBAV_LIBAVCODEC_REV=54
LIBAV_LIBAVFORMAT_REV=54
LIBAV_LIBAVUTIL_REV=51

$(LIBAV_DIR)/.unpacked: 
	mkdir -p $(LIBAV_DIR)
	touch $@

$(LIBAV_DIR)/.configured: $(LIBAV_DIR)/.unpacked
	(cd $(LIBAV_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		../../$(LIBAV_SOURCE_DIR)/configure \
		--arch=$(ARCH) \
		--cc=$(TARGET_CC) \
		--prefix=/usr  \
		--mandir=/usr/share/man \
		--libdir=/usr/lib \
		--enable-gpl  \
		--enable-shared \
		--disable-bzlib \
		--enable-nonfree \
		--disable-avconv --disable-avplay --disable-avprobe --disable-avserver \
	)
	touch $@

$(LIBAV_DIR)/.compiled: $(LIBAV_DIR)/.configured
	$(MAKE) -C $(LIBAV_DIR)
	touch $@

$(TARGET_DIR)/usr/lib/libavcodec.so.$(LIBAV_LIBAVCODEC_REV): $(LIBAV_DIR)/.compiled
	cp $(LIBAV_DIR)/libavcodec/libavcodec.so.$(LIBAV_LIBAVCODEC_REV) $@
	rm -f $(TARGET_DIR)/usr/lib/libavcodec.so && ln -s $(@F) $(TARGET_DIR)/usr/lib/libavcodec.so

$(TARGET_DIR)/usr/lib/libavformat.so.$(LIBAV_LIBAVFORMAT_REV): $(LIBAV_DIR)/.compiled
	cp $(LIBAV_DIR)/libavformat/libavformat.so.$(LIBAV_LIBAVFORMAT_REV) $@
	rm -f $(TARGET_DIR)/usr/lib/libavformat.so && ln -s $(@F) $(TARGET_DIR)/usr/lib/libavformat.so

$(TARGET_DIR)/usr/lib/libavutil.so.$(LIBAV_LIBAVUTIL_REV): $(LIBAV_DIR)/.compiled
	cp $(LIBAV_DIR)/libavutil/libavutil.so.$(LIBAV_LIBAVUTIL_REV) $@
	rm -f $(TARGET_DIR)/usr/lib/libavutil.so && ln -s $(@F) $(TARGET_DIR)/usr/lib/libavutil.so

$(LIBAV_DIR)/.installed: $(TARGET_DIR)/usr/lib/libavcodec.so.$(LIBAV_LIBAVCODEC_REV) $(TARGET_DIR)/usr/lib/libavformat.so.$(LIBAV_LIBAVFORMAT_REV) $(TARGET_DIR)/usr/lib/libavutil.so.$(LIBAV_LIBAVUTIL_REV)
	DESTDIR=$(STAGING_DIR) $(MAKE) -C $(LIBAV_DIR) install
	touch $@

libav: uclibc zlib $(LIBAV_DIR)/.installed

libav-clean:
	-$(MAKE) -C $(LIBAV_DIR) clean

libav-dirclean:
	rm -rf $(LIBAV_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBAV)),y)
TARGETS+=libav
endif
endif
