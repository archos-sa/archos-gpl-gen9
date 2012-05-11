SDE_FLAVOUR         = sde
SDE_BUILD_DIR       = $(BASE_DIR)/$(SDE_FLAVOUR)
SDE_ROOT            = $(BASE_DIR)/$(SDE_FLAVOUR)/root
SDE_KERNEL          = $(BASE_DIR)/linux-ics/arch/arm/boot/zImage
SDE_BUILDROOT_BOARD = init

SDE_SRC             = package/sde
SDE_DEVICE_TABLE    = $(SDE_SRC)/device_table.txt
SDE_BOOT_IMAGES     = $(SDE_SRC)/SDE-1024x768.gz $(SDE_SRC)/SDE-1280x800.gz

SDE_CPIO_BASE       = $(SDE_BUILD_DIR)/sde.cpio
SDE_CPIO_LZO        = $(SDE_BUILD_DIR)/initramfs.cpio.gz
SDE_LZO             = lzop -c
SDE_STRIP           = $(STAGING_DIR)/usr/bin/arm-linux-strip

sde_filesystem:  $(SDE_BOOT_IMAGES) 
	@#build our mini rootfs using BOARD=init
	(unset LD_LIBRARY_PATH; $(MAKE) -C $(BASE_DIR) BOARD=$(SDE_BUILDROOT_BOARD) PROJECT_BUILD_DIR=$(SDE_BUILD_DIR))

	cp -dp $(SDE_BOOT_IMAGES) $(SDE_ROOT)/

	@# link init to build's specific init.
	-rm -f $(SDE_ROOT)/init
	cp -dp $(VERBOSE) $(SDE_SRC)/init $(SDE_ROOT)/init
	chmod 755 $(SDE_ROOT)/init

$(SDE_CPIO_BASE):
	-find $(SDE_ROOT) -type f -perm +111       | xargs $(SDE_STRIP) 2>/dev/null || true
	-find $(SDE_ROOT) -type f -a -name "*.so*" | xargs $(SDE_STRIP) 2>/dev/null || true
	-find $(SDE_ROOT) -type f -a -name "*.ko"  | xargs $(SDE_STRIP) --strip-unneeded 2>/dev/null || true
	@rm -rf $(SDE_ROOT)/usr/man
	@rm -rf $(SDE_ROOT)/usr/info
	
	@# Use fakeroot to pretend all target binaries are owned by root
	@rm -f $(SDE_BUILD_DIR)/_fakeroot.$(notdir $(SDE_CPIO_BASE))
	echo "chown -R 0:0 $(SDE_ROOT)" >> $(SDE_BUILD_DIR)/_fakeroot.$(notdir $(SDE_CPIO_BASE))

	@# Use fakeroot to pretend to create all needed device nodes
	@echo "$(STAGING_DIR)/bin/makedevs -d $(SDE_DEVICE_TABLE) $(SDE_ROOT)" \
		>> $(SDE_BUILD_DIR)/_fakeroot.$(notdir $(SDE_CPIO_BASE))

	@# Use fakeroot so cpio believes the previous fakery
	@echo "cd $(SDE_ROOT) && find . | cpio --quiet -o -H newc > $(SDE_CPIO_BASE)" \
		>> $(SDE_BUILD_DIR)/_fakeroot.$(notdir $(SDE_CPIO_BASE))
	@chmod a+x $(SDE_BUILD_DIR)/_fakeroot.$(notdir $(SDE_CPIO_BASE))
	$(STAGING_DIR)/usr/bin/fakeroot -- $(SDE_BUILD_DIR)/_fakeroot.$(notdir $(SDE_CPIO_BASE))
	
	-@rm -f $(SDE_BUILD_DIR)/_fakeroot.$(notdir $(SDE_CPIO_BASE))
	
$(SDE_CPIO_LZO): $(SDE_CPIO_BASE)
	$(SDE_LZO) $< > $@
	@rm -f $(SDE_CPIO_BASE)

sde_kernel: kernel
	cp $(SDE_KERNEL) $(SDE_BUILD_DIR)

sde_banner:
	@echo ""
	@echo "**********************"
	@echo "*                    *"
	@echo "* SDE build complete *"
	@echo "*                    *"
	@echo "**********************"
	@echo ""
	@echo "files to install:" 
	@echo `ls -l $(SDE_FLAVOUR)/zImage`
	@echo `ls -l $(SDE_FLAVOUR)/initramfs.cpio.gz`
	@echo ""
	
sde: sde_filesystem $(SDE_CPIO_LZO) sde_kernel sde_banner

sde-clean:
	rm -rf $(SDE_BUILD_DIR)

sde-dirclean: sde-clean

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_SDE)),y)
TARGETS+=sde
endif
