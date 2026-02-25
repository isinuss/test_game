extends Control
## Visual stamp mark that slams onto the screen when a decision is made.
## Shows "ONAYLANDI" or "REDDEDİLDİ" with ink stamp aesthetic.

var _stamp_color: Color = Color.WHITE
var _stamp_text: String = ""
var _stamp_alpha: float = 0.0
var _stamp_rotation: float = 0.0
var _stamp_visible: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

func show_stamp(hired: bool) -> void:
	if hired:
		_stamp_text = "ONAYLANDI"
		_stamp_color = Color(0.1, 0.55, 0.15, 0.85)
	else:
		_stamp_text = "REDDEDİLDİ"
		_stamp_color = Color(0.7, 0.1, 0.08, 0.85)

	_stamp_rotation = randf_range(-0.12, 0.12)
	_stamp_visible = true
	visible = true

	# Slam animation: start big, slam to normal size
	scale = Vector2(2.5, 2.5)
	modulate.a = 0.0
	pivot_offset = size / 2.0

	var tween: Tween = create_tween()
	# Quick slam in
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.05)
	# Brief hold
	tween.tween_interval(1.5)
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func() -> void:
		visible = false
		_stamp_visible = false
	)

	queue_redraw()

func _draw() -> void:
	if not _stamp_visible:
		return

	var center: Vector2 = size / 2.0

	# Draw rotated stamp
	draw_set_transform(center, _stamp_rotation, Vector2.ONE)

	# Outer border rectangle
	var rect_size: Vector2 = Vector2(280, 76)
	var rect: Rect2 = Rect2(-rect_size / 2.0, rect_size)
	draw_rect(rect, _stamp_color, false, 4.0)

	# Inner border
	var inner_rect: Rect2 = Rect2(-rect_size / 2.0 + Vector2(5, 5), rect_size - Vector2(10, 10))
	draw_rect(inner_rect, _stamp_color, false, 2.0)

	# Text
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 30
	var text_size: Vector2 = font.get_string_size(_stamp_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos: Vector2 = Vector2(-text_size.x / 2.0, text_size.y / 3.0)
	draw_string(font, text_pos, _stamp_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, _stamp_color)

	# Reset transform
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
