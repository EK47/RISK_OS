// The RISK OS
// Ethan Kelly
// 20 May 2024

#![no_main]
#![no_std]
#![feature(panic_info_message)]

use core::arch::asm;

////////////
// Macros //
////////////

#[macro_export]
macro_rules! print
{
    ($($args:tt)+) => ({

    });
}
#[macro_export]
macro_rules! println {
    () => ({
       print!("\r\n")
    });
    ($fmt:expr) => ({
        print!(concat!($fmt, "\r\n"))
    });
    ($fmt:expr, $($args:tt)+) => ({
        print!(concat!($fmt, "\r\n"), $($args)+)
    });
}

////////////////////////////
// Structures / Functions //
////////////////////////////

#[no_mangle]
extern "C" fn eh_personality() {}
#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    print!("Aborting: ");
    if let Some(p) = info.location() {
        println!(
            "line {}, file {}: {}",
            p.line(),
            p.file(),
            info.message().unwrap()
        );
    } else {
        println!("no information available");
    }
    abort();
}
#[no_mangle]
extern "C"
fn abort() -> ! {
    loop {
        unsafe {
            asm!("wfi");
        }
    }
}

#[no_mangle]
extern "C"
fn kmain() {

}
