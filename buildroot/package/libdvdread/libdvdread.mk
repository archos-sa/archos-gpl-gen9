#############################################################
#
# libdvdread
#
#############################################################
LIBDVDREAD_VERSION:=4.1.3
LIBDVDREAD_SOURCE:=libdvdread-$(LIBDVDREAD_VERSION).tar.bz2
LIBDVDREAD_SITE:=
LIBDVDREAD_DIR:=$(BUILD_DIR)/libdvdread-$(LIBDVDREAD_VERSION)
LIBDVDREAD_CAT:=$(BZCAT)
LIBDVDREAD_BINARY:=libdvdread
LIBDVDREAD_TARGET_BINARY:=usr/bin/libdvdread

#$(DL_DIR)/$(LIBDVDREAD_SOURCE):
#	$(LIBDVDREAD) -P $(DL_DIR) $(LIBDVDREAD_SITE)/$(LIBDVDREAD_SOURCE)

$(LIBDVDREAD_DIR)/.unpacked: $(DL_DIR)/$(LIBDVDREAD_SOURCE)
	$(LIBDVDREAD_CAT) $(DL_DIR)/$(LIBDVDREAD_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $(LIBDVDREAD_DIR)/.unpacked

$(LIBDVDREAD_DIR)/.configured: $(LIBDVDREAD_DIR)/.unpacked
	(cd $(LIBDVDREAD_DIR); \
		./autogen.sh \
		rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
	)
	touch $(LIBDVDREAD_DIR)/.configured

$(LIBDVDREAD_DIR)/.compiled: $(LIBDVDREAD_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(LIBDVDREAD_DIR)
	touch $(LIBDVDREAD_DIR)/.compiled

$(LIBDVDREAD_DIR)/.installed: $(LIBDVDREAD_DIR)/.compiled
	$(MAKE) -C $(LIBDVDREAD_DIR) \
		prefix=$(STAGING_DIR) \
		libdir=$(STAGING_DIR)/usr/lib \
		install
	cp -dpf $(STAGING_DIR)/usr/lib/libdvdread.so* $(TARGET_DIR)/usr/lib/
	touch $(LIBDVDREAD_DIR)/.installed

libdvdread: uclibc $(LIBDVDREAD_DIR)/.installed

libdvdread-clean:
	rm -f $(TARGET_DIR)/$(LIBDVDREAD_TARGET_BINARY)
	-$(MAKE) -C $(LIBDVDREAD_DIR) clean

libdvdread-dirclean:
	rm -rf $(LIBDVDREAD_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBDVDREAD)),y)
TARGETS+=libdvdread
endif
