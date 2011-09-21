LIBEXIF_VERSION:=0.6.20
LIBEXIF_SOURCE:=libexif-$(LIBEXIF_VERSION).tar.gz
LIBEXIF_SITE:=
LIBEXIF_CAT:=$(ZCAT)
LIBEXIF_DIR:=$(BUILD_DIR)/libexif-$(LIBEXIF_VERSION)

$(DL_DIR)/$(LIBEXIF_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBEXIF_SITE)/$(LIBEXIF_SOURCE)

libexif-source: $(DL_DIR)/$(LIBEXIF_SOURCE)

$(LIBEXIF_DIR)/.patched: $(DL_DIR)/$(LIBEXIF_SOURCE)
	$(LIBEXIF_CAT) $(DL_DIR)/$(LIBEXIF_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(LIBEXIF_DIR) package/libexif/ libexif\*.patch
	touch $(LIBEXIF_DIR)/.patched

$(LIBEXIF_DIR)/.configured: $(LIBEXIF_DIR)/.patched
	(cd $(LIBEXIF_DIR); rm -rf config.cache; \
	$(TARGET_CONFIGURE_ARGS) \
	$(TARGET_CONFIGURE_OPTS) \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--prefix=$(STAGING_DIR)/usr \
	--sysconfdir=/etc \
	)
	touch $(LIBEXIF_DIR)/.configured

$(LIBEXIF_DIR)/.compiled: $(LIBEXIF_DIR)/.configured
	$(MAKE) -C $(LIBEXIF_DIR)
	touch $(LIBEXIF_DIR)/.compiled

$(STAGING_DIR)/lib/libexif.so: $(LIBEXIF_DIR)/.compiled
	$(MAKE) -C $(LIBEXIF_DIR) \
		prefix=$(STAGING_DIR) \
		sysconfdir=$(STAGING_DIR)/etc \
		libdir=$(STAGING_DIR)/usr/lib \
		-lgettext -lintl\
		install

$(TARGET_DIR)/lib/libexif.so: $(STAGING_DIR)/lib/libexif.so
	cp -dpf $(STAGING_DIR)/usr/lib/libexif.so* $(TARGET_DIR)/usr/lib/

libexif: uclibc gettext $(TARGET_DIR)/lib/libexif.so

libexif-build: uclibc $(LIBEXIF_DIR)/.configured
	rm -f $(LIBEXIF_DIR)/.compiled
	$(MAKE) -C $(LIBEXIF_DIR)
	touch $(LIBEXIF_DIR)/.compiled

libexif-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(LIBEXIF_DIR) uninstall
	rm -f $(STAGING_DIR)/usr/lib/libexif.so*
	-$(MAKE) -C $(LIBEXIF_DIR) clean

libexif-dirclean:
	rm -fr $(TARGET_DIR)/usr/lib/libexif
	rm -rf $(LIBEXIF_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBEXIF)),y)
TARGETS+=libexif
endif
