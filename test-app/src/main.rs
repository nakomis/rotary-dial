use eframe::egui;
use rotary_dial::RotaryDial;

struct App {
    dial: RotaryDial,
    last_setpoint: f32,
}

impl App {
    fn new(_cc: &eframe::CreationContext<'_>) -> Self {
        Self {
            dial: RotaryDial::new(18.0, 20.0),
            last_setpoint: 20.0,
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default()
            .frame(egui::Frame::new().fill(egui::Color32::from_rgb(0x1a, 0x1a, 0x2e)))
            .show(ctx, |ui| {
                ui.centered_and_justified(|ui| {
                    let new_setpoint = self.dial.show(ui);
                    if (new_setpoint - self.last_setpoint).abs() > f32::EPSILON {
                        println!("Setpoint: {:.1} °C", new_setpoint);
                        self.last_setpoint = new_setpoint;
                    }
                });
            });
    }
}

fn main() -> eframe::Result<()> {
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([400.0, 400.0])
            .with_title("Rotary Dial Test"),
        ..Default::default()
    };
    eframe::run_native(
        "Rotary Dial Test",
        options,
        Box::new(|cc| Ok(Box::new(App::new(cc)))),
    )
}
