#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/cdev.h>
#include <linux/gpio.h>

// some code from
/*
* raspi_gpio_driver.c - GPIO Linux device driver for Raspberry Pi B
* rev 2.0 platform
* Author: Vu Nguyen <quangngmetro@gmail.com>
* Version: 0.2
* License: GPL
*/

struct raspi_gpio_dev {
	struct cdev cdev;
	struct gpio pin;
	//enum state state;
	//enum direction dir;
	bool irq_perm;
	unsigned long irq_flag;
	unsigned int irq_counter;
	//spinlock_t lock;
};

// fixme: make as in video but without direct calls HW
// fixme: how use IRQ
//
// fixme: try with poll() interface. only one can open

static int __init ofd_init(void) /* Constructor */
{
    printk(KERN_INFO "Namaskar: ofd registered");
    return 0;
}

static void __exit ofd_exit(void) /* Destructor */
{
    printk(KERN_INFO "Alvida: ofd unregistered");
} 

module_init(ofd_init);
module_exit(ofd_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Anil Kumar Pugalia <email_at_sarika-pugs_dot_com>");
MODULE_DESCRIPTION("Our First Driver");