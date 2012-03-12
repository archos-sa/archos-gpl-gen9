TOOLCHAIN_PATH=${ANDROID_SRC}/prebuilt/linux-x86/toolchain
TOOLCHAIN=${TOOLCHAIN_PATH}/arm-linux-androideabi-4.4.x
CROSS=${TOOLCHAIN}/bin/arm-linux-androideabi-
CRT_PATH=${TOOLCHAIN}/lib/gcc/arm-linux-androideabi/4.4.3/armv7-a
SYSTEM_LIB=${ANDROID_SRC}/prebuilt/ndk/android-ndk-r6/platforms/android-9/arch-arm/usr/lib
LDSCRIPTS=${TOOLCHAIN_PATH}/arm-eabi-4.4.3/arm-eabi/lib/ldscripts/armelf.x

BIONIC=${ANDROID_SRC}/bionic
LIBC=${BIONIC}/libc

CFLAGS= \
	-fPIC -DANDROID -DPIC \
	-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -marm \
	-I${LIBC}/arch-arm/include \
        -I${LIBC}/include \
        -I${LIBC}/libstdc++/include \
        -I${LIBC}/kernel/common \
        -I${LIBC}/kernel/arch-arm \
        -I${BIONIC}/libm/include \
        -I${BIONIC}/libm/include/arm

LDFLAGS= \
	-Wl,-T,${LDSCRIPTS} \
	-Wl,-rpath-link=${SYSTEM_LIB} \
	-L${SYSTEM_LIB} \
	-nostdlib \
	${CRT_PATH}/crtbegin.o \
	${CRT_PATH}/crtend.o \
	-lc -lm -ldl

include $(LIBAV_DIR)/configure_common.mk

config.mak: $(LIBAV_DIR)/configure.mk $(LIBAV_DIR)/configure_common.mk $(LIBAV_DIR)/configure
	$(LIBAV_DIR)/configure --target-os=linux \
		--arch=armv7a \
		--enable-cross-compile \
		--cc=${CROSS}gcc \
		--cross-prefix=${CROSS} \
		--nm=${CROSS}nm \
		--extra-cflags="${CFLAGS}" \
		--extra-ldflags="${LDFLAGS}" \
		--prefix=/system  \
		--libdir=/system/lib \
		${CONFIG_LIBAV}
	mkdir -p $(INCLUDE_OUT_DIR)/libavutil
	cp libavutil/avconfig.h $(INCLUDE_OUT_DIR)/libavutil/avconfig.h

all: config.mak
