
ifeq ($(strip $(BOARD_USES_ALSA_AUDIO)),true)
ifeq ($(strip $(BUILD_WITH_ALSA_UTILS)),true)

LOCAL_PATH:= $(call my-dir)

#
# Build aplay command
#

include $(CLEAR_VARS)

LOCAL_CFLAGS := \
        -fPIC -D_POSIX_SOURCE \
        -DALSA_CONFIG_DIR=\"/system/usr/share/alsa\" \
        -DALSA_PLUGIN_DIR=\"/system/usr/lib/alsa-lib\" \
        -DALSA_DEVICE_DIRECTORY=\"/dev/snd/\"

LOCAL_C_INCLUDES:= \
        $(LOCAL_PATH)/include \
        $(LOCAL_PATH)/android \
        external/alsa-lib/include

LOCAL_SRC_FILES := \
        aplay/aplay.c

LOCAL_MODULE_TAGS := debug
LOCAL_MODULE := alsa_aplay

LOCAL_SHARED_LIBRARIES := \
        libasound \
        libc

include $(BUILD_EXECUTABLE)

#
# Build alsactl command
#

include $(CLEAR_VARS)

LOCAL_CFLAGS := \
        -fPIC -D_POSIX_SOURCE \
        -DALSA_CONFIG_DIR=\"/system/usr/share/alsa\" \
        -DALSA_PLUGIN_DIR=\"/system/usr/lib/alsa-lib\" \
        -DALSA_DEVICE_DIRECTORY=\"/dev/snd/\"

LOCAL_C_INCLUDES:= \
        $(LOCAL_PATH)/include \
        $(LOCAL_PATH)/android \
        external/alsa-lib/include

LOCAL_SRC_FILES := \
        alsactl/alsactl.c \
        alsactl/init_parse.c \
        alsactl/state.c \
        alsactl/utils.c

LOCAL_MODULE_TAGS := debug
LOCAL_MODULE := alsa_ctl

LOCAL_SHARED_LIBRARIES := \
        libasound \
        libc

include $(BUILD_EXECUTABLE)

#
# Build amixer command
#

include $(CLEAR_VARS)

LOCAL_CFLAGS := \
        -fPIC -D_POSIX_SOURCE \
        -DALSA_CONFIG_DIR=\"/system/usr/share/alsa\" \
        -DALSA_PLUGIN_DIR=\"/system/usr/lib/alsa-lib\" \
        -DALSA_DEVICE_DIRECTORY=\"/dev/snd/\"

LOCAL_C_INCLUDES:= \
        $(LOCAL_PATH)/include \
        $(LOCAL_PATH)/android \
        external/alsa-lib/include

LOCAL_SRC_FILES := \
        amixer/amixer.c

LOCAL_MODULE_TAGS := debug
LOCAL_MODULE := alsa_amixer

LOCAL_SHARED_LIBRARIES := \
        libasound \
        libc

include $(BUILD_EXECUTABLE)

##
##
ALSAINIT_DIR := $(TARGET_OUT)/usr/share/alsa/init

alsa_util_files := $(addprefix $(ALSAINIT_DIR)/,00main default hda help info test)

$(alsa_util_files): $(ALSAINIT_DIR)/%: $(LOCAL_PATH)/alsactl/init/% | $(ACP)
	$(transform-prebuilt-to-target)

include $(CLEAR_VARS)

LOCAL_MODULE := alsa-util-conf
LOCAL_MODULE_TAGS:=optional
LOCAL_MODULE_CLASS:=SHARED_LIBRARIES

include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): $(alsa_util_files)

endif
endif
