extends Control
## Final ending screen. Displays ending based on accumulated game state.

@onready var title_label: Label = %EndingTitle
@onready var text_label: Label = %EndingText
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	menu_button.pressed.connect(_on_menu)
	menu_button.modulate.a = 0.0
	_show_ending()

func _show_ending() -> void:
	var ending: Dictionary = GameManager.get_ending()

	title_label.text = ending.get("title", "SON")
	text_label.text = ""

	# Typewriter effect for ending text
	var full_text: String = ending.get("text", "")
	var char_delay: float = 0.03
	var total_time: float = 0.0

	for i in range(full_text.length()):
		var tween: Tween = create_tween()
		tween.tween_interval(total_time)
		var idx: int = i + 1
		tween.tween_callback(func() -> void:
			text_label.text = full_text.substr(0, idx)
		)
		total_time += char_delay

	# Show menu button after text finishes
	var btn_tween: Tween = create_tween()
	btn_tween.tween_interval(total_time + 1.0)
	btn_tween.tween_property(menu_button, "modulate:a", 1.0, 0.5)

func _on_menu() -> void:
	GameManager.state = GameManager.GameState.MENU
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
