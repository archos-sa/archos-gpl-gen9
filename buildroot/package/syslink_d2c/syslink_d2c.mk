#############################################################
#
# syslink_d2c
#
#############################################################
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Library General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA

SYSLINK_D2C_SOURCE:=$(TOPDIR)/../lgf/mydroid/hardware/ti/syslink/
SYSLINK_D2C_DIR:=$(BUILD_DIR)/syslink_d2c

$(SYSLINK_D2C_DIR)/.unpacked:
	mkdir $(SYSLINK_D2C_DIR) || true
	(cd $(SYSLINK_D2C_SOURCE)/ ; git archive HEAD ) |tar x -C $(SYSLINK_D2C_DIR)
	touch $(SYSLINK_D2C_DIR)/.unpacked

$(SYSLINK_D2C_DIR)/.configured: $(SYSLINK_D2C_DIR)/.unpacked
	(cd $(SYSLINK_D2C_DIR)/syslink/d2c/; rm -rf config.cache; bash bootstrap.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(STAGING_DIR)/usr \
	)
	touch $@

$(SYSLINK_D2C_DIR)/.compiled: $(SYSLINK_D2C_DIR)/.configured
	make -C $(SYSLINK_D2C_DIR)/syslink/d2c/
	touch $@


$(STAGING_DIR)/usr/lib/libd2cmap.so: $(SYSLINK_D2C_DIR)/.compiled
	$(MAKE) -C $(SYSLINK_D2C_DIR)/syslink/d2c/ install

$(TARGET_DIR)/usr/lib/libd2cmap.so: $(STAGING_DIR)/usr/lib/libd2cmap.so
	cp -dpf $(STAGING_DIR)/usr/lib/libd2cmap.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libd2cmap.so

syslink_d2c: uclibc syslink $(TARGET_DIR)/usr/lib/libd2cmap.so

syslink_d2c-clean:

syslink_d2c-dirclean:
	rm -rf $(SYSLINK_D2C_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_SYSLINK_D2C)),y)
TARGETS+=syslink_d2c
endif
