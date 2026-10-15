use egui::{Align2, Color32, FontId, Pos2, Sense, Shape, Stroke, Ui, Vec2};
use egui::epaint::{PathShape, PathStroke};

#[derive(Clone, Copy, PartialEq)]
pub struct RotaryDial {
    pub current_temperature: f32,
    pub setpoint: f32,
    pub min_temperature: f32,
    pub max_temperature: f32,
}

impl RotaryDial {
    pub fn new(current_temperature: f32, setpoint: f32) -> Self {
        Self {
            current_temperature,
            setpoint,
            min_temperature: 5.0,
            max_temperature: 30.0,
        }
    }

    /// Draw the dial and return the (possibly updated) setpoint.
    pub fn show(&mut self, ui: &mut Ui) -> f32 {
        let size = ui.available_size().min_elem().max(100.0);
        let (_id, rect) = ui.allocate_space(Vec2::splat(size));
        let response = ui.allocate_rect(rect, Sense::drag());

        let cx = rect.center().x;
        let cy = rect.center().y;
        let radius = rect.width().min(rect.height()) / 2.0 - 24.0;

        let painter = ui.painter();

        // Track arc: 150° → 390° (≡ 30°)
        painter.add(Shape::Path(PathShape {
            points: arc_points(cx, cy, radius, 150.0, 390.0, 64),
            closed: false,
            fill: Color32::TRANSPARENT,
            stroke: PathStroke::new(12.0, Color32::from_rgb(0x33, 0x33, 0x44)),
        }));

        // Setpoint arc: 150° → setpoint angle
        let setpoint_angle = self.temp_to_angle(self.setpoint);
        if setpoint_angle > 150.0 {
            painter.add(Shape::Path(PathShape {
                points: arc_points(cx, cy, radius, 150.0, setpoint_angle, 64),
                closed: false,
                fill: Color32::TRANSPARENT,
                stroke: PathStroke::new(12.0, Color32::from_rgb(0x3a, 0x6a, 0x8a)),
            }));
        }

        // Current temperature blue dot
        let cur_pos = point_on_arc(cx, cy, radius, self.temp_to_angle(self.current_temperature));
        painter.circle_filled(cur_pos, 7.0, Color32::from_rgb(0x44, 0x88, 0xff));
        painter.circle_stroke(cur_pos, 7.0, Stroke::new(2.0, Color32::WHITE));

        // Setpoint handle (white circle, dark blue-grey border)
        let handle_pos = point_on_arc(cx, cy, radius, setpoint_angle);
        painter.circle_filled(handle_pos, 11.0, Color32::WHITE);
        painter.circle_stroke(handle_pos, 11.0, Stroke::new(2.0, Color32::from_rgb(0x3a, 0x6a, 0x8a)));

        // Centre: setpoint value
        painter.text(
            Pos2::new(cx, cy - 10.0),
            Align2::CENTER_CENTER,
            format!("{:.1}°", self.setpoint),
            FontId::proportional(48.0),
            Color32::WHITE,
        );

        // Below centre: current temperature
        painter.text(
            Pos2::new(cx, cy + 30.0),
            Align2::CENTER_CENTER,
            format!("now  {:.1}°", self.current_temperature),
            FontId::proportional(14.0),
            Color32::from_rgb(0x44, 0x88, 0xff),
        );

        // Drag interaction — skip the first frame so that a tap that also opens the
        // widget doesn't move the setpoint before the user has intentionally dragged.
        if response.dragged() && !response.drag_started() {
            if let Some(pos) = response.interact_pointer_pos() {
                let dx = pos.x - cx;
                let dy = pos.y - cy;
                let angle_deg = dy.atan2(dx).to_degrees();
                let norm = if angle_deg < 0.0 { angle_deg + 360.0 } else { angle_deg };
                let shifted = norm - 150.0;
                let adj = if shifted < -60.0 { shifted + 360.0 } else { shifted };
                let clamped = adj.clamp(0.0, 240.0);
                let raw = self.min_temperature
                    + clamped / 240.0 * (self.max_temperature - self.min_temperature);
                self.setpoint = (raw * 2.0).round() / 2.0;
            }
        }

        self.setpoint
    }

    fn temp_to_angle(&self, temp: f32) -> f32 {
        150.0
            + (temp - self.min_temperature) / (self.max_temperature - self.min_temperature)
                * 240.0
    }
}

fn arc_points(cx: f32, cy: f32, radius: f32, start_deg: f32, end_deg: f32, segments: usize) -> Vec<Pos2> {
    (0..=segments)
        .map(|i| {
            let t = i as f32 / segments as f32;
            let angle = (start_deg + t * (end_deg - start_deg)).to_radians();
            Pos2::new(cx + radius * angle.cos(), cy + radius * angle.sin())
        })
        .collect()
}

fn point_on_arc(cx: f32, cy: f32, radius: f32, angle_deg: f32) -> Pos2 {
    let rad = angle_deg.to_radians();
    Pos2::new(cx + radius * rad.cos(), cy + radius * rad.sin())
}
