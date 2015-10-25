
#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/device.h>
#include <linux/fs.h>
#include <asm/uaccess.h>

// Note: модуль ядра, драйвер, device - модуль ядра не 
//   обязательно драйвер
//   http://unix.stackexchange.com/questions/47208/what-is-the-difference-between-kernel-drivers-and-kernel-modules

// Minor - получает как параметр
//   http://linuxdrivers.blogspot.ru/2010/10/13.html

#define DEVICE_NAME "ebbchar"
#define CLASS_NAME "ebb"

static int majorNumber;
static char message[256];
static short size_of_message;
static int numberOpens = 0;
static struct class* ebbcharClass = NULL;
static struct device* ebbcharDevice = NULL;

// prototypes
static int dev_open(struct inode*, struct file*);
static int dev_release(struct inode*, struct file*);
 
/** @brief Devices are represented as file structure in the kernel. The file_operations structure from
 *  /linux/fs.h lists the callback functions that you wish to associated with your file operations
 *  using a C99 syntax structure. char devices usually implement open, read, write and release calls
 */
static struct file_operations fops =
{
   //.open = dev_open,
//   .read = dev_read,
//   .write = dev_write,
   //.release = dev_release,
};

// ctor/dtor
static int __init ebbchar_init(void) 
{
	printk(KERN_INFO "EBBChar: Init the EBBChar LKM\n");

	majorNumber = register_chrdev(0, DEVICE_NAME, &fops);
	if (majorNumber<0){
		printk(KERN_ALERT "EBBChar: failed to reg a major number\n");
		return majorNumber;
	}

	// red device class
}

static int __exit ebbchar_exit(void) 
{

}

module_init(ebbchar_init);
module_exit(ebbchar_exit);