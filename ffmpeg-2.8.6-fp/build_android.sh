#!/bin/bash

ACCOUNT=marsr
NDK=/home/$ACCOUNT/Android/Sdk/ndk-bundle

PLATFORM=$NDK/platforms/android-9/arch-arm/
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64

function build_one
{
    ./configure --target-os=linux \
        --prefix=$PREFIX \
        --enable-cross-compile \
        --extra-libs="-lgcc" \
        --arch=arm \
        --cc=$PREBUILT/bin/arm-linux-androideabi-gcc \
        --cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
        --nm=$PREBUILT/bin/arm-linux-androideabi-nm \
        --sysroot=$PLATFORM \
        --extra-cflags=" -O3 -fpic -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex \
        -fasm -Wno-psabi -fno-short-enums  -fno-strict-aliasing -finline-limit=300 $OPTIMIZE_CFLAGS " \
        --disable-shared \
        --enable-static \
        --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib  -nostdlib -lc -lm -ldl -llog" \
        --enable-parsers \
        --disable-encoders  \
        --enable-decoders \
        --disable-muxers \
        --enable-demuxers \
        --enable-swscale  \
        --disable-ffmpeg \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-ffserver \
        --enable-network \
        --enable-indevs \
        --disable-bsfs \
        --enable-filters \
        --enable-protocols  \
        --enable-asm \
        $ADDITIONAL_CONFIGURE_FLAG

        #make clean
        make  -j4 install
        $PREBUILT/bin/arm-linux-androideabi-ar d libavcodec/libavcodec.a inverse.o

        $PREBUILT/bin/arm-linux-androideabi-ld -rpath-link=$PLATFORM/usr/lib \
            -L$PLATFORM/usr/lib  -soname libffmpeg.so -shared -nostdlib \
            -Bsymbolic --whole-archive --no-undefined -o $PREFIX/libffmpeg.so \
            libavcodec/libavcodec.a libavdevice/libavdevice.a libavfilter/libavfilter.a \
            libavformat/libavformat.a libavutil/libavutil.a libswscale/libswscale.a \
            libswresample/libswresample.a -lc -lm -lz -ldl -llog \
            --dynamic-linker=/system/bin/linker \
            $PREBUILT/lib/gcc/arm-linux-androideabi/4.9.x/libgcc.a
}

#arm v7vfpv3 
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
PREFIX=./android/$CPU 
ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v7vfp 
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "
PREFIX=./android/$CPU-vfp
ADDITIONAL_CONFIGURE_FLAG=
build_one

#arm v7n 
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8"
PREFIX=./android/$CPU 
ADDITIONAL_CONFIGURE_FLAG=--enable-neon
build_one

