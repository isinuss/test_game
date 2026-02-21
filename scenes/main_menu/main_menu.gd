extends Control
## Main menu screen. Dark bureaucratic aesthetic.
## Enhanced with title flicker, typewriter subtitle, and ambient effects.

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
@onready var title_label: Label = $VBox/Title
@onready var subtitle_label: Label = $VBox/Subtitle
@onready var footer_label: Label = $VBox/Footer

var _title_flicker_timer: float = 0.0
var _title_flicker_interval: float = 5.0

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Initial state — everything hidden for reveal
	title_label.modulate.a = 0.0
	subtitle_label.text = ""
	start_button.modulate.a = 0.0
	quit_button.modulate.a = 0.0
	footer_label.modulate.a = 0.0

	_animate_intro()

func _animate_intro() -> void:
	# Title fades in with slight scale
	title_label.pivot_offset = Vector2(title_label.size.x / 2.0, title_label.size.y / 2.0)
	title_label.scale = Vector2(1.1, 1.1)

	var title_tween: Tween = create_tween()
	title_tween.tween_interval(0.4)  # Wait for screen transition fade-in
	title_tween.tween_property(title_label, "modulate:a", 1.0, 0.8)
	title_tween.parallel().tween_property(title_label, "scale", Vector2.ONE, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Typewriter subtitle
	var full_subtitle: String = "İnsan Kaynakları Simülasyonu"
	var sub_tween: Tween = create_tween()
	sub_tween.tween_interval(1.4)
	subtitle_label.add_theme_color_override("font_color", Color(0.5, 0.47, 0.4, 1))
	for i in range(full_subtitle.length()):
		var idx: int = i + 1
		sub_tween.tween_callback(func() -> void:
			subtitle_label.text = full_subtitle.substr(0, idx)
		)
		sub_tween.tween_interval(0.04)

	# Buttons fade in
	var btn_tween: Tween = create_tween()
	btn_tween.tween_interval(2.6)
	btn_tween.tween_property(start_button, "modulate:a", 1.0, 0.4)
	btn_tween.tween_property(quit_button, "modulate:a", 1.0, 0.3)

	# Footer
	var footer_tween: Tween = create_tween()
	footer_tween.tween_interval(3.3)
	footer_tween.tween_property(footer_label, "modulate:a", 1.0, 0.5)

func _process(delta: float) -> void:
	# Subtle title glow flicker
	_title_flicker_timer += delta
	if _title_flicker_timer >= _title_flicker_interval:
		_title_flicker_timer = 0.0
		_title_flicker_interval = randf_range(3.0, 8.0)
		_do_title_flicker()

	# Subtle title color breathing
	var breath: float = (sin(Time.get_ticks_msec() * 0.001) + 1.0) * 0.5
	var base_color: Color = Color(0.85, 0.82, 0.75)
	title_label.add_theme_color_override("font_color", base_color.lerp(Color(0.75, 0.72, 0.65), breath * 0.3))

func _do_title_flicker() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 0.6, 0.03)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.03)
	tween.tween_property(title_label, "modulate:a", 0.75, 0.04)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.05)

func _on_start_pressed() -> void:
	start_button.disabled = true
	quit_button.disabled = true
	GameManager.start_new_game()
	ScreenTransition.transition_to("res://scenes/day_briefing/day_briefing.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
