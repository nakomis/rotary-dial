# rotary-dial

A reusable egui `RotaryDial` widget for a Raspberry Pi thermostat, with desktop and Pi test apps.

## Stack

- **Language**: Rust (edition 2021)
- **UI framework**: [egui](https://github.com/emilk/egui) — immediate-mode GUI, pure Rust
- **Target**: Raspberry Pi 5 + RC070S (Elecrow 7" 1024×600 IPS capacitive touch, HDMI+USB)
- **Mac build**: standard eframe native backend, no special flags needed

## Workspace layout

| Crate | Type | Purpose |
|---|---|---|
| `rotary-dial` | library | The reusable `RotaryDial` egui widget |
| `test-app` | binary | Minimal Mac desktop app to develop and test the dial |
| `rpi-test-app` | binary | Full-screen eframe app for the RC070S (1024×600, no decorations) |

## Architecture decisions

- The dial is drawn with egui's painter API (arcs, circles, text) — no separate widget crate needed.
- `RotaryDial::show(&mut self, ui: &mut egui::Ui) -> f32` draws the dial and returns the (possibly updated) setpoint.
- Temperature range: 5–30 °C, 0.5 °C increments.
- Interaction: click/drag anywhere in the dial's allocated rect.
- The struct holds `current_temperature` (read-only display) and `setpoint` (adjusted by drag).
- MQTT, sensors, ESP32 — all out of scope here; wired at the app layer.

## Language

British English throughout — colour not color, realise not realize, etc.

## Shepherd drones

This project uses shepherd drones for boilerplate generation. Specs live in `specs/`.
