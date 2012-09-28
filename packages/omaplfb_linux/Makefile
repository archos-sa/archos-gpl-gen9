#-------------------------------------------------------------------------------
# Texas Instruments OMAP(TM) Platform Software
# (c) Copyright 2011 Texas Instruments Incorporated. All Rights Reserved.
# (c) Copyright 2002-2011 by Imagination Technologies Ltd. All Rights Reserved.
# Use of this software is controlled by the terms and conditions found
# in the license agreement under which this software has been supplied.
#-------------------------------------------------------------------------------

.PHONY: help clean

ifeq ($(KERNELDIR),)
$(error "Must specify kernel directory with KERNELDIR=")
endif

ifeq ($(PVRKMDIR),)
$(error "Must specify pvrkm directory with PVRKMDIR=")
endif

ifeq ($(DEBUG),1)
BUILD_TYPE := debug
BUILD_FLAG := -DDEBUG
endif

ifeq ($(TARGET_PRODUCT),)
$(error "Must specify target SOC with TARGET_PRODUCT=")
endif


ifeq ($(TARGET_PRODUCT), G10A)
TARGET:= omap4470
else
ifeq ($(TARGET_PRODUCT), G9A)
TARGET:= omap4460
endif
endif

TARGET ?= omap4470

TARGET_DIR ?= $(TARGET)

ifeq ($(TARGET),omap5430)
CORE_REV := 544_105
BUILD_TYPE ?= release
endif

ifeq ($(TARGET),omap4470)
CORE_REV := 544_112
BUILD_TYPE ?= release
CONFIG_GCBV := y
endif

ifeq ($(TARGET),omap4460)
CORE_REV := 540_120
BUILD_TYPE ?= release
TARGET_DIR := omap4430
endif

BIN_POSTFIX := sgx$(CORE_REV)
BIN_DIR := binary2_$(CORE_REV)_$(TARGET_DIR)_android_$(BUILD_TYPE)
obj-m := omaplfb_$(BIN_POSTFIX).o

CROSS_COMPILE ?= arm-none-linux-gnueabi-

ccflags-y += \
	-I$(PVRKMDIR)/eurasia_km/services4/include \
	-I$(PVRKMDIR)/eurasia_km/services4/srvkm/include \
	-I$(PVRKMDIR)/eurasia_km/include4 \
	-I$(PVRKMDIR)/eurasia_km/services4/system/omap4 \
	-I$(PVRKMDIR)/eurasia_km/services4/system/include \
	-I$(PVRKMDIR)/eurasia_km/services4/srvkm/env/linux \
	-I$(PVRKMDIR)/eurasia_km/services4/srvkm/hwdefs \
	-I$(KERNEL_HEADER_DIR)/drivers/video/omap2 \
	-I$(KERNEL_HEADER_DIR)/arch/arm/plat-omap/include

KBUILD_EXTRA_SYMBOLS += \
	$(PVRKMDIR)/eurasia_km/eurasiacon/$(BIN_DIR)/target/kbuild/Module.symvers

ccflags-y += \
	-DLINUX \
	-D__linux__ \
	-fno-pic \
	-D__KERNEL__ \
	-DPVR_LINUX_USING_WORKQUEUES \
	-DSUPPORT_MEMINFO_IDS \
	-DSGX_CORE_DEFINED \
	-DTRANSFER_QUEUE

ccflags-y += $(BUILD_FLAG)

omaplfb_$(BIN_POSTFIX)-y += \
	omaplfb_linux.o \
	omaplfb_displayclass.o

omaplfb_$(BIN_POSTFIX)-$(CONFIG_GCBV) += \
	omaplfb_bv.o

all:
	$(MAKE) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNELDIR) M=$(PWD) modules

help:
	@echo "Usage: make"
	@echo ""
	@echo "The following variables are mandatory:"
	@echo "	KERNELDIR    	Source location of kernel"
	@echo "	PVRKMDIR	Path to kernel side SGX driver directory containing eurasia_km"
	@echo "	TARGET		Target product: omap5430, omap4460 or omap4470"
	@echo ""
	@echo "The following variable is optional:"
	@echo "	CROSS_COMPILE	Prefix for your preferred Toolchain (default is arm-none-linux-gnueabi-)"
	@echo ""

clean:
	$(MAKE) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNELDIR) M=$(PWD) clean
