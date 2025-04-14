#include <stdint.h>
void kernel_main(void) {

  /* Make sure hidden caches / registers are set properly */
  asm volatile (
    "mov $0x10, %%ax \n"
    "mov %%ax, %%ds \n"
    "mov %%ax, %%es \n"
    "mov %%ax, %%fs \n"
    "mov %%ax, %%gs \n"
    "mov %%ax, %%ss \n"
    ::: "ax"
  );

  /* Pigeon goes "ku" */
  volatile char *vga = (char *)0xB8000;
  vga[0] = 'K';
  vga[1] = 0x0F;

  vga = (char *)0xB8002;
  vga[0] = 'u';
  vga[1] = 0x0F;

  for(;;)
    ;
}
