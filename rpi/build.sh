#!/bin/bash

export RPI_ROOT=/home/zaqwes/emb-rpi/buildroot-2014.11
export CCPREFIX=$RPI_ROOT/output/host/usr/bin/arm-buildroot-linux-uclibcgnueabi-
export KERNEL_SRC=$RPI_ROOT/output/build/linux-rpi-3.12.y

# make mrproper

# make ARCH=arm CROSS_COMPILE=${CCPREFIX} bcmrpi_defconfig
# make ARCH=arm CROSS_COMPILE=${CCPREFIX} -j4

make