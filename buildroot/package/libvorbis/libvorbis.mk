LIBVORBIS_VERSION:=1.3.2
LIBVORBIS_SOURCE:=libvorbis-$(LIBVORBIS_VERSION).tar.gz
LIBVORBIS_SITE:=
LIBVORBIS_CAT:=$(ZCAT)
LIBVORBIS_DIR:=$(BUILD_DIR)/libvorbis-$(LIBVORBIS_VERSION)

$(DL_DIR)/$(LIBVORBIS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBVORBIS_SITE)/$(LIBVORBIS_SOURCE)

libvorbis-source: $(DL_DIR)/$(LIBVORBIS_SOURCE)

$(LIBVORBIS_DIR)/.patched: $(DL_DIR)/$(LIBVORBIS_SOURCE)
	$(LIBVORBIS_CAT) $(DL_DIR)/$(LIBVORBIS_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(LIBVORBIS_DIR) package/libvorbis/ libvorbis\*.patch
	touch $(LIBVORBIS_DIR)/.patched

$(LIBVORBIS_DIR)/.configured: $(LIBVORBIS_DIR)/.patched
	(cd $(LIBVORBIS_DIR); rm -rf config.cache; \
	$(TARGET_CONFIGURE_ARGS) \
	$(TARGET_CONFIGURE_OPTS) \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--prefix=$(STAGING_DIR)/usr \
	--sysconfdir=/etc \
	)
	touch $(LIBVORBIS_DIR)/.configured

$(LIBVORBIS_DIR)/.compiled: $(LIBVORBIS_DIR)/.configured
	$(MAKE) -C $(LIBVORBIS_DIR)
	touch $(LIBVORBIS_DIR)/.compiled

$(STAGING_DIR)/usr/lib/libvorbis.so: $(LIBVORBIS_DIR)/.compiled
	$(MAKE) -C $(LIBVORBIS_DIR) \
		prefix=$(STAGING_DIR) \
		sysconfdir=$(STAGING_DIR)/etc \
		libdir=$(STAGING_DIR)/usr/lib \
		-lgettext -lintl\
		install

$(TARGET_DIR)/lib/libvorbis.so: $(STAGING_DIR)/usr/lib/libvorbis.so
	cp -dpf $(STAGING_DIR)/usr/lib/libvorbis.so* $(TARGET_DIR)/lib/

libvorbis: uclibc gettext $(TARGET_DIR)/lib/libvorbis.so

libvorbis-build: uclibc $(LIBVORBIS_DIR)/.configured
	rm -f $(LIBVORBIS_DIR)/.compiled
	$(MAKE) -C $(LIBVORBIS_DIR)
	touch $(LIBVORBIS_DIR)/.compiled

libvorbis-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(LIBVORBIS_DIR) uninstall
	rm -f $(STAGING_DIR)/usr/dir/libvorbis
	-$(MAKE) -C $(LIBVORBIS_DIR) clean

libvorbis-dirclean:
	rm -fr $(TARGET_DIR)/usr/lib/libvorbis
	rm -rf $(LIBVORBIS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBVORBIS)),y)
TARGETS+=libvorbis
endif
