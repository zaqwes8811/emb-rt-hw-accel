#!/bin/bash

export RPI_ROOT=/home/zaqwes/emb-rpi/buildroot-2014.11/output
export CCPREFIX=$RPI_ROOT/host/usr/bin/arm-buildroot-linux-uclibcgnueabi-
export KERNEL_SRC=$RPI_ROOT/build/linux-c256eb9968c8997dce47350d2075e42f1b3991d3

# make mrproper

# make ARCH=arm CROSS_COMPILE=${CCPREFIX} bcmrpi_defconfig
# make ARCH=arm CROSS_COMPILE=${CCPREFIX} -j4

make