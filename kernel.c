void kernel_main() {
    char *vga = (char *)0xB8000;
    vga[0] = 'H';
    vga[1] = 0x07;
    for (;;) {}
}
