# rotary-dial

A reusable Slint `RotaryDial` component for a Raspberry Pi thermostat, with a minimal Mac desktop test app.

## Stack

- **Language**: Rust (edition 2021)
- **UI framework**: [Slint](https://slint.dev) — `.slint` DSL for UI, Rust for logic
- **Target**: Raspberry Pi 5 + RC070S (Elecrow 7" 1024×600 IPS capacitive touch, HDMI+USB)
- **Mac build**: default Slint backend, no special flags needed

## Workspace layout

| Crate | Type | Purpose |
|---|---|---|
| `rotary-dial` | library | The reusable `RotaryDial` Slint component |
| `test-app` | binary | Minimal Mac desktop app to develop and test the dial |

## Architecture decisions

- The dial is built in Slint's `.slint` DSL using `Path` elements (SVG-style arcs). No dedicated dial crate.
- Temperature range: 5–30 °C, 0.5 °C increments.
- Interaction: touch/drag around the arc (no physical rotary encoder for now).
- The component exposes `current-temperature` (read-only) and `setpoint` (two-way bindable) properties.
- MQTT, sensors, ESP32, LUKS, NAS — all out of scope here; wired at the app layer later.

## Language

British English throughout — colour not color, realise not realize, etc.

## Shepherd drones

This project uses shepherd drones for boilerplate generation. Specs live in `specs/`.
