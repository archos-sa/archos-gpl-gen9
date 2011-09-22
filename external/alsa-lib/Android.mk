# external/alsa-lib/Android.mk
#
# Copyright 2008 Wind River Systems
#

ifeq ($(strip $(BOARD_USES_ALSA_AUDIO)),true)

LOCAL_PATH := $(call my-dir)

##
## build libasound.so
##
include $(CLEAR_VARS)
LOCAL_MODULE := libasound
LOCAL_MODULE_TAGS:=optional
LOCAL_PRELINK_MODULE := false
LOCAL_ARM_MODE := arm

LOCAL_C_INCLUDES += $(LOCAL_PATH)/include

# libasound must be compiled with -fno-short-enums, as it makes extensive
# use of enums which are often type casted to unsigned ints.
LOCAL_CFLAGS := \
    -Wno-format-security \
    -fPIC -DPIC -D_POSIX_SOURCE -O1 \
    -DALSA_CONFIG_DIR=\"/system/usr/share/alsa\" \
    -DALSA_PLUGIN_DIR=\"/system/usr/lib/alsa-lib\" \
    -DALSA_DEVICE_DIRECTORY=\"/dev/snd/\"

LOCAL_SRC_FILES := $(sort $(call all-c-files-under, src))

# It is easier to exclude the ones we don't want...
#
LOCAL_SRC_FILES := $(filter-out src/alisp/alisp_snd.c, $(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out src/compat/hsearch_r.c, $(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out src/control/control_shm.c, $(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out src/pcm/pcm_d%.c, $(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out src/pcm/pcm_ladspa.c, $(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out src/pcm/pcm_shm.c, $(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out src/pcm/scopes/level.c, $(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out src/shmarea.c, $(LOCAL_SRC_FILES))

LOCAL_SHARED_LIBRARIES := \
    libdl

include $(BUILD_SHARED_LIBRARY)

##
## Copy ALSA configuration files to rootfs
##
TARGET_ALSA_CONF_DIR := $(TARGET_OUT)/usr/share/alsa
ALSA_CONF_DIR  := $(LOCAL_PATH)/src/conf

conf_files_from := \
    $(ALSA_CONF_DIR)/alsa.conf \
    $(ALSA_CONF_DIR)/cards/aliases.conf \
    $(wildcard $(ALSA_CONF_DIR)/pcm/*.conf)
conf_files_to := $(conf_files_from:$(ALSA_CONF_DIR)/%=$(TARGET_ALSA_CONF_DIR)/%)

$(conf_files_to): $(TARGET_ALSA_CONF_DIR)/% : $(ALSA_CONF_DIR)/% | $(ACP)
	$(transform-prebuilt-to-target)


include $(CLEAR_VARS)

LOCAL_MODULE := alsa-conf
LOCAL_MODULE_TAGS:=optional
LOCAL_MODULE_CLASS:=SHARED_LIBRARIES

include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): $(conf_files_to)

endif
