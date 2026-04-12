cargo zigbuild --release --target aarch64-unknown-linux-gnu --bin rpi-test-app
cargo zigbuild --release --target aarch64-apple-darwin --bin test-app

echo RPi binary is at ./target/aarch64-unknown-linux-gnu/release/rpi-test-app
echo macOS binary is at ./target/aarch64-apple-darwin/release/test-app



# cargo zigbuild --release --target aarch64-unknown-linux-gnu.2.36
