#############################################################
#
# minidlna
#
#############################################################
MINIDLNA_VERSION:=1.0.22
MINIDLNA_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/minidlna
MINIDLNA_SOURCE:=minidlna_$(MINIDLNA_VERSION)_src.tar.gz
MINIDLNA_DIR=$(BUILD_DIR)/minidlna-$(MINIDLNA_VERSION)
MINIDLNA_INSTALL_STAGING = YES
MINIDLNA_DEPENDENCIES = sqlite libid3tag jpeg flac libogg libvorbis libexif
MINIDLNA_CAT=$(ZCAT)



$(DL_DIR)/$(MINIDLNA_SOURCE):
	    $(WGET) -P $(DL_DIR) $(MINIDLNA_SITE)/$(MINIDLNA_SOURCE)


$(MINIDLNA_DIR)/.patched: $(DL_DIR)/$(MINIDLNA_SOURCE) 
	$(MINIDLNA_CAT) $(DL_DIR)/$(MINIDLNA_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(MINIDLNA_DIR) package/minidlna/ minidlna\*.patch
	touch $(MINIDLNA_DIR)/.patched

$(MINIDLNA_DIR)/.compiled: $(MINIDLNA_DIR)/.patched
	$(TARGET_CONFIGURE_ARGS) \
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(MINIDLNA_DIR) STAGING_DIR="$(STAGING_DIR)" CC="$(TARGET_CC)" -I$(STAGING_DIR)/include/
	touch $(MINIDLNA_DIR)/.compiled

$(STAGING_DIR)/usr/bin/minidlna: $(MINIDLNA_DIR)/.compiled
	$(MAKE) -C $(MINIDLNA_DIR) STAGING_DIR="$(STAGING_DIR)"\
		install

$(TARGET_DIR)/usr/bin/minidlna: $(STAGING_DIR)/usr/bin/minidlna
	cp -dpf $(STAGING_DIR)/sbin/minidlna $(TARGET_DIR)/usr/bin/

minidlna :$(MINIDLNA_DEPENDENCIES) $(TARGET_DIR)/usr/bin/minidlna

minidlna-clean:
	$(MAKE) -C $(MINIDLNA_DIR) clean
	rm -f $(TARGET_DIR)/usr/bin/minidlna $(STAGING_DIR)/usr/bin/minidlna

minidlna-dirclean: minidlna-clean
	rm -fr $(MINIDLNA_DIR)/

ifeq ($(strip $(BR2_PACKAGE_MINIDLNA)),y)
TARGETS+=minidlna
endif


