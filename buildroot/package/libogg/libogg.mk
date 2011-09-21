LIBOGG_VERSION:=1.3.0
LIBOGG_SOURCE:=libogg-$(LIBOGG_VERSION).tar.gz
LIBOGG_SITE:=
LIBOGG_CAT:=$(ZCAT)
LIBOGG_DIR:=$(BUILD_DIR)/libogg-$(LIBOGG_VERSION)

$(DL_DIR)/$(LIBOGG_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBOGG_SITE)/$(LIBOGG_SOURCE)

libogg-source: $(DL_DIR)/$(LIBOGG_SOURCE)

$(LIBOGG_DIR)/.patched: $(DL_DIR)/$(LIBOGG_SOURCE)
	$(LIBOGG_CAT) $(DL_DIR)/$(LIBOGG_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(LIBOGG_DIR) package/libogg/ libogg\*.patch
	touch $(LIBOGG_DIR)/.patched

$(LIBOGG_DIR)/.configured: $(LIBOGG_DIR)/.patched
	(cd $(LIBOGG_DIR); rm -rf config.cache; \
	$(TARGET_CONFIGURE_ARGS) \
	$(TARGET_CONFIGURE_OPTS) \
	./configure \
	--host=$(GNU_TARGET_NAME) \
	--prefix=$(STAGING_DIR)/usr \
	--sysconfdir=/etc \
	)
	touch $(LIBOGG_DIR)/.configured

$(LIBOGG_DIR)/.compiled: $(LIBOGG_DIR)/.configured
	$(MAKE) -C $(LIBOGG_DIR)
	touch $(LIBOGG_DIR)/.compiled

$(STAGING_DIR)/lib/libogg.so: $(LIBOGG_DIR)/.compiled
	$(MAKE) -C $(LIBOGG_DIR) \
		prefix=$(STAGING_DIR) \
		sysconfdir=$(STAGING_DIR)/etc \
		libdir=$(STAGING_DIR)/lib \
		-lgettext -lintl\
		install

$(TARGET_DIR)/lib/libogg.so: $(STAGING_DIR)/lib/libogg.so
	cp -dpf $(STAGING_DIR)/lib/libogg.so* $(TARGET_DIR)/lib/

libogg: uclibc gettext $(TARGET_DIR)/lib/libogg.so

libogg-build: uclibc $(LIBOGG_DIR)/.configured
	rm -f $(LIBOGG_DIR)/.compiled
	$(MAKE) -C $(LIBOGG_DIR)
	touch $(LIBOGG_DIR)/.compiled

libogg-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(LIBOGG_DIR) uninstall
	rm -f $(STAGING_DIR)/usr/dir/libogg
	-$(MAKE) -C $(LIBOGG_DIR) clean

libogg-dirclean:
	rm -fr $(TARGET_DIR)/usr/lib/libogg
	rm -rf $(LIBOGG_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBOGG)),y)
TARGETS+=libogg
endif
