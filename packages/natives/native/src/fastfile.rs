#![allow(non_snake_case)]

use std::ffi::OsString;
use std::path::PathBuf;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

use lazy_static::lazy_static;
use lru::LruCache;
use memmap2::Mmap;
use parking_lot::Mutex;
use rand::Rng;
use std::fs::File;
use std::io::Result as IOResult;

type Handle = u64;

const DEFAULT_MAX_MMAP_BYTES: usize = 200 * 1024 * 1024;

lazy_static! {
    static ref GLOBAL_CACHE: Mutex<LruCache<Handle, Arc<MmapEntry>>> =
        Mutex::new(LruCache::unbounded());
    static ref GLOBAL_BYTES: Mutex<usize> = Mutex::new(0usize);
    static ref NEXT_HANDLE: AtomicU64 = AtomicU64::new(1);
}

struct MmapEntry {
    mmap: Mmap,
    size: usize,
}

fn next_handle() -> Handle {
    let v = NEXT_HANDLE.fetch_add(1, Ordering::Relaxed);
    if v == 0 {
        rand::rng().random::<u64>().max(1)
    } else {
        v
    }
}
 
fn path_buf_from_ptr_and_len(ptr: *const u8, len: usize) -> Option<PathBuf> {
    unsafe {
        if ptr.is_null() || len == 0 {
            return None;
        }
        let slice = std::slice::from_raw_parts(ptr, len);
        if let Ok(s) = std::str::from_utf8(slice) {
            return Some(PathBuf::from(s));
        }
        #[cfg(unix)]
        {
            use std::os::unix::ffi::OsStringExt;
            return Some(OsString::from_vec(slice.to_vec()).into());
        }
        #[cfg(windows)]
        {
            return Some(PathBuf::from(String::from_utf8_lossy(slice).to_string()));
        }
        Some(PathBuf::from(String::from_utf8_lossy(slice).to_string()))
    }
}

fn map_file(path_buf: &PathBuf) -> IOResult<Mmap> {
    let file = File::open(String::from(
        path_buf.canonicalize().unwrap().to_str().unwrap(),
    ))?;
    unsafe { Mmap::map(&file) }
}

fn insert_mmap_with_limit(mmap: Mmap, max_total_bytes: usize) -> Handle {
    let size = mmap.len();
    let entry = Arc::new(MmapEntry { mmap, size });
    let handle = next_handle();

    let mut cache = GLOBAL_CACHE.lock();
    let mut total = GLOBAL_BYTES.lock();

    cache.put(handle, entry.clone());
    *total += size;

    while *total > max_total_bytes {
        if let Some((_old_handle, old_entry)) = cache.pop_lru() {
            *total = total.saturating_sub(old_entry.size);
        } else {
            break;
        }
    }
    handle
}

fn lookup_map(handle: Handle) -> Option<Arc<MmapEntry>> {
    let mut cache = GLOBAL_CACHE.lock();
    if let Some(entry) = cache.get(&handle) {
        Some(entry.clone())
    } else {
        None
    }
}

fn remove_map(handle: Handle) {
    let mut cache = GLOBAL_CACHE.lock();
    if let Some(entry) = cache.pop(&handle) {
        let mut total = GLOBAL_BYTES.lock();
        *total = total.saturating_sub(entry.size);
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn set_max_mmap_bytes(max_bytes: u64) {
    let max = max_bytes as usize;
    let mut cache = GLOBAL_CACHE.lock();
    let mut total = GLOBAL_BYTES.lock();
    while *total > max {
        if let Some((_h, e)) = cache.pop_lru() {
            *total = total.saturating_sub(e.size);
        } else {
            break;
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn open_map32(path_ptr: *const u8, path_len: u32) -> Handle {
    open_map_internal(path_ptr, path_len as usize)
}

#[unsafe(no_mangle)]
pub extern "C" fn get_map_ptr32(handle: Handle, out_len_ptr: *mut u32) -> *const u8 {
    get_map_ptr_internal(handle, out_len_ptr as *mut usize)
}

#[unsafe(no_mangle)]
pub extern "C" fn open_map64(path_ptr: *const u8, path_len: u64) -> Handle {
    open_map_internal(path_ptr, path_len as usize)
}

#[unsafe(no_mangle)]
pub extern "C" fn get_map_ptr64(handle: Handle, out_len_ptr: *mut u64) -> *const u8 {
    get_map_ptr_internal(handle, out_len_ptr as *mut usize)
}

fn open_map_internal(path_ptr: *const u8, path_len: usize) -> Handle {
    let max_total = DEFAULT_MAX_MMAP_BYTES;

    let path_buf_opt = path_buf_from_ptr_and_len(path_ptr, path_len);
    let path_buf = match path_buf_opt {
        Some(p) => p,
        None => return 0,
    };

    match map_file(&path_buf) {
        Ok(mmap) => insert_mmap_with_limit(mmap, max_total),
        Err(_e) => 0,
    }
}

fn get_map_ptr_internal(handle: Handle, out_len_ptr: *mut usize) -> *const u8 {
    if handle == 0 {
        return 0 as *const u8;
    }
    if let Some(entry) = lookup_map(handle) {
        let len = entry.size;
        unsafe {
            if !out_len_ptr.is_null() {
                *out_len_ptr = len;
            }
        }
        entry.mmap.as_ptr()
    } else {
        0 as *const u8
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn close_map(handle: Handle) {
    if handle == 0 {
        return;
    }
    remove_map(handle);
}
