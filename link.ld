ENTRY(_start)

SECTIONS
{
        /* Raspberry Pi 64-bit kernel starting address */
        . = 0x80000;

        /* Executable code (.text) segment */
        .text : {
                KEEP(*(.text.boot))     /* Put boot code at the very front */
                *(.text)                /* All other code follows */
        }

        /* Read-Only Data (string, constants) */
        .rodata : {
                *(.rodata)
        }

        /* Read-Write Data (variables) */
        .data : {
                *(.data)
        }

        /* Uninitialized variables (BSS) */
        .bss : {
                __bss_start = .;
                *(.bss)
                __bss_end = .;
        }
}
