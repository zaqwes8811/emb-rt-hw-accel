obj-m += ofd.o

default:
	make ARCH=arm CROSS_COMPILE=${CCPREFIX} -C ${KERNEL_SRC} M=$(PWD) modules

clean: 
	rm *.ko *.o *.mod.c *.order *.symvers