extends Control
## Main menu screen. Dark bureaucratic aesthetic.

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/day_briefing/day_briefing.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
