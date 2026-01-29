.section ".text.boot"
.global _start

_start:
        /* low power hang loop for now */
        wfe             /* wait for event (lower power sleep)
        b _start        /* loop forever */
