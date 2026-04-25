# rotary-dial

A reusable `RotaryDial` egui widget for a Raspberry Pi thermostat, with desktop and Pi test harnesses.

## Workspace layout

| Crate | Purpose |
|---|---|
| `rotary-dial` | Reusable `RotaryDial` egui widget library |
| `test-app` | Mac desktop test harness (400×400 window) |
| `rpi-test-app` | Pi harness — 1024×600 borderless, for the RC070S touch panel |

## Running the Mac test app

```bash
cargo run -p test-app
```

## Building for Raspberry Pi

### Option A — Cross-compile from Mac

Install prerequisites once:

```bash
brew install zig
cargo install cargo-zigbuild
rustup target add aarch64-unknown-linux-gnu
```

Build:

```bash
cargo zigbuild --release -p rpi-test-app --target aarch64-unknown-linux-gnu.2.36
```

Copy to the Pi:

```bash
scp target/aarch64-unknown-linux-gnu/release/rpi-test-app pi@<pi-ip>:~/
```

### Option B — Compile natively on the Pi

```bash
curl https://sh.rustup.rs -sSf | sh
sudo apt install -y libgl1 libfontconfig1 libxkbcommon0 pkg-config \
    libgl1-mesa-dev libfontconfig-dev libxkbcommon-dev libwayland-dev
git clone git@github.com:nakomis/rotary-dial.git
cd rotary-dial
cargo build --release -p rpi-test-app
```

## Running on the Pi

Install runtime dependencies:

```bash
sudo apt install -y libgl1 libfontconfig1 libxkbcommon0 cage
```

Run:

```bash
sudo XDG_RUNTIME_DIR=/tmp cage ~/rpi-test-app
```

## Auto-start on boot (systemd)

Copy the binary to a system location:

```bash
sudo cp ~/rpi-test-app /usr/local/bin/rpi-test-app
```

Create the service file:

```bash
sudo tee /etc/systemd/system/thermostat.service > /dev/null << 'EOF'
[Unit]
Description=Thermostat dial
After=multi-user.target

[Service]
Environment=XDG_RUNTIME_DIR=/tmp
ExecStart=/usr/bin/cage /usr/local/bin/rpi-test-app
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable thermostat
sudo systemctl start thermostat
```

Check status / logs:

```bash
sudo systemctl status thermostat
sudo journalctl -u thermostat -f
```
