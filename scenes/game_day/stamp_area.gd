extends Control
## HIRE/REJECT stamp buttons with animation, visual feedback, and screen shake.

signal stamp_pressed(hired: bool)

@onready var hire_button: Button = %HireButton
@onready var reject_button: Button = %RejectButton
@onready var next_button: Button = %NextButton
@onready var status_label: Label = %StampStatusLabel

var _buttons_enabled: bool = false

func _ready() -> void:
	hire_button.pressed.connect(_on_hire)
	reject_button.pressed.connect(_on_reject)
	set_buttons_enabled(false)
	next_button.visible = false

func set_buttons_enabled(enabled: bool) -> void:
	_buttons_enabled = enabled
	hire_button.disabled = not enabled
	reject_button.disabled = not enabled
	if enabled:
		status_label.text = "Karar bekleniyor..."
		status_label.add_theme_color_override("font_color", Color(0.6, 0.58, 0.5))
		# Subtle pulse to draw attention
		_pulse_buttons()

func _pulse_buttons() -> void:
	if not _buttons_enabled:
		return
	var tween: Tween = create_tween().set_loops(3)
	tween.tween_property(hire_button, "modulate:a", 0.7, 0.4)
	tween.tween_property(hire_button, "modulate:a", 1.0, 0.4)

func _on_hire() -> void:
	if not _buttons_enabled:
		return
	set_buttons_enabled(false)
	_play_stamp_animation(hire_button)
	status_label.text = "İŞE ALINDI"
	status_label.add_theme_color_override("font_color", Color(0.1, 0.6, 0.2))
	_show_stamp_overlay(true)
	_screen_shake(4.0, 0.15)
	stamp_pressed.emit(true)

func _on_reject() -> void:
	if not _buttons_enabled:
		return
	set_buttons_enabled(false)
	_play_stamp_animation(reject_button)
	status_label.text = "REDDEDİLDİ"
	status_label.add_theme_color_override("font_color", Color(0.7, 0.15, 0.1))
	_show_stamp_overlay(false)
	_screen_shake(5.0, 0.18)
	stamp_pressed.emit(false)

func _play_stamp_animation(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	var tween: Tween = create_tween()
	# Slam down
	tween.tween_property(btn, "scale", Vector2(0.85, 0.85), 0.06)
	# Bounce back
	tween.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08)

	# Status label slam
	status_label.pivot_offset = Vector2(status_label.size.x / 2.0, 0)
	var lbl_tween: Tween = create_tween()
	lbl_tween.tween_property(status_label, "scale", Vector2(1.3, 1.3), 0.08)
	lbl_tween.tween_property(status_label, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT)

func _show_stamp_overlay(hired: bool) -> void:
	var game_day: Node = get_tree().current_scene
	if game_day == null:
		return
	var overlay: Node = game_day.find_child("StampOverlay", true, false)
	if overlay and overlay.has_method("show_stamp"):
		overlay.show_stamp(hired)

func _screen_shake(intensity: float, duration: float) -> void:
	var game_day: Node = get_tree().current_scene
	if game_day == null:
		return

	var original_pos: Vector2 = game_day.position
	var tween: Tween = create_tween()
	var steps: int = 6
	var step_time: float = duration / steps

	for i in range(steps):
		var offset: Vector2 = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		var decay: float = 1.0 - float(i) / float(steps)
		tween.tween_property(game_day, "position", original_pos + offset * decay, step_time)

	tween.tween_property(game_day, "position", original_pos, step_time)

func show_result(correct: bool, reason: String) -> void:
	if not correct:
		status_label.text += "\n⚠ İHLAL: " + reason
		status_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.1))
		# Intense flash for violation
		var tween: Tween = create_tween()
		tween.tween_property(status_label, "modulate", Color(1, 0.2, 0.2), 0.1)
		tween.tween_property(status_label, "modulate", Color.WHITE, 0.1)
		tween.tween_property(status_label, "modulate", Color(1, 0.2, 0.2), 0.1)
		tween.tween_property(status_label, "modulate", Color.WHITE, 0.1)
		tween.tween_property(status_label, "modulate", Color(1, 0.2, 0.2), 0.1)
		tween.tween_property(status_label, "modulate", Color.WHITE, 0.15)
		# Extra screen shake for violation
		_screen_shake(8.0, 0.3)

func show_next_button() -> void:
	next_button.visible = true

func hide_next_button() -> void:
	next_button.visible = false

func reset_status() -> void:
	status_label.text = ""
	status_label.add_theme_color_override("font_color", Color(0.6, 0.58, 0.5))
	next_button.visible = false
	hire_button.modulate.a = 1.0
	reject_button.modulate.a = 1.0
