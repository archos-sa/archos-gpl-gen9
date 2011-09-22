
##
##
## File lists and locations
##
##

#
# DK_ROOT must be set prior to including common.inc
#
DK_ROOT = ../../../../..

#
# Includes common definitions and source file list
#
ifneq ($(KERNELRELEASE),)
    include $(M)/$(DK_ROOT)/stad/build/linux/common.inc
    include $(M)/$(DK_ROOT)/platforms/os/common/build/linux/os_sources.inc
else
    include $(DK_ROOT)/stad/build/linux/common.inc
    include $(DK_ROOT)/platforms/os/common/build/linux/os_sources.inc
endif


#
# List of platform independent OS files needed to be compiled
#
OS_SRCS = \
    $(DK_ROOT)/platforms/os/common/src/osRgstry.c \
    $(COMSRC)/Ctrl_Interface/CmdHndlr.c \

ifeq ($(TI_TRACE_BUFFER),y)
   OS_SRCS += $(DK_ROOT)/platforms/os/common/src/tracebuf.c
endif

OS_OBJS = $(patsubst %.c, %.o, $(OS_SRCS))

#
# OS include paths required for compilation.
# 
OS_INCS = $(DK_ROOT)/platforms/os/linux/inc $(DK_ROOT)/platforms/os/linux/src $(DK_ROOT)/platforms/os/common/inc

#
# Location and filename of the OS .lib file created by this makefile.
#
OUTPUT_DIR = $(KERNEL_DIR)/$(BUILD_DIR)
OUTPUT_FILE = $(OUTPUT_DIR)/libuadrv.a





##
##
## Build process
##
##

ifneq ($(KERNELRELEASE),)


	##
	##
	## This is the kernel build phase - set the appropriate arguments
    ##
    ##

	#
	# Adds the current directory as a prefix to all include directories.
	#
	EXTRA_CFLAGS += $(addprefix -I$(M)/, $(OS_DK_INCS) $(OS_INCS))

	#
	# Intermediate object name - this should be converted to the appropriate library file
	# after the kernel makefile finishes its work.
	#
	obj-m = tiwlan_drv.o

	#
	# List of object files the kernel makefile needs to compile.
	#
	tiwlan_drv-y = $(OS_OBJS) $(OS_AUXILIARY_LIBS)


else	# ifneq ($(KERNELRELEASE),)


##
##
## This is the regular build phase - act according to the make actions
##
##

#
# The location of the kernel makefile
#
KERNEL_DIR ?= 


#
# Build the OS lib file
#
.PHONY: all
all: .depend $(OUTPUT_FILE)

#
# Prints variables
#
.PHONY: help
help:
	@echo Default Compilation:	PLATFORM=$(PLATFORM) DEBUG=$(DEBUG) INTR=$(INTR) WSPI=$(WSPI) XCC=$(XCC) EXTRA CFLAGS: $(EXTRA_CFLAGS)


#
# Recursively cleans the OS lib object files
#
.PHONY: clean
clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(BUILD_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) clean
	@rm -f *.o .*.o.cmd *~ *.a *.~* core .depend dep $(addprefix $(OUTPUT_DIR)/, $(OS_OBJS))
#
# Causes the library file to get rebuilt
#
.depend:
	rm -f $(OUTPUT_FILE)

#
# Recursively builds the library file
#
$(OUTPUT_FILE):
	@echo EXTRA_CFLAGS = $(EXTRA_CFLAGS)
	$(MAKE) -C $(KERNEL_DIR) M=$(BUILD_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) modules
	@$(CROSS_COMPILE)$(AR) rcs $@ $(addprefix $(OUTPUT_DIR)/, $(OS_OBJS))


endif	# ifneq ($(KERNELRELEASE),)
