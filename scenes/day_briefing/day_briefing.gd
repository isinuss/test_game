extends Control
## Morning briefing screen: newspaper headline + directives for today.

@onready var day_label: Label = %DayLabel
@onready var headline_label: Label = %HeadlineLabel
@onready var directives_container: VBoxContainer = %DirectivesContainer
@onready var start_button: Button = %StartDayButton
@onready var memo_label: Label = %MemoLabel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	_populate()

func _populate() -> void:
	var config: Dictionary = GameManager.get_day_config()
	day_label.text = config.get("title", "Gün ?")
	headline_label.text = config.get("headline", "")

	# Show directives
	var directives: Array[DirectiveData] = DirectivePool.get_directives_for_day(GameManager.current_day)
	for d: DirectiveData in directives:
		var lbl: Label = Label.new()
		lbl.text = "• " + d.directive_text
		lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		directives_container.add_child(lbl)

	# Memo text
	match GameManager.current_day:
		1: memo_label.text = "Yönetimden: \"Hoş geldiniz. Bugün ilk gününüz. Kuralları okuyun ve doğru kararlar verin.\""
		2: memo_label.text = "Yönetimden: \"Bütçe kısıtlaması var. Mühendislik alımları durduruldu.\""
		3: memo_label.text = "Yönetimden: \"Bugün önemli misafirlerimiz olabilir. Dikkatli olun.\""
		4: memo_label.text = "Yönetimden: \"Sendika baskısı artıyor ama bütçe de yok. Kuralları takip edin.\""
		5: memo_label.text = "Yönetimden: \"Soruşturma başladı. Her şeyi kayıt altına alın.\""

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_day/game_day.tscn")
