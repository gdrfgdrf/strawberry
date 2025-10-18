#[unsafe(no_mangle)]
pub extern "C" fn create_buffer(size: u32) -> *mut u8 {
    let size: usize = size as usize;
    let buffer: Vec<u8> = vec![0u8; size];
    let ptr: *mut u8 = buffer.as_ptr() as *mut u8;
    std::mem::forget(buffer);
    ptr
}

#[unsafe(no_mangle)]
pub extern "C" fn release_buffer(ptr: *mut u8, len: u32) {
    let len: usize = len as usize;
    unsafe {
        let _ = Vec::from_raw_parts(ptr, len, len);
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn create_float_buffer(size: u32) -> *mut f32 {
    let size: usize = size as usize;
    let buffer: Vec<f32> = vec![0f32; size];
    let ptr: *mut f32 = buffer.as_ptr() as *mut f32;
    std::mem::forget(buffer);
    ptr
}

#[unsafe(no_mangle)]
pub extern "C" fn release_float_buffer(ptr: *mut f32, len: u32) {
    let len: usize = len.clone() as usize;
    unsafe {
        let _ = Vec::from_raw_parts(ptr, len, len);
    }
}

pub fn get_string_from_ptr(ptr: *const u8, len: u32) -> Option<String> {
    if ptr.is_null() {
        None
    } else {
        Some(
            unsafe { std::str::from_utf8_unchecked(std::slice::from_raw_parts(ptr, len as usize)) }
                .to_string(),
        )
    }
}

pub fn get_int_vec_from_ptr(ptr: *const i32, len: &u32) -> Option<Vec<i32>> {
    if ptr.is_null() || len <= &0 {
        return None;
    }
    unsafe { Some(std::slice::from_raw_parts(ptr, len.clone() as usize).to_vec()) }
}

pub fn get_float_vec_from_ptr(ptr: *const f32, len: &u32) -> Option<Vec<f32>> {
    if ptr.is_null() || len <= &0 {
        return None;
    }
    unsafe { Some(std::slice::from_raw_parts(ptr, len.clone() as usize).to_vec()) }
}

pub fn get_byte_vec_from_ptr(ptr: *const u8, len: &u32) -> Option<Vec<u8>> {
    if ptr.is_null() || len <= &0 {
        return None;
    }
    unsafe { Some(std::slice::from_raw_parts(ptr, len.clone() as usize).to_vec()) }
}