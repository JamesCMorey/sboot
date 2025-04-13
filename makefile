DISK = disk.img

MBR_SRC = mbr.s
OS_SRC = os.c
BIN = bin

LD_OPTS = -m elf_i386 -Ttext=0x7C00 --oformat=binary
QEMU = qemu-system-i386 -nographic -drive format=raw,file=$(DISK)

all: $(DISK) clean

$(DISK):
	gcc -m32 -ffreestanding -fno-pic -nostdlib -fno-stack-protector -c os.c -o os.o
	as --32 mbr.s -o mbr.o
	ld $(LD_OPTS) mbr.o os.o -o $(DISK)
	#dd if=$(BIN) of=$(DISK) conv=notrunc

run:clean all # ctrl-a x to exit
	$(QEMU) -s

d:
	gdb -ex "target remote localhost:1234" 

clean:
	rm -f *.o *.bin disk.img
