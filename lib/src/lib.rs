extern crate libc;

use libc::c_char;
use libc::size_t;
use std::ffi::CString;
use std::ffi::CStr;
use std::slice;

// Returning a number
// Disable name mangling for linking
#[no_mangle]
pub extern fn return_one() -> u64 {
    return 1
}

#[no_mangle]
pub extern fn add_one(i: u64) -> u64 {
    return i+1
}


// Returning a string
#[no_mangle]
pub extern fn return_string() -> *mut c_char {
    let res =  String::from("bar");
    let c_str_res = CString::new(res).unwrap();
    c_str_res.into_raw()
}


#[no_mangle]
pub extern fn free_string(s: *mut c_char) {
    unsafe {
        if s.is_null() {
            return;
        }
        CString::from_raw(s)
    };
}

// the Rust code does not own the string slice, and the compiler will only allow
// the string to live as long as the CStr instance
#[no_mangle]
pub extern fn how_many_characters(s: *const c_char) -> u32 {
    let c_str = unsafe {
        assert!(!s.is_null());

        CStr::from_ptr(s)
    };

    let r_str = c_str.to_str().unwrap();
    r_str.chars().count() as u32
}

#[no_mangle]
pub extern fn sum_of_array(n: *const u32, len: size_t) -> u32 {
    let numbers = unsafe {
        assert!(!n.is_null());

        slice::from_raw_parts(n, len as usize)
    };

    numbers
        .iter()
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn foo_returns_1() {
        assert_eq!(return_one(), 1);
    }

    #[test]
    fn add_one_returns_i_plus_1() {
        assert_eq!(add_one(0), 1);
    }
}
