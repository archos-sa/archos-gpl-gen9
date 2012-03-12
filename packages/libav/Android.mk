LIBAV_CONFIG_DIR := $(PRODUCT_OUT)/obj/LIBAV_CONFIG
LIBAV_DIR := $(shell readlink -m $(call my-dir))

$(shell \
	mkdir -p $(LIBAV_CONFIG_DIR) && \
	make -C $(LIBAV_CONFIG_DIR) -f $(LIBAV_DIR)/configure.mk \
	ANDROID_SRC=$(shell pwd) \
	TARGET_PRODUCT=$(TARGET_PRODUCT) \
	LIBAV_DIR=$(LIBAV_DIR) \
	INCLUDE_OUT_DIR=../include \
	> /dev/null 2>&1)

include $(all-subdir-makefiles)
