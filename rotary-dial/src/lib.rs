// Expose the path to the RotaryDial Slint component so consumer build.rs
// scripts can locate it for import in their own .slint files.
pub fn slint_component_path() -> &'static str {
    concat!(env!("CARGO_MANIFEST_DIR"), "/ui/rotary-dial.slint")
}
