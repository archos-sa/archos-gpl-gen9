#############################################################
#
# syslink
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

SYSLINK_SOURCE:=$(TOPDIR)/../lgf/mydroid/hardware/ti/syslink/
SYSLINK_DIR:=$(BUILD_DIR)/syslink
SYSLINK_LIBS := ipc ipcutils omap4430proc procmgr rcm syslinknotify sysmgr

$(SYSLINK_DIR)/.unpacked:
	mkdir $(SYSLINK_DIR) || true
	(cd $(SYSLINK_SOURCE) ; git archive HEAD ) |tar x -C $(SYSLINK_DIR)
	touch $(SYSLINK_DIR)/.unpacked

$(SYSLINK_DIR)/.configured: $(SYSLINK_DIR)/.unpacked
	(cd $(SYSLINK_DIR)/syslink/; rm -rf config.cache; bash bootstrap.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(STAGING_DIR)/usr \
	)
	touch $@

$(SYSLINK_DIR)/.compiled: $(SYSLINK_DIR)/.configured
	make -C $(SYSLINK_DIR)/syslink/
	touch $@


$(STAGING_DIR)/usr/bin/syslink_daemon.out: $(SYSLINK_DIR)/.compiled
	$(MAKE) -C $(SYSLINK_DIR)/syslink/ install

$(TARGET_DIR)/usr/bin/syslink_daemon.out: $(STAGING_DIR)/usr/bin/syslink_daemon.out
	$(foreach LIB,$(SYSLINK_LIBS), \
		cp -dpf $(STAGING_DIR)/usr/lib/lib$(LIB).so* $(TARGET_DIR)/usr/lib/; \
		$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/lib$(LIB).so ;)
	cp -dpf $(STAGING_DIR)/usr/bin/syslink_daemon.out $(TARGET_DIR)/usr/bin/

syslink: uclibc tiler $(TARGET_DIR)/usr/bin/syslink_daemon.out

syslink-clean:

syslink-dirclean:
	rm -rf $(SYSLINK_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_SYSLINK)),y)
TARGETS+=syslink
endif
