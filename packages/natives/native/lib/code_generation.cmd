del "../src/frb_generated.rs" /Q
cd ..
cd ..
flutter_rust_bridge_codegen generate --rust-input crate::atomic,crate::smtc --rust-root native --dart-output lib/ffi
cd native
cd lib