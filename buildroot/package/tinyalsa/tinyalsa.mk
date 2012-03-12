#############################################################
#
# tinyalsa
#
#############################################################
# Copyright (C) 2012 by Niklas Schroeter <schroeter@archos.com>

TINYALSA_VERSION:=e85d805
TINYALSA_DIR:=$(BUILD_DIR)/tinyalsa-tinyalsa-$(TINYALSA_VERSION)
TINYALSA_SITE:=https://github.com/tinyalsa/tinyalsa/tarball
TINYALSA_SOURCE:=tinyalsa-tinyalsa-$(TINYALSA_VERSION).tar.gz
TINYALSA_CAT:=$(ZCAT)
TINYALSA_LIB:=libtinyalsa.so

$(DL_DIR)/$(TINYALSA_SOURCE):
	 $(WGET) -P $(DL_DIR) $(TINYALSA_SITE)/$(TINYALSA_VERSION)
	 mv $(DL_DIR)/$(TINYALSA_VERSION) $(DL_DIR)/$(TINYALSA_SOURCE)

tinyalsa-source: $(DL_DIR)/$(TINYALSA_SOURCE)

$(TINYALSA_DIR)/.unpacked: $(DL_DIR)/$(TINYALSA_SOURCE)
	$(TINYALSA_CAT) $(DL_DIR)/$(TINYALSA_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(TINYALSA_DIR) package/tinyalsa tinyalsa\*.patch
	$(CONFIG_UPDATE) $(TINYALSA_DIR)
	touch $@

$(TINYALSA_DIR)/$(TINYALSA_LIB): $(TINYALSA_DIR)/.unpacked
	$(MAKE) CC="$(TARGET_CC)" \
		-C $(TINYALSA_DIR) 

$(STAGING_DIR)/usr/include/tinyalsa/asoundlib.h: $(TINYALSA_DIR)/include/tinyalsa/asoundlib.h
	$(INSTALL) -D $< $@

$(STAGING_DIR)/usr/lib/$(TINYALSA_LIB): $(TINYALSA_DIR)/$(TINYALSA_LIB)
	cp -f $< $@

$(TARGET_DIR)/usr/lib/$(TINYALSA_LIB): $(TINYALSA_DIR)/$(TINYALSA_LIB)
	cp -f $< $@
	$(STRIPCMD) $@

tinyalsa: uclibc $(TARGET_DIR)/usr/lib/$(TINYALSA_LIB) $(STAGING_DIR)/usr/lib/$(TINYALSA_LIB) $(STAGING_DIR)/usr/include/tinyalsa/asoundlib.h

tinyalsa-clean:
	rm -f $(TARGET_DIR)/usr/lib/$(TINYALSA_LIB)
	-$(MAKE) -C $(TINYALSA_DIR) clean

tinyalsa-dirclean:
	rm -rf $(TINYALSA_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_TINYALSA)),y)
TARGETS+=tinyalsa
endif
