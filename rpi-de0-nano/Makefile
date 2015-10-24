obj-m += ofd.o pii.o


RPI_ROOT=/home/zaqwes/emb-rpi/buildroot-2014.11/output
CCPREFIX=${RPI_ROOT}/host/usr/bin/arm-buildroot-linux-uclibcgnueabi-
KERNEL_SRC=${RPI_ROOT}/build/linux-c256eb9968c8997dce47350d2075e42f1b3991d3

default:
	make ARCH=arm CROSS_COMPILE=${CCPREFIX} -C ${KERNEL_SRC} M=$(PWD) modules

clean: 
	rm *.ko *.o *.mod.c *.order *.symvers