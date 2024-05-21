OUTPUT_ARCH("riscv")

/*
CPU instruction starting point
is called _start
*/

ENTRY( _start )

/*
wxa = writeable, executable, allocatable
!ri = NOT read-only, NOT initialized
*/

MEMORY
{
    ram (wxa) : ORIGIN = 0x80000000, LENGTH = 128M
}

/*
Program headers
text - CPU instructions
data - Global initialized variables
bss - Global, UNinitialized variables

PT_LOAD tells linker that these are loaded
from file to memory
*/

PHDRS
{
    text PT_LOAD;
    data PT_LOAD;
    bss PT_LOAD;
}

/*
Memory organization based on section.
Assembly uses .section, C++ and Rust
go into the previously defined headers

*/

SECTIONS
{
    .text : {
        PROVIDE(_text_start = .);
        *(.text.init) *(.text .text.*)
        PROVIDE(_text_end = .);
    } >ram AT>ram :text
   
    PROVIDE(_global_pointer = .);

    .rodata : {
        PROVIDE(_rodata_start = .);
        *(.rodata .rodata.*)
        PROVIDE(_rodata_end = .);
    } >ram AT>ram :text

    .data : {
        . = ALIGN(4096);
        PROVIDE(_data_start = .);
        *(.sdata .sdata.*) *(.data .data.*)
        PROVIDE(_data_end = .);
    } >ram AT>ram :data
    
    .bss : {
        PROVIDE(_bss_start = .);
        *(.sbss .sbss.*) *(.bss .bss.*)
        PROVIDE(_bss_end = .);
    } >ram AT>ram :bss

    PROVIDE(_memory_start = ORIGIN(ram));
    PROVIDE(_stack = _bss_end + 0x80000000);
    PROVIDE(_memory_end = ORIGIN(ram) + LENGTH(ram));
    PROVIDE(_heap_start = _stack);
    PROVIDE(_heap_size = _memory_end - _stack);

}
