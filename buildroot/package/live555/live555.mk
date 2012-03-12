#############################################################
#
# Live555
#
#############################################################
LIVE555_VERSION:=2011.12.02
LIVE555_SOURCE:=live.$(LIVE555_VERSION).tar.gz
LIVE555_SITE:=http://www.live555.com/liveMedia/public/
LIVE555_CAT:=$(ZCAT)
LIVE555_DIR:=$(BUILD_DIR)/live
LIVE555_BINARY:=testMPEG2TransportStreamer

$(DL_DIR)/$(LIVE555_SOURCE):
	 $(WGET) -P $(DL_DIR) $(LIVE555_SITE)/$(LIVE555_SOURCE)

live555-source: $(DL_DIR)/$(LIVE555_SOURCE)

$(LIVE555_DIR)/.unpacked: $(DL_DIR)/$(LIVE555_SOURCE)
	$(LIVE555_CAT) $(DL_DIR)/$(LIVE555_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	chmod +rw -R $(LIVE555_DIR)
	toolchain/patch-kernel.sh $(LIVE555_DIR) package/live555/ \*.patch*
	touch $(LIVE555_DIR)/.unpacked

$(LIVE555_DIR)/.configured: $(LIVE555_DIR)/.unpacked
	(cd $(LIVE555_DIR); rm -rf config.android; touch config.android; \
	echo "C = c" >> config.android; \
	echo "CPP = cpp" >> config.android; \
	echo "OBJ = o" >> config.android; \
	echo "COMPILE_OPTS =	$$"'(INCLUDES)'" -I. -O2 -DSOCKLEN_T=socklen_t -DNO_SSTREAM=1 -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 -DDEBUG=1 -DREAD_FROM_FILES_SYNCHRONOUSLY=1 -DXLOCALE_NOT_USED=1"  >> config.android; \
	echo "C_COMPILER = $(TARGET_CC)" >> config.android; \
	echo "C_FLAGS = $$"'(COMPILE_OPTS)'" $(TARGET_CFLAGS)" >> config.android; \
	echo "CPLUSPLUS_COMPILER = $(TARGET_CXX)" >> config.android; \
	echo "CPLUSPLUS_FLAGS = $$"'(COMPILE_OPTS)'" $(TARGET_CXXFLAGS)" >> config.android; \
	echo "LINK = $(TARGET_CXX) -o" >> config.android; \
	echo "LINK_OPTS =" >> config.android; \
	echo "CONSOLE_LINK_OPTS =" >> config.android; \
	echo "LIBRARY_LINK = $(TARGET_AR) cr " >> config.android; \
	echo "LIBRARY_LINK_OPTS =" >> config.android; \
	echo "LIB_SUFFIX = a" >> config.android; \
	./genMakefiles android)
	touch $(LIVE555_DIR)/.configured

$(LIVE555_DIR)/testProgs/$(LIVE555_BINARY): $(LIVE555_DIR)/.configured
	$(MAKE) -C $(LIVE555_DIR)

$(TARGET_DIR)/usr/bin/$(LIVE555_BINARY): $(LIVE555_DIR)/testProgs/$(LIVE555_BINARY)
	cp -a $(LIVE555_DIR)/testProgs/$(LIVE555_BINARY) $(TARGET_DIR)/usr/bin/$(LIVE555_BINARY)

live555: uclibc $(TARGET_DIR)/usr/bin/$(LIVE555_BINARY)

live555-clean:
	rm -f $(STAGING_DIR)/usr/bin/$(LIVE555_BINARY)
	-$(MAKE) -C $(LIVE555_DIR) clean

live555-dirclean:
	rm -rf $(LIVE555_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIVE555)),y)
TARGETS+=live555
endif
