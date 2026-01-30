# Toolchain Setup
CC = aarch64-elf-gcc
OBJCOPY = aarch64-elf-objcopy

# Compilation Flags
# -g: Debug info for gdb
# -Wall: All warnings
# -O2: Optimize for speed
# -ffreestanding: Tell gcc no libc
# -nostdinc: Do not look for standard headers
# -nostdlib: Do not like standard libraries
CFLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib -mcpu=cortex-a72 -g -Iinclude

# Source Files
C_SRCS = $(wildcard src/*.c)
ASM_SRCS = $(wildcard src/*.S)

# Object Files
OBJS = $(C_SRCS:src/%.c=build/%.o) $(ASM_SRCS:src/%.S=build/%.o)

# Default Target
all: kernel8.img

# Make Image From ELF
kernel8.img: kernel.elf
	$(OBJCOPY) -O binary kernel.elf kernel8.img

# Link Everything Into ELF
kernel.elf: $(OBJS) link.ld
	$(CC) $(CFLAGS) -T link.ld -o kernel.elf $(OBJS)

# Compile C Files
build/%.o: src/%.c
	@mkdir -p build
	$(CC) $(CFLAGS) -c $< -o $@

# Compile Assembly Files
build/%.o: src/%.S
	@mkdir -p build
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up
clean:
	rm -rf build kernel.elf kernel8.img

# Run in QEMU (With GUI)
run: kernel8.img
	qemu-system-aarch64 -M raspi4b -serial stdio -kernel kernel8.img

# Run in QEMU (Without GUI)
run-term: kernel8.img
	qemu-system-aarch64 -M raspi4b -nographic -kernel kernel8.img
