#############################################################
#
# usb_modeswitch
#
#############################################################
USB_MODESWITCHVERSION:=1.1.5
USB_MODESWITCHSOURCE:=usb-modeswitch-$(USB_MODESWITCHVERSION).tar.bz2
USB_MODESWITCHSITE:=http://www.draisberghof.de/usb_modeswitch
USB_MODESWITCHCAT:=$(BZCAT)
USB_MODESWITCHDIR:=$(BUILD_DIR)/usb-modeswitch-$(USB_MODESWITCHVERSION)
USB_MODESWITCHBINARY:=usb_modeswitch

$(DL_DIR)/$(USB_MODESWITCHSOURCE):
	 $(WGET) -P $(DL_DIR) $(USB_MODESWITCHSITE)/$(USB_MODESWITCHSOURCE)

usb_modeswitch-source: $(DL_DIR)/$(USB_MODESWITCHSOURCE)

$(USB_MODESWITCHDIR)/.unpacked: $(DL_DIR)/$(USB_MODESWITCHSOURCE)
	$(USB_MODESWITCHCAT) $(DL_DIR)/$(USB_MODESWITCHSOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(USB_MODESWITCHDIR) package/usb_modeswitch/ \*.patch*
	touch $(USB_MODESWITCHDIR)/.unpacked

$(USB_MODESWITCHDIR)/$(USB_MODESWITCHBINARY): $(USB_MODESWITCHDIR)/.unpacked
	$(MAKE) -C $(USB_MODESWITCHDIR) LDFLAGS="-L$(STAGING_DIR)/lib -L$(STAGING_DIR)/usr/lib -Wl,-rpath-link,$(STAGING_DIR)/usr/lib " CC=$(TARGET_CC)
	touch $(USB_MODESWITCHDIR)/$(USB_MODESWITCHBINARY)


usb_modeswitch_copy: 
	cp -a $(USB_MODESWITCHDIR)/$(USB_MODESWITCHBINARY) $(TARGET_DIR)/usr/bin
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/bin/$(USB_MODESWITCHBINARY)


usb_modeswitch: uclibc $(USB_MODESWITCHDIR)/$(USB_MODESWITCHBINARY) usb_modeswitch_copy


usb_modeswitch-clean:
	rm -f $(TARGET_DIR)/usr/bin/$(USB_MODESWITCHBINARY)
	-$(MAKE) -C $(USB_MODESWITCHDIR) clean

usb_modeswitch-dirclean:
	rm -rf $(USB_MODESWITCHDIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_USB_MODESWITCH)),y)
TARGETS+=usb_modeswitch
endif

