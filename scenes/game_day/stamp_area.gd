extends Control
## HIRE/REJECT stamp buttons with animation and visual feedback.

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

func _on_hire() -> void:
	if not _buttons_enabled:
		return
	set_buttons_enabled(false)
	_play_stamp_animation(hire_button)
	status_label.text = "İŞE ALINDI"
	status_label.add_theme_color_override("font_color", Color(0.1, 0.6, 0.2))
	stamp_pressed.emit(true)

func _on_reject() -> void:
	if not _buttons_enabled:
		return
	set_buttons_enabled(false)
	_play_stamp_animation(reject_button)
	status_label.text = "REDDEDİLDİ"
	status_label.add_theme_color_override("font_color", Color(0.7, 0.15, 0.1))
	stamp_pressed.emit(false)

func _play_stamp_animation(btn: Button) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.08)
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.06)

func show_result(correct: bool, reason: String) -> void:
	if not correct:
		status_label.text += "\n⚠ İHLAL: " + reason
		status_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.1))
		# Flash effect
		var tween: Tween = create_tween()
		tween.tween_property(status_label, "modulate", Color(1, 0.3, 0.3), 0.15)
		tween.tween_property(status_label, "modulate", Color.WHITE, 0.15)
		tween.tween_property(status_label, "modulate", Color(1, 0.3, 0.3), 0.15)
		tween.tween_property(status_label, "modulate", Color.WHITE, 0.15)

func show_next_button() -> void:
	next_button.visible = true

func hide_next_button() -> void:
	next_button.visible = false

func reset_status() -> void:
	status_label.text = ""
	status_label.add_theme_color_override("font_color", Color(0.6, 0.58, 0.5))
	next_button.visible = false
