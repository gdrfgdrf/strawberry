cd ..
cargo ndk -t armeabi-v7a -o lib build --release
cargo ndk -t arm64-v8a -o lib build --release
cargo ndk -t x86_64  -o lib build --release
cargo ndk -t x86 -o lib build --release
cargo build --target x86_64-pc-windows-msvc --target-dir lib --release
cd native