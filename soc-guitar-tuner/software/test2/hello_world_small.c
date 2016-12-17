/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "system.h"

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include "sys/alt_irq_entry.h"
#include "altera_avalon_timer_regs.h"

// fixme: сделать свой драйвер
#include <io.h>
//#include "alt"
//#define IOADDR_ALTERA_AVALON_PIO_DATA(base)           __IO_CALC_ADDRESS_NATIVE(base, 0)
#define IORD_ALTERA_AVALON_PIO_DATA(base)             IORD(base, 0)
#define IOWR_ALTERA_AVALON_PIO_DATA(base, data)       IOWR(base, 0, data)

//////////////////////////////////

volatile unsigned short int led_dir;

// http://www.alteraforum.com/forum/showthread.php?t=41438
static void timer_isr (void * context)
{
	volatile unsigned char* dir_ptr;

	IOWR_ALTERA_AVALON_TIMER_STATUS( SYS_TIMER_BASE, 0 );

	dir_ptr = (volatile unsigned char*)context;
	*dir_ptr ^= 0x1;
}

//////////////////////////////////

// https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/ug/ug_embedded_ip.pdf

int main()
{ 
//	init_button_pio();
//
	void* led_dir_ptr = (void*)&led_dir;

	led_dir = 0x0100;

	//Timer Initialization
	IOWR_ALTERA_AVALON_TIMER_CONTROL(SYS_TIMER_IRQ, 0x0003);
	IOWR_ALTERA_AVALON_TIMER_STATUS(SYS_TIMER_IRQ, 0);

	IOWR_ALTERA_AVALON_TIMER_PERIODL(SYS_TIMER_IRQ, 0x000A);
	IOWR_ALTERA_AVALON_TIMER_PERIODH(SYS_TIMER_IRQ, 0x0000);

	//Register ISR for timer event
	alt_ic_isr_register(
			SYS_TIMER_IRQ_INTERRUPT_CONTROLLER_ID, SYS_TIMER_IRQ,
			timer_isr, led_dir_ptr, 0);

	//Start timer and begin the work
	IOWR_ALTERA_AVALON_TIMER_CONTROL( SYS_TIMER_BASE, 0x0007 );

	//////////////////////////////////

	alt_putstr("Hello from Nios II!\n");
	//IOWR_ALTERA_AVALON_PIO_DATA(
	//REG16_AVALON_INTERFACE_0_BASE;//, 0xff);
//	volatile short int* p = REG16_AVALON_INTERFACE_0_BASE;
//
//	int count = 0;
//	int delay;
//	while(1)
//	{
//		*p = count & 0x7;
//		// http://stackoverflow.com/questions/16049329/write-only-pointer-type
//		if( (count & 0x7) == *p ){
//			alt_printf("val %x ;\n", *p);
//		}
//		delay = 0;
//		while(delay < 2000000){
//		  delay++;
//		}
//		count++;
//	}

	return 0;
}
