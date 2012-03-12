#############################################################
#
# lsdvd
#
#############################################################
LSDVD_VERSION:=0.16
LSDVD_SOURCE:=lsdvd-$(LSDVD_VERSION).tar.gz
LSDVD_SITE:=
LSDVD_DIR:=$(BUILD_DIR)/lsdvd-$(LSDVD_VERSION)
LSDVD_CAT:=$(ZCAT)
LSDVD_BINARY:=lsdvd
LSDVD_TARGET_BINARY:=usr/bin/lsdvd

#$(DL_DIR)/$(LSDVD_SOURCE):
#	$(LSDVD) -P $(DL_DIR) $(LSDVD_SITE)/$(LSDVD_SOURCE)

$(LSDVD_DIR)/.unpacked: $(DL_DIR)/$(LSDVD_SOURCE)
	$(LSDVD_CAT) $(DL_DIR)/$(LSDVD_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(LSDVD_DIR) package/lsdvd/ \*.patch
	touch $(LSDVD_DIR)/.unpacked

$(LSDVD_DIR)/.configured: $(LSDVD_DIR)/.unpacked
	(cd $(LSDVD_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/ \
	)
	touch $(LSDVD_DIR)/.configured

$(LSDVD_DIR)/$(LSDVD_BINARY): $(LSDVD_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(LSDVD_DIR)

$(TARGET_DIR)/$(LSDVD_TARGET_BINARY): $(LSDVD_DIR)/$(LSDVD_BINARY)
	install -D $(LSDVD_DIR)/$(LSDVD_BINARY) $(TARGET_DIR)/$(LSDVD_TARGET_BINARY)

lsdvd: uclibc libdvdread $(TARGET_DIR)/$(LSDVD_TARGET_BINARY)

lsdvd-clean:
	rm -f $(TARGET_DIR)/$(LSDVD_TARGET_BINARY)
	-$(MAKE) -C $(LSDVD_DIR) clean

lsdvd-dirclean:
	rm -rf $(LSDVD_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LSDVD)),y)
TARGETS+=lsdvd
endif
