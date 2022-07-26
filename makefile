##
#   Ferrite is bare metal
#
#
# @file
# @version 0.1

CROSS_COMPILE ?= arm-none-eabi

AOPS = --warn --fatal-warnings -mcpu=cortex-m4 -mthumb
COPS = -Wall -c -g -O0 -nostdlib -nostartfiles --specs=nosys.specs -ffreestanding -mcpu=cortex-m4 -mthumb

BUILD_DIR=./build
SRC_DIR=./src

sources = ./src/startup.s ./src/main.c
objects = $(BUILD_DIR)/$(wildcard *.o)

all: compile linkqemu linkstm32

compile:
	mkdir -p ./build
	$(CROSS_COMPILE)-as $(AOPS) $(SRC_DIR)/startup.s -o $(BUILD_DIR)/startup.o
	$(CROSS_COMPILE)-gcc $(COPS) $(SRC_DIR)/main.c -o $(BUILD_DIR)/main.o

	$(CROSS_COMPILE)-objcopy -R .comment -R .ARM.attributes $(BUILD_DIR)/startup.o $(BUILD_DIR)/startup.o
	$(CROSS_COMPILE)-objcopy -R .comment -R .ARM.attributes $(BUILD_DIR)/main.o $(BUILD_DIR)/main.o

linkqemu: compile
	mkdir -p ./build/qemu
	$(CROSS_COMPILE)-ld -nostdlib -Map=output.map $(BUILD_DIR)/startup.o $(BUILD_DIR)/main.o -T ./boards/qemu.ld -o $(BUILD_DIR)/qemu/ferrite.elf
	$(CROSS_COMPILE)-objdump -D $(BUILD_DIR)/qemu/ferrite.elf > $(BUILD_DIR)/qemu/ferrite.list
	$(CROSS_COMPILE)-objcopy $(BUILD_DIR)/qemu/ferrite.elf -O binary $(BUILD_DIR)/qemu/ferrite.bin

linkstm32: compile
	mkdir -p ./build/stm32f401
	$(CROSS_COMPILE)-ld -nostdlib -Map=output.map $(BUILD_DIR)/startup.o $(BUILD_DIR)/main.o -T ./boards/stm32f401.ld -o $(BUILD_DIR)/stm32f401/ferrite.elf
	$(CROSS_COMPILE)-objdump -D $(BUILD_DIR)/stm32f401/ferrite.elf > $(BUILD_DIR)/stm32f401/ferrite.list
	$(CROSS_COMPILE)-objcopy $(BUILD_DIR)/stm32f401/ferrite.elf -O binary $(BUILD_DIR)/stm32f401/ferrite.bin

clean:
	rm -r build

run:
	qemu-system-arm -d in_asm,cpu,cpu_reset -machine lm3s811evb \
					-cpu cortex-m4 -nographic -S -serial /dev/null \
					-kernel ferrite.elf
# end
