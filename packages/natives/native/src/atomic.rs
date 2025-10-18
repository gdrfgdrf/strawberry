use std::sync::atomic::{AtomicI32, Ordering};
use flutter_rust_bridge::frb;

#[frb(opaque)]
pub struct AtomicCounter {
    value: AtomicI32,
}

impl AtomicCounter {
    #[frb(sync)]
    pub fn new(initial: i32) -> AtomicCounter {
        AtomicCounter {
            value: AtomicI32::new(initial),
        }
    }

    #[frb(sync)]
    pub fn increment(&self) -> i32 {
        self.value.fetch_add(1, Ordering::SeqCst) + 1
    }
    
    #[frb(sync)]
    pub fn decrement(&self) -> i32 {
        self.value.fetch_sub(1, Ordering::SeqCst) - 1
    }

    #[frb(sync)]
    pub fn get(&self) -> i32 {
        self.value.load(Ordering::SeqCst)
    }
    
    #[frb(sync)]
    pub fn set(&self, new: i32) {
        self.value.store(new, Ordering::SeqCst)
    }

    #[frb(sync)]
    pub fn compare_and_swap(&self, expected: i32, new: i32) -> i32 {
        self.value.compare_exchange(
            expected,
            new,
            Ordering::SeqCst,
            Ordering::SeqCst
        ).unwrap_or_else(|x| x)
    }

    #[frb(sync)]
    pub fn add(&self, value: i32) -> i32 {
        self.value.fetch_add(value, Ordering::SeqCst) + value
    }

    #[frb(sync)]
    pub fn sub(&self, value: i32) -> i32 {
        self.value.fetch_sub(value, Ordering::SeqCst) - value
    }
}

#[frb(opaque)]
pub struct AtomicBoolImpl {
    value: AtomicI32,
}

impl AtomicBoolImpl {
    #[frb(sync)]
    pub fn new(initial: bool) -> AtomicBoolImpl {
        AtomicBoolImpl {
            value: AtomicI32::new(initial as i32),
        }
    }

    #[frb(sync)]
    pub fn get(&self) -> bool {
        self.value.load(Ordering::SeqCst) != 0
    }

    #[frb(sync)]
    pub fn set(&self, value: bool) {
        self.value.store(value as i32, Ordering::SeqCst);
    }

    #[frb(sync)]
    pub fn compare_and_swap(&self, expected: bool, new: bool) -> bool {
        let expected_i32 = expected as i32;
        let new_i32 = new as i32;

        self.value.compare_exchange(
            expected_i32,
            new_i32,
            Ordering::SeqCst,
            Ordering::SeqCst
        ).is_ok()
    }
}

#[frb(opaque)]
pub struct AtomicApi;

impl AtomicApi {
    #[frb(sync)]
    pub fn create_counter(initial: i32) -> AtomicCounter {
        AtomicCounter::new(initial)
    }

    #[frb(sync)]
    pub fn create_bool(initial: bool) -> AtomicBoolImpl {
        AtomicBoolImpl::new(initial)
    }
}