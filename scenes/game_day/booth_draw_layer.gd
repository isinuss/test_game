extends Control
## Pseudo-3D perspective overlay for the booth scene.
## Draws perspective floor grid, wall shadows, desk items, wall decorations,
## and architectural details on top of the base ColorRect structure.

var _time: float = 0.0
var _redraw_timer: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	_time += delta
	_redraw_timer += delta
	if _redraw_timer >= 0.066:
		_redraw_timer = 0.0
		queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 0.0 or h <= 0.0:
		return

	_draw_wall_shading(w, h)
	_draw_ceiling_panels(w, h)
	_draw_perspective_floor(w, h)
	_draw_baseboard_shadow(w, h)
	_draw_counter_depth(w, h)
	_draw_door_depth(w, h)
	_draw_wall_decor(w, h)
	_draw_desk_items(w, h)

# ── Wall corner & ceiling shadows ──────────────────────────────────────────

func _draw_wall_shading(w: float, h: float) -> void:
	var wall_top: float = 18.0
	var wall_bottom: float = h * 0.82

	# Left corner shadow gradient
	var shadow_w: float = 70.0
	var steps: int = 12
	for i in range(steps):
		var t: float = float(i) / float(steps)
		var alpha: float = 0.18 * (1.0 - t) * (1.0 - t)
		var strip: float = shadow_w / float(steps)
		draw_rect(Rect2(t * shadow_w, wall_top, strip + 1.0, wall_bottom - wall_top), Color(0.0, 0.0, 0.0, alpha))

	# Right corner shadow gradient
	for i in range(steps):
		var t: float = float(i) / float(steps)
		var alpha: float = 0.14 * (1.0 - t) * (1.0 - t)
		var strip: float = shadow_w / float(steps)
		draw_rect(Rect2(w - shadow_w + t * shadow_w, wall_top, strip + 1.0, wall_bottom - wall_top), Color(0.0, 0.0, 0.0, alpha))

	# Under-ceiling shadow (light falls downward)
	for i in range(10):
		var t: float = float(i) / 10.0
		var alpha: float = 0.1 * (1.0 - t) * (1.0 - t)
		draw_rect(Rect2(0, wall_top + t * 35.0, w, 4.0), Color(0.0, 0.0, 0.0, alpha))

# ── Ceiling panel lines & AC vent ──────────────────────────────────────────

func _draw_ceiling_panels(w: float, h: float) -> void:
	# Panel division lines
	var spacing: float = w / 6.0
	for i in range(1, 6):
		var x: float = i * spacing
		draw_line(Vector2(x, 0), Vector2(x, 14.0), Color(0.12, 0.11, 0.1, 0.4), 1.0)

	# AC vent unit
	var vx: float = w * 0.72
	draw_rect(Rect2(vx, 2.0, 52.0, 10.0), Color(0.19, 0.18, 0.16, 1.0))
	draw_rect(Rect2(vx, 2.0, 52.0, 10.0), Color(0.22, 0.2, 0.17, 1.0), false, 1.0)
	for i in range(6):
		var sy: float = 4.0 + i * 1.4
		draw_line(Vector2(vx + 4, sy), Vector2(vx + 48, sy), Color(0.1, 0.09, 0.08, 0.6), 1.0)

# ── Perspective floor grid ─────────────────────────────────────────────────

func _draw_perspective_floor(w: float, h: float) -> void:
	var floor_top: float = h * 0.82
	var floor_bottom: float = h
	var floor_h: float = floor_bottom - floor_top
	var vp_x: float = w * 0.42  # Vanishing point X (slightly left of center)

	# Horizontal perspective lines (closer together toward the back)
	for i in range(1, 10):
		var t: float = float(i) / 10.0
		var adjusted_t: float = pow(t, 0.55)
		var y: float = floor_top + floor_h * adjusted_t
		var alpha: float = 0.1 + 0.18 * t
		draw_line(Vector2(0, y), Vector2(w, y), Color(0.15, 0.11, 0.07, alpha), 1.0)

	# Vertical converging lines
	var num_lines: int = 14
	for i in range(num_lines):
		var ratio: float = float(i) / float(num_lines - 1)
		var bottom_x: float = w * ratio
		var spread: float = 0.55
		var top_x: float = lerp(vp_x - w * spread * 0.5, vp_x + w * spread * 0.5, ratio)
		var alpha: float = 0.12 + 0.08 * (1.0 - abs(ratio - 0.5) * 2.0)
		draw_line(Vector2(top_x, floor_top), Vector2(bottom_x, floor_bottom), Color(0.15, 0.11, 0.07, alpha), 1.0)

	# Floor light reflection strip (under the fluorescent lamp)
	var ref_y: float = floor_top + floor_h * 0.35
	draw_rect(Rect2(w * 0.32, ref_y, w * 0.36, 2.0), Color(0.3, 0.26, 0.2, 0.1))

# ── Baseboard shadow ───────────────────────────────────────────────────────

func _draw_baseboard_shadow(w: float, h: float) -> void:
	var baseboard_y: float = h * 0.82
	for i in range(5):
		var t: float = float(i) / 5.0
		var alpha: float = 0.1 * (1.0 - t)
		draw_rect(Rect2(0, baseboard_y - 5.0 + t * 5.0, w, 1.5), Color(0.0, 0.0, 0.0, alpha))

# ── Counter 3D depth ───────────────────────────────────────────────────────

func _draw_counter_depth(w: float, h: float) -> void:
	var ct_top: float = h * 0.86
	var ct_bottom: float = h * 0.95

	# Top surface highlight line
	draw_line(Vector2(0, ct_top), Vector2(w, ct_top), Color(0.48, 0.4, 0.3, 0.35), 1.5)

	# Front face darkening
	draw_rect(Rect2(0, h * 0.88, w, h * 0.06), Color(0.0, 0.0, 0.0, 0.06))

	# Bottom edge shadow
	draw_line(Vector2(0, ct_bottom), Vector2(w, ct_bottom), Color(0.1, 0.08, 0.05, 0.4), 1.0)

	# Shadow cast on floor below counter
	for i in range(6):
		var t: float = float(i) / 6.0
		var alpha: float = 0.14 * (1.0 - t) * (1.0 - t)
		draw_rect(Rect2(0, ct_bottom + t * 8.0, w, 1.5), Color(0.0, 0.0, 0.0, alpha))

	# Wood grain on counter surface
	draw_line(Vector2(w * 0.1, h * 0.87), Vector2(w * 0.38, h * 0.87), Color(0.28, 0.2, 0.13, 0.15), 1.0)
	draw_line(Vector2(w * 0.5, h * 0.872), Vector2(w * 0.78, h * 0.872), Color(0.28, 0.2, 0.13, 0.12), 1.0)
	draw_line(Vector2(w * 0.25, h * 0.865), Vector2(w * 0.6, h * 0.865), Color(0.28, 0.2, 0.13, 0.08), 1.0)

# ── Door corridor depth ────────────────────────────────────────────────────

func _draw_door_depth(w: float, h: float) -> void:
	var dl: float = 828.0  # Door inner left
	var dr: float = 920.0  # Door inner right
	var dt: float = 36.0   # Door top
	var db: float = 210.0  # Door bottom
	var cx: float = (dl + dr) / 2.0

	# Corridor vanishing point
	var cvp: Vector2 = Vector2(cx, dt + 35.0)

	# Corridor perspective lines
	# Left wall
	draw_line(Vector2(dl, db), Vector2(cvp.x - 18, cvp.y + 50), Color(0.07, 0.06, 0.05, 0.5), 1.0)
	draw_line(Vector2(dl, dt), Vector2(cvp.x - 18, cvp.y), Color(0.06, 0.05, 0.04, 0.3), 1.0)
	# Right wall
	draw_line(Vector2(dr, db), Vector2(cvp.x + 18, cvp.y + 50), Color(0.07, 0.06, 0.05, 0.5), 1.0)
	draw_line(Vector2(dr, dt), Vector2(cvp.x + 18, cvp.y), Color(0.06, 0.05, 0.04, 0.3), 1.0)

	# Far wall rectangle
	draw_rect(Rect2(cvp.x - 18, cvp.y, 36, 50), Color(0.13, 0.12, 0.1, 0.4))

	# Distant corridor light
	draw_rect(Rect2(cvp.x - 10, cvp.y + 4, 20, 4), Color(0.3, 0.28, 0.22, 0.25))

	# Door frame inner shadow (depth effect)
	draw_line(Vector2(dl, dt), Vector2(dl, db), Color(0.04, 0.03, 0.02, 0.5), 2.0)
	draw_line(Vector2(dr, dt), Vector2(dr, db), Color(0.04, 0.03, 0.02, 0.3), 1.5)

	# Floor line inside corridor
	draw_line(Vector2(dl, db - 30), Vector2(dr, db - 30), Color(0.08, 0.07, 0.06, 0.3), 1.0)

# ── Wall decorations ───────────────────────────────────────────────────────

func _draw_wall_decor(w: float, h: float) -> void:
	# ─── Bulletin board (above filing cabinet) ───
	var bb_x: float = 32.0
	var bb_y: float = 26.0
	# Cork board
	draw_rect(Rect2(bb_x, bb_y, 82.0, 52.0), Color(0.36, 0.28, 0.18, 1.0))
	draw_rect(Rect2(bb_x, bb_y, 82.0, 52.0), Color(0.28, 0.22, 0.14, 1.0), false, 2.0)
	# Pinned notes
	draw_rect(Rect2(bb_x + 5, bb_y + 8, 24.0, 20.0), Color(0.88, 0.85, 0.42, 0.85))  # Yellow sticky
	draw_rect(Rect2(bb_x + 34, bb_y + 5, 20.0, 28.0), Color(0.82, 0.8, 0.74, 0.85))   # White paper
	draw_rect(Rect2(bb_x + 58, bb_y + 12, 20.0, 16.0), Color(0.55, 0.78, 0.6, 0.75))  # Green sticky
	draw_rect(Rect2(bb_x + 10, bb_y + 34, 32.0, 14.0), Color(0.72, 0.8, 0.9, 0.75))   # Blue note
	# Pins
	draw_rect(Rect2(bb_x + 15, bb_y + 7, 3, 3), Color(0.9, 0.2, 0.12, 1.0))
	draw_rect(Rect2(bb_x + 42, bb_y + 4, 3, 3), Color(0.2, 0.5, 0.85, 1.0))
	draw_rect(Rect2(bb_x + 66, bb_y + 11, 3, 3), Color(0.2, 0.72, 0.3, 1.0))
	draw_rect(Rect2(bb_x + 24, bb_y + 33, 3, 3), Color(0.9, 0.82, 0.12, 1.0))
	# Text lines on white paper
	for i in range(4):
		draw_rect(Rect2(bb_x + 37, bb_y + 10 + i * 5, 14.0, 1.5), Color(0.3, 0.28, 0.25, 0.4))

	# ─── Framed certificate/photo (between clock and center) ───
	var fr_x: float = 310.0
	var fr_y: float = 48.0
	var fr_w: float = 56.0
	var fr_h: float = 44.0
	# Outer frame
	draw_rect(Rect2(fr_x, fr_y, fr_w, fr_h), Color(0.32, 0.25, 0.16, 1.0))
	# Inner mat
	draw_rect(Rect2(fr_x + 3, fr_y + 3, fr_w - 6, fr_h - 6), Color(0.72, 0.7, 0.62, 1.0))
	# Certificate content
	draw_rect(Rect2(fr_x + 6, fr_y + 6, fr_w - 12, fr_h - 12), Color(0.82, 0.8, 0.72, 1.0))
	# Header line
	draw_rect(Rect2(fr_x + 12, fr_y + 10, fr_w - 24, 3), Color(0.3, 0.28, 0.24, 0.5))
	# Body text lines
	for i in range(3):
		var lw: float = (fr_w - 20) * (0.9 - i * 0.15)
		draw_rect(Rect2(fr_x + 10, fr_y + 18 + i * 6, lw, 1.5), Color(0.35, 0.32, 0.28, 0.35))
	# Seal/stamp circle (bottom-right)
	draw_rect(Rect2(fr_x + fr_w - 18, fr_y + fr_h - 18, 10, 10), Color(0.7, 0.25, 0.2, 0.3))

	# ─── İş Güvenliği poster (right side) ───
	var po_x: float = 600.0
	var po_y: float = 45.0
	var po_w: float = 58.0
	var po_h: float = 75.0
	# Poster paper
	draw_rect(Rect2(po_x, po_y, po_w, po_h), Color(0.42, 0.4, 0.3, 1.0))
	# Poster border
	draw_rect(Rect2(po_x + 2, po_y + 2, po_w - 4, po_h - 4), Color(0.47, 0.44, 0.34, 1.0), false, 1.0)
	# Warning stripe header
	draw_rect(Rect2(po_x + 5, po_y + 5, po_w - 10, 12.0), Color(0.75, 0.25, 0.18, 0.85))
	# Hazard symbol (simplified triangle)
	var tri_cx: float = po_x + po_w / 2.0
	draw_rect(Rect2(tri_cx - 6, po_y + 28, 12, 14), Color(0.8, 0.7, 0.15, 0.6))
	draw_rect(Rect2(tri_cx - 2, po_y + 33, 4, 6), Color(0.2, 0.18, 0.15, 0.7))
	# Text lines
	for i in range(3):
		var lw: float = (po_w - 14) * (0.85 - i * 0.1)
		draw_rect(Rect2(po_x + 7, po_y + 50 + i * 7, lw, 2.5), Color(0.22, 0.2, 0.16, 0.45))
	# Pin at top
	draw_rect(Rect2(po_x + po_w / 2.0 - 2, po_y - 2, 4, 4), Color(0.85, 0.18, 0.12, 1.0))

	# ─── Calendar (near clock, right of it) ───
	var cal_x: float = 260.0
	var cal_y: float = 56.0
	var cal_w: float = 30.0
	var cal_h: float = 38.0
	draw_rect(Rect2(cal_x, cal_y, cal_w, cal_h), Color(0.88, 0.85, 0.78, 1.0))
	# Month header
	draw_rect(Rect2(cal_x, cal_y, cal_w, 9.0), Color(0.72, 0.2, 0.15, 0.9))
	# Day grid
	for row in range(4):
		for col in range(5):
			draw_rect(Rect2(cal_x + 3 + col * 5.2, cal_y + 13 + row * 6, 2.5, 2.5), Color(0.3, 0.28, 0.25, 0.35))
	# Today marker (highlighted)
	draw_rect(Rect2(cal_x + 3 + 2 * 5.2, cal_y + 13 + 1 * 6, 2.5, 2.5), Color(0.8, 0.25, 0.2, 0.7))
	# Pin
	draw_rect(Rect2(cal_x + cal_w / 2.0 - 1.5, cal_y - 2, 3, 3), Color(0.6, 0.55, 0.42, 1.0))

	# ─── Light switch (right wall) ───
	draw_rect(Rect2(770.0, 128.0, 11.0, 18.0), Color(0.78, 0.75, 0.68, 1.0))
	draw_rect(Rect2(770.0, 128.0, 11.0, 18.0), Color(0.65, 0.62, 0.55, 1.0), false, 1.0)
	draw_rect(Rect2(773.0, 131.0, 5.0, 6.0), Color(0.68, 0.65, 0.58, 1.0))

	# ─── Wall conduit pipe (vertical, right side) ───
	draw_line(Vector2(762, 18), Vector2(762, 128), Color(0.26, 0.24, 0.2, 0.5), 2.0)
	draw_line(Vector2(762, 128), Vector2(770, 128), Color(0.26, 0.24, 0.2, 0.5), 2.0)

	# ─── Wall texture lines (subtle cracks/seams) ───
	draw_line(Vector2(500, 60), Vector2(500, 180), Color(0.17, 0.16, 0.14, 0.3), 1.0)
	draw_line(Vector2(380, 100), Vector2(420, 100), Color(0.17, 0.16, 0.14, 0.15), 1.0)

# ── Desk / counter items ──────────────────────────────────────────────────

func _draw_desk_items(w: float, h: float) -> void:
	var surface_y: float = h * 0.86  # Counter top surface

	# ─── Desk lamp (far left) ───
	var dl_x: float = 26.0
	# Base
	draw_rect(Rect2(dl_x, surface_y - 5, 18.0, 4.0), Color(0.16, 0.16, 0.16, 0.9))
	# Stem
	draw_line(Vector2(dl_x + 9, surface_y - 5), Vector2(dl_x + 7, surface_y - 24), Color(0.18, 0.18, 0.18, 0.9), 2.0)
	# Shade
	draw_rect(Rect2(dl_x - 3, surface_y - 28, 22.0, 8.0), Color(0.26, 0.22, 0.16, 0.9))
	draw_rect(Rect2(dl_x - 3, surface_y - 28, 22.0, 8.0), Color(0.3, 0.25, 0.18, 1.0), false, 1.0)
	# Light glow
	draw_rect(Rect2(dl_x - 1, surface_y - 20, 18.0, 6.0), Color(0.45, 0.38, 0.25, 0.08))

	# ─── Pen holder ───
	var ph_x: float = 85.0
	# Holder body
	draw_rect(Rect2(ph_x, surface_y - 20, 16.0, 18.0), Color(0.2, 0.18, 0.16, 1.0))
	draw_rect(Rect2(ph_x + 1, surface_y - 20, 14.0, 2.5), Color(0.26, 0.23, 0.2, 1.0))  # Rim
	# Pens
	draw_line(Vector2(ph_x + 3, surface_y - 27), Vector2(ph_x + 4, surface_y - 6), Color(0.12, 0.12, 0.5, 0.85), 1.5)
	draw_line(Vector2(ph_x + 7, surface_y - 30), Vector2(ph_x + 7, surface_y - 6), Color(0.55, 0.12, 0.12, 0.85), 1.5)
	draw_line(Vector2(ph_x + 11, surface_y - 26), Vector2(ph_x + 10, surface_y - 6), Color(0.12, 0.42, 0.12, 0.85), 1.5)
	# Ruler
	draw_line(Vector2(ph_x + 14, surface_y - 32), Vector2(ph_x + 13, surface_y - 6), Color(0.55, 0.5, 0.2, 0.7), 1.5)

	# ─── Document / file stack ───
	var fs_x: float = 155.0
	# Stacked papers
	draw_rect(Rect2(fs_x - 1, surface_y - 5, 44.0, 4.0), Color(0.68, 0.65, 0.58, 0.9))
	draw_rect(Rect2(fs_x + 1, surface_y - 8, 40.0, 4.0), Color(0.72, 0.7, 0.62, 0.9))
	draw_rect(Rect2(fs_x + 3, surface_y - 11, 38.0, 4.0), Color(0.66, 0.62, 0.55, 0.9))
	# Manila folder on top
	draw_rect(Rect2(fs_x + 2, surface_y - 16, 38.0, 7.0), Color(0.68, 0.56, 0.35, 1.0))
	draw_rect(Rect2(fs_x + 2, surface_y - 16, 38.0, 2.5), Color(0.72, 0.6, 0.38, 1.0))  # Tab

	# ─── Name plate (center) ───
	var np_x: float = w * 0.44
	# Base stand
	draw_rect(Rect2(np_x, surface_y - 12, 64.0, 10.0), Color(0.3, 0.24, 0.16, 1.0))
	# Face plate
	draw_rect(Rect2(np_x + 3, surface_y - 11, 58.0, 7.0), Color(0.38, 0.32, 0.22, 1.0))
	# Name text line
	draw_rect(Rect2(np_x + 10, surface_y - 8, 44.0, 2.0), Color(0.62, 0.55, 0.4, 0.6))

	# ─── Stapler ───
	var st_x: float = w * 0.62
	draw_rect(Rect2(st_x, surface_y - 6, 26.0, 4.0), Color(0.14, 0.14, 0.14, 0.9))  # Base
	draw_rect(Rect2(st_x + 2, surface_y - 9, 22.0, 3.5), Color(0.18, 0.18, 0.18, 0.9))  # Top
	draw_rect(Rect2(st_x + 22, surface_y - 10, 4.0, 5.0), Color(0.16, 0.16, 0.16, 0.9))  # Hinge

	# ─── Coffee cup with animated steam ───
	var cc_x: float = w - 155.0
	# Cup body
	draw_rect(Rect2(cc_x, surface_y - 16, 14.0, 14.0), Color(0.82, 0.8, 0.74, 1.0))
	# Handle
	draw_rect(Rect2(cc_x + 14, surface_y - 12, 5.0, 8.0), Color(0.78, 0.76, 0.7, 1.0))
	draw_rect(Rect2(cc_x + 15, surface_y - 10, 3.0, 4.0), Color(0.2, 0.19, 0.17, 0.5))
	# Coffee inside
	draw_rect(Rect2(cc_x + 1, surface_y - 15, 12.0, 4.0), Color(0.22, 0.14, 0.06, 0.85))
	# Animated steam wisps
	_draw_steam(cc_x + 4, surface_y - 18)
	_draw_steam(cc_x + 9, surface_y - 17)

	# ─── Tape dispenser (far right) ───
	var td_x: float = w - 95.0
	draw_rect(Rect2(td_x, surface_y - 8, 18.0, 7.0), Color(0.2, 0.35, 0.2, 0.9))
	draw_rect(Rect2(td_x + 14, surface_y - 12, 6.0, 6.0), Color(0.18, 0.3, 0.18, 0.9))  # Roll

func _draw_steam(x: float, y: float) -> void:
	# Two wavy steam lines with gentle animation
	var wave1: float = sin(_time * 1.8) * 1.5
	var wave2: float = sin(_time * 2.2 + 1.0) * 1.2
	var alpha: float = 0.15 + sin(_time * 0.8) * 0.05
	draw_line(
		Vector2(x + wave1, y),
		Vector2(x + wave2 * 0.5, y - 8),
		Color(0.65, 0.62, 0.55, alpha), 1.0
	)
	draw_line(
		Vector2(x + wave2 * 0.5, y - 8),
		Vector2(x - wave1 * 0.3, y - 14),
		Color(0.65, 0.62, 0.55, alpha * 0.5), 1.0
	)
