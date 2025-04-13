/* MBR Bootloader Code */

.code16

.org 0 /* make sure code starts at 0x0 */

.text
_start:
  cli /* clear interrupt flag */

  xor %ax, %ax

  /* Zero segment indicators */
  mov %ax, %ds
  mov %ax, %es
  mov %ax, %ss

  /* Set stack pointer to default value */
  mov $0x7C00, %sp

  /* Make sure cs:ip are set properly (0:0x7cXX) */
  ljmp $0, $skip
skip:

  call clrscr /* Make things look nice */

read_kernel:
  /* Read kernel from disk into memory

   * Sectors on disk are read into memory at es:bx, so set %bx to right after 
   * MBR in memory.
   * */
  mov $0x7e00, %bx

  mov $0x02, %ah /* INT Service Code */
  mov $0x01, %al /* Num sectors to read (sector is 512 bytes)*/

  mov $0x00, %ch /* Cylinder Number (disk identification)*/
  mov $0x02, %cl /* Sector Number (sector on disk) */

  mov $0x00, %dh /* Drive Head */
  /* %dl need not be set as it is the same drive */

  INT $0x13

load_gdt:
  /* Load GDT */
  lgdt gdt_descriptor

  /* Enter Protected Mode (x32)*/
  /* %eax isn't valid in 16-bit, but it's necessary to keep the assembler happy. */
  /* This also means the 'l' variants of the ops are needed. */
  movl %cr0, %eax 
  orl $0x1, %eax
  movl %eax, %cr0

  /* Set cs to 0x08 (index of Code Segment descriptor in the GDT) */
  ljmp $0x08, $protected_mode_entry


.code32
protected_mode_entry:
  /* Set segments to 0x10 (index of Data Segment descriptor in GDT)
   */
  movw $0x10, %ax
  movw %ax, %ds
  movw %ax, %es
  movw %ax, %ss
  movw %ax, %fs
  movw %ax, %gs

hang:
  jmp hang

clrscr:
    mov     $0x00, %ah
    mov     $0x07, %al
    int     $0x10
    ret

.align 8
gdt:
    /* Null descriptor */
    .quad 0x0000000000000000 

    /* Code segment (idx 0x08): base=0x0, limit=0xFFFFF (4GB), type=exec/read */
    .word 0xFFFF         /* Limit low */
    .word 0x0000         /* Base low */
    .byte 0x00           /* Base middle  */
    .byte 0x9A           /* Access: present, ring 0, code, readable  */
    .byte 0xCF           /* Flags: 4K granularity, 32-bit  */
    .byte 0x00           /* Base high  */

    /* Data segment (idx 0x10): base=0x0, limit=0xFFFFF (4GB), type=read/write */
    .word 0xFFFF         /* Limit low */
    .word 0x0000         /* Base low  */
    .byte 0x00           /* Base middle */
    .byte 0x92           /* Access: present, ring 0, data, writable */
    .byte 0xCF           /* Flags: 4K, 32-bit */
    .byte 0x00           /* Base high */

gdt_descriptor:
    .word gdt_end - gdt - 1     /* Limit (size - 1)  */
    .long gdt                   /* Base address  */

gdt_end:

.org 510      /* pad till 510 */
.word 0xaa55  /* Magic Number */
