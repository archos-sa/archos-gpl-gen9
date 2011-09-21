#############################################################
#
# tiler
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

TILER_SOURCE:=$(TOPDIR)/../lgf/mydroid/hardware/ti/tiler/
TILER_DIR:=$(BUILD_DIR)/tiler

$(TILER_DIR)/.unpacked:
	mkdir $(TILER_DIR) || true
	(cd $(TILER_SOURCE) ; git archive HEAD ) |tar x -C $(TILER_DIR)
	touch $(TILER_DIR)/.unpacked

$(TILER_DIR)/.configured: $(TILER_DIR)/.unpacked
	(cd $(TILER_DIR); rm -rf config.cache; bash bootstrap.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
	)
	touch $@

$(TILER_DIR)/.compiled: $(TILER_DIR)/.configured
	make -C $(TILER_DIR)
	touch $@


$(STAGING_DIR)/usr/lib/libtimemmgr.so: $(TILER_DIR)/.compiled
	$(MAKE) -C $(TILER_DIR) DESTDIR=$(STAGING_DIR) install
	$(SED) "s,^libdir=.*,libdir=\'$(STAGING_DIR)/usr/lib\',g" \
		$(STAGING_DIR)/usr/lib/libtimemmgr.la

$(TARGET_DIR)/usr/lib/libtimemmgr.so: $(STAGING_DIR)/usr/lib/libtimemmgr.so
	cp -dpf $(STAGING_DIR)/usr/lib/libtimemmgr.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libtimemmgr.so

tiler: uclibc $(TARGET_DIR)/usr/lib/libtimemmgr.so

tiler-clean:

tiler-dirclean:
	rm -rf $(TILER_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_TILER)),y)
TARGETS+=tiler
endif
