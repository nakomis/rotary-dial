slint::include_modules!();

fn main() -> Result<(), slint::PlatformError> {
    let window = AppWindow::new()?;

    window.on_setpoint_changed(|setpoint| {
        println!("Setpoint: {:.1} °C", setpoint);
    });

    window.run()
}
