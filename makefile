##
#   Ferrite is bare metal
#
#
# @file
# @version 0.1

CROSS_COMPILE ?= arm-none-eabi

AOPS = --warn --fatal-warnings -mcpu=cortex-m4 -mthumb
COPS = -Wall -c -O0 -nostdlib -nostartfiles --specs=nosys.specs -ffreestanding -mcpu=cortex-m4 -mthumb

all: startup.s memmap.ld
	$(CROSS_COMPILE)-as $(AOPS) startup.s -o startup.o
	$(CROSS_COMPILE)-gcc $(COPS) main.c -o main.o

	$(CROSS_COMPILE)-objcopy -R .comment -R .ARM.attributes startup.o startup.o
	$(CROSS_COMPILE)-objcopy -R .comment -R .ARM.attributes main.o main.o

	$(CROSS_COMPILE)-ld -nostartfiles -nostdlib startup.o main.o -T ./memmap.ld -o ferrite.elf
	$(CROSS_COMPILE)-objdump -D ferrite.elf > ferrite.list
	$(CROSS_COMPILE)-objcopy ferrite.elf -O binary ferrite.bin

run:
	qemu-system-arm -d in_asm,cpu,cpu_reset -machine lm3s811evb \
					-cpu cortex-m4 -nographic -S -serial /dev/null \
					-kernel ferrite.elf
# end
