# Spec: RotaryDial egui widget

## Target file
`rotary-dial/src/lib.rs`

## Action
Replace entire file

## Description
Implement a reusable `RotaryDial` egui widget as a Rust struct. The widget renders a
thermostat-style rotary dial and handles drag interaction to adjust a setpoint temperature.

## Visual design
- A 240° arc track, starting at 150° (lower-left) and ending at 30° (lower-right), gap at the
  bottom. Angles measured clockwise from the positive-x axis.
- Track colour: `Color32::from_rgb(0x33, 0x33, 0x44)`
- An orange filled arc from arc-start to the setpoint angle:
  colour `Color32::from_rgb(0xff, 0x66, 0x00)`
- A blue dot at the current temperature position:
  colour `Color32::from_rgb(0x44, 0x88, 0xff)`, radius 7.0, white 2px border
- A white draggable handle at the setpoint position:
  radius 11.0, white fill, orange 2px border
- Centre text: setpoint in large white text (font size 48), e.g. "20°"
- Below centre: current temp in small blue text (font size 14), e.g. "now  18°"
- Arc stroke width: 12.0

## Public API

```rust
pub struct RotaryDial {
    pub current_temperature: f32,  // read-only sensor value
    pub setpoint: f32,             // two-way; updated by drag
    pub min_temperature: f32,      // default 5.0
    pub max_temperature: f32,      // default 30.0
}

impl RotaryDial {
    pub fn new(current_temperature: f32, setpoint: f32) -> Self;
    // Returns the (possibly updated) setpoint after handling input.
    pub fn show(&mut self, ui: &mut egui::Ui) -> f32;
}
```

## Implementation notes

### Geometry helpers
- `cx`, `cy`: centre of the widget rect
- `radius`: `rect.width().min(rect.height()) / 2.0 - 24.0`
- `temp_to_angle(t)`: maps temperature linearly to degrees →
  `150.0 + (t - min) / (max - min) * 240.0`
- `point_on_arc(cx, cy, radius, angle_deg)`: returns `egui::Pos2` using
  `cos`/`sin` on `angle_deg.to_radians()`

### Arc drawing
Use `egui::Shape::Path` (via `epaint::PathShape`) with `closed: false` and a stroke.
To draw an arc, tessellate it as a polyline: generate N=64 intermediate angle steps, collect
`Pos2` points, create a `PathShape { points, closed: false, fill: Color32::TRANSPARENT, stroke }`.

For the orange setpoint arc: generate points from start_deg to setpoint_angle (step 64 segments).
For the grey track arc: generate points from 150° to 390° (which equals 30°) (64 segments).

### Drag interaction
- Allocate the full widget rect as interactive: `ui.allocate_rect(rect, egui::Sense::drag())`
- On drag: compute `atan2(pointer_y - cy, pointer_x - cx).to_degrees()`
- Normalise to `[0, 360)`, shift by −150° so arc-start = 0
- If shifted < −60°, add 360° (wraps the gap correctly)
- Clamp to `[0, 240]`, map back to temperature
- Snap to nearest 0.5°: `(raw * 2.0).round() / 2.0`

### Widget sizing
- Request a square of `egui::Vec2::splat(300.0)` via `ui.allocate_space`

## Dependencies
`egui = "0.31"` (already in Cargo.toml)

## Constraints
- No `unsafe`
- No additional crates beyond egui
- All floating-point angles in degrees internally; convert to radians only at cos/sin call sites
- Keep the entire implementation in `lib.rs` (no submodules)
