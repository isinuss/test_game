extends Control
## Final ending screen. Displays ending based on accumulated game state.
## Enhanced with dramatic reveal and transitions.

@onready var title_label: Label = %EndingTitle
@onready var text_label: Label = %EndingText
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	menu_button.pressed.connect(_on_menu)
	menu_button.modulate.a = 0.0
	menu_button.disabled = true
	_show_ending()

func _show_ending() -> void:
	var ending: Dictionary = GameManager.get_ending()

	# Title — dramatic fade in with scale
	var full_title: String = ending.get("title", "SON")
	title_label.text = full_title
	title_label.modulate.a = 0.0
	title_label.pivot_offset = Vector2(title_label.size.x / 2.0, title_label.size.y / 2.0)
	title_label.scale = Vector2(1.5, 1.5)

	var title_tween: Tween = create_tween()
	title_tween.tween_interval(0.8)
	title_tween.tween_property(title_label, "modulate:a", 1.0, 1.2)
	title_tween.parallel().tween_property(title_label, "scale", Vector2.ONE, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Color the title based on ending
	var ending_id: String = ending.get("id", "neutral")
	match ending_id:
		"fired":
			title_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.1))
		"whistleblower":
			title_label.add_theme_color_override("font_color", Color(0.3, 0.75, 0.9))
		"corrupt":
			title_label.add_theme_color_override("font_color", Color(0.6, 0.5, 0.2))
		"promoted":
			title_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.3))
		_:
			title_label.add_theme_color_override("font_color", Color(0.7, 0.67, 0.6))

	text_label.text = ""

	# Typewriter effect for ending text
	var full_text: String = ending.get("text", "")
	var char_delay: float = 0.03
	var total_time: float = 2.5  # Start after title animation

	var text_tween: Tween = create_tween()
	text_tween.tween_interval(total_time)
	for i in range(full_text.length()):
		var idx: int = i + 1
		var c: String = full_text[i]
		text_tween.tween_callback(func() -> void:
			text_label.text = full_text.substr(0, idx)
		)
		# Pause longer on newlines and periods for dramatic effect
		if c == "\n":
			text_tween.tween_interval(char_delay * 8.0)
		elif c == ".":
			text_tween.tween_interval(char_delay * 4.0)
		else:
			text_tween.tween_interval(char_delay)
		total_time += char_delay

	# Show menu button after text finishes
	var btn_tween: Tween = create_tween()
	var btn_wait: float = 2.5 + full_text.length() * char_delay + 1.5
	btn_tween.tween_interval(btn_wait)
	btn_tween.tween_property(menu_button, "modulate:a", 1.0, 0.5)
	btn_tween.tween_callback(func() -> void:
		menu_button.disabled = false
	)

func _on_menu() -> void:
	menu_button.disabled = true
	GameManager.state = GameManager.GameState.MENU
	ScreenTransition.transition_to("res://scenes/main_menu/main_menu.tscn", 0.8, 0.6)
