.section ".text.boot"
.global _start

_start:
        /* check processor id and if core 0, continue */
        mrs     x0, mpidr_el1
        and     x0, x0, #0xFF           /* check processor id */
        cbz     x0, master              /* if core 0 jump to master */
        b       hang                    /* if core 1..n, hang */

hang:
        wfe                             /* wait for event in low power */
        b       hang

master:
        /* setup stack pointer */ 
        /* stack starts at 0x80000 and grows down */
        /* kernel code starts at 0x80000 and grows up */
        ldr     x0, =_start
        mov     sp, x0

        /* clear bss (initialize global variables to 0) */
        ldr     x1, =__bss_start        /* start address */
        ldr     w2, =__bss_size         /* size */
        cbz     w2, run_kernel          /* skip if size is 0 */ 

clear_bss:
        str     xzr, [x1], #8           /* store zero register to addr x1, inc x1 by 8 */
        sub     w2, w2, #1              /* decrement size counter */
        cbnz    w2, clear_bss           /* loop if not zero */

run_kernel:
        /* hand off control to C */
        bl      kernel_main
        b       hang                    /* hang if C returns */
