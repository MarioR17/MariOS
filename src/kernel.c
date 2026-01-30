#include "types.h"

/* Pi 4 base address for all devices */
#define MMIO_BASE       0xFE000000

/* UART control registers are 0x201000 from base */
#define UART0_DR        ((volatile uint32_t*)(MMIO_BASE + 0x201000)) /* Data Register (R/W chars) */ 
#define UART0_FR        ((volatile uint32_t*)(MMIO_BASE + 0x201018)) /* Flag Register (busy?) */
#define UART0_IBRD      ((volatile uint32_t*)(MMIO_BASE + 0x201024)) /* Integer Baud Rate (speed) */
#define UART0_FBRD      ((volatile uint32_t*)(MMIO_BASE + 0x201028)) /* Fractional Baud Rate */
#define UART0_LCRH      ((volatile uint32_t*)(MMIO_BASE + 0x20102C)) /* Line Control Register (Config bits) */
#define UART0_CR        ((volatile uint32_t*)(MMIO_BASE + 0x201030)) /* Control Register (On/Off switch) */
#define UART0_IMSC      ((volatile uint32_t*)(MMIO_BASE + 0x201038)) /* Interrupt Mask (Shut up interrupts) */

/* setup baud rate and protocol */
void uart_init(void)
{
        // turn off UART while we change settings 
        *UART0_CR = 0;

        // clear all interrupts
        *UART0_IMSC = 0;

        // Set Baud Rate to 115200
        *UART0_IBRD = 26; // Integer part
        *UART0_FBRD = 3; // Fractional part

        // Set the Protocol
        *UART0_LCRH = (1<<4) | (1<<5) | (1<<6);

        // Turn UART back on
        *UART0_CR = (1<<0) | (1<<8) | (1<<9);
}

/* Print a character */
void uart_putc(char c)
{
        // while FR is is 1 wait
        while (*UART0_FR & (1<<5)) {
        }

        // write our character to DR
        *UART0_DR = c;
}

/* Print a whole string */
void uart_puts(const char* str)
{
        while (*str) {
                uart_putc(*str++);
        }
}

/* Main kernel loop */
void kernel_main(void)
{
        uart_init();

        /* Print out first message */
        uart_puts("\r\n---              Welcome to MariOS               ---\r\n");
        uart_puts("\r\r---              [OK] UART INITIALIZED           ---\r\n");
        uart_puts("Type below (Echo Mode):\r\n> ");

        while (1) {
                // if FR 4th bit isn't 0 then not empty
                if (!(*UART0_FR & (1<<4))) {
                        // read characters from hardware
                        char c = (char)(*UART0_DR);

                        // echo it back to the screen
                        uart_putc(c);

                        // if we type \r add newline for prettiness
                        if (c == '\r') {
                                uart_putc('\n');
                                uart_putc('\r');
                                uart_puts("> ");
                        } else if (c == '\n') {
                                uart_putc('\n');
                                uart_putc('\r');
                                uart_puts("> ");
                        } else {
                                uart_putc(c);
                        }
                }
        }
}
