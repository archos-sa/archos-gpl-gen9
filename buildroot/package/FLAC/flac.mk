FLAC_VERSION:=1.2.1
FLAC_SOURCE:=flac-$(FLAC_VERSION).tar.gz
FLAC_SITE:=
FLAC_CAT:=$(ZCAT)
FLAC_DIR:=$(BUILD_DIR)/flac-$(FLAC_VERSION)

$(DL_DIR)/$(FLAC_SOURCE):
	$(WGET) -P $(DL_DIR) $(FLAC_SITE)/$(FLAC_SOURCE)

flac-source: $(DL_DIR)/$(FLAC_SOURCE)

$(FLAC_DIR)/.patched: $(DL_DIR)/$(FLAC_SOURCE)
	$(FLAC_CAT) $(DL_DIR)/$(FLAC_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(FLAC_DIR) package/FLAC/ flac\*.patch
	touch $(FLAC_DIR)/.patched

$(FLAC_DIR)/.configured: $(FLAC_DIR)/.patched
	(cd $(FLAC_DIR); rm -rf config.cache; \
	$(TARGET_CONFIGURE_ARGS) \
	$(TARGET_CONFIGURE_OPTS) \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--prefix=$(STAGING_DIR)/usr \
	--sysconfdir=/etc \
	--disable-cpplibs \
	--disable-xmms-plugin \
	)
	touch $(FLAC_DIR)/.configured

$(FLAC_DIR)/.compiled: $(FLAC_DIR)/.configured
	$(MAKE) -C $(FLAC_DIR)
	touch $(FLAC_DIR)/.compiled

$(STAGING_DIR)/lib/libFLAC.so: $(FLAC_DIR)/.compiled
	$(MAKE) -C $(FLAC_DIR) \
		prefix=$(STAGING_DIR) \
		sysconfdir=$(STAGING_DIR)/etc \
		libdir=$(STAGING_DIR)/lib \
		-lgettext -lintl\
		install

$(TARGET_DIR)/lib/libFLAC.so: $(STAGING_DIR)/lib/libFLAC.so
	cp -dpf $(STAGING_DIR)/lib/libFLAC.so* $(TARGET_DIR)/lib/

flac: uclibc gettext libogg $(TARGET_DIR)/lib/libFLAC.so 

flac-build: uclibc $(FLAC_DIR)/.configured
	rm -f $(FLAC_DIR)/.compiled
	$(MAKE) -C $(FLAC_DIR)
	touch $(FLAC_DIR)/.compiled

flac-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(FLAC_DIR) uninstall
	rm -f $(STAGING_DIR)/usr/dir/flac
	-$(MAKE) -C $(FLAC_DIR) clean

flac-dirclean:
	rm -fr $(TARGET_DIR)/usr/lib/flac
	rm -rf $(FLAC_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_FLAC)),y)
TARGETS+=flac
endif
