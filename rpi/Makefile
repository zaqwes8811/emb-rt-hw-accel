obj-m += ofd.o

default:
	make ARCH=arm CROSS_COMPILE=${CCPREFIX} -C ${KERNEL_SRC} M=$(PWD) modules

# clean: 
    # make -C ${KERNEL_SRC} M=$(PWD) clean