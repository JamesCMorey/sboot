DISK = disk.img

MBR_SRC = mbr.s
KERNEL_SRC = kernel.c
BIN = bin

LD_OPTS = -m elf_i386 --oformat=binary
LD_MBR = -Ttext=0x7C00 $(LD_OPTS)
LD_KERNEL = -Ttext=0x1000 $(LD_OPTS)

QEMU = qemu-system-i386 -drive format=raw,file=$(DISK)

all:
	gcc -m32 -ffreestanding -fno-pic -nostdlib -fno-stack-protector -c kernel.c -o kernel.o
	as --32 mbr.s -o mbr.o
	# Link MBR and Kernel
	ld $(LD_MBR) mbr.o -o mbr.bin
	ld $(LD_KERNEL) kernel.o -o kernel.bin
	# Combine MBR and Kernel
	dd if=mbr.bin of=$(DISK) conv=notrunc
	dd if=kernel.bin of=$(DISK) conv=notrunc seek=1

run:clean all # ctrl-a x to exit
	$(QEMU) -s

d:
	gdb -ex "target remote localhost:1234" 

clean:
	rm -f *.o *.bin disk.img
