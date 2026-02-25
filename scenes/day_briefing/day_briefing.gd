extends Control
## Morning briefing screen: newspaper headline + directives for today.
## Enhanced with slam animation, staggered reveals, and typewriter memo.

@onready var day_label: Label = %DayLabel
@onready var headline_label: Label = %HeadlineLabel
@onready var directives_container: VBoxContainer = %DirectivesContainer
@onready var start_button: Button = %StartDayButton
@onready var memo_label: Label = %MemoLabel
@onready var newspaper_panel: PanelContainer = $MarginContainer/VBox/NewspaperPanel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	_populate()

func _populate() -> void:
	var config: Dictionary = GameManager.get_day_config()

	# === DAY LABEL — typewriter reveal ===
	var full_day_text: String = config.get("title", "Gün ?")
	day_label.text = ""
	day_label.modulate.a = 1.0

	var day_tween: Tween = create_tween()
	day_tween.tween_interval(0.3)
	for i in range(full_day_text.length()):
		var idx: int = i + 1
		day_tween.tween_callback(func() -> void:
			day_label.text = full_day_text.substr(0, idx)
		)
		day_tween.tween_interval(0.035)

	# === NEWSPAPER HEADLINE — slam effect ===
	headline_label.text = config.get("headline", "")
	newspaper_panel.pivot_offset = Vector2(newspaper_panel.size.x / 2.0, newspaper_panel.size.y / 2.0)
	newspaper_panel.scale = Vector2(1.8, 1.8)
	newspaper_panel.modulate.a = 0.0

	var news_tween: Tween = create_tween()
	news_tween.tween_interval(1.0)
	# Slam in
	news_tween.tween_property(newspaper_panel, "modulate:a", 1.0, 0.08)
	news_tween.parallel().tween_property(newspaper_panel, "scale", Vector2(0.95, 0.95), 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# Settle
	news_tween.tween_property(newspaper_panel, "scale", Vector2(1.0, 1.0), 0.1)

	# === DIRECTIVES — staggered fade-in ===
	var directives: Array[DirectiveData] = DirectivePool.get_directives_for_day(GameManager.current_day)
	var directive_delay: float = 1.8
	for d: DirectiveData in directives:
		var lbl: Label = Label.new()
		lbl.text = "• " + d.directive_text
		lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
		lbl.add_theme_font_size_override("font_size", 15)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.modulate.a = 0.0
		directives_container.add_child(lbl)

		var d_tween: Tween = create_tween()
		d_tween.tween_interval(directive_delay)
		d_tween.tween_property(lbl, "modulate:a", 1.0, 0.3)
		directive_delay += 0.35

	# === MEMO — typewriter effect ===
	var full_memo: String = ""
	match GameManager.current_day:
		1: full_memo = "Yönetimden: \"Hoş geldiniz. Bugün ilk gününüz. Kuralları okuyun ve doğru kararlar verin.\""
		2: full_memo = "Yönetimden: \"Bütçe kısıtlaması var. Mühendislik alımları durduruldu.\""
		3: full_memo = "Yönetimden: \"Bugün önemli misafirlerimiz olabilir. Dikkatli olun.\""
		4: full_memo = "Yönetimden: \"Sendika baskısı artıyor ama bütçe de yok. Kuralları takip edin.\""
		5: full_memo = "Yönetimden: \"Soruşturma başladı. Her şeyi kayıt altına alın.\""

	memo_label.text = ""
	var memo_tween: Tween = create_tween()
	memo_tween.tween_interval(directive_delay + 0.3)
	for i in range(full_memo.length()):
		var idx: int = i + 1
		memo_tween.tween_callback(func() -> void:
			memo_label.text = full_memo.substr(0, idx)
		)
		memo_tween.tween_interval(0.02)

	# === START BUTTON — fade in at the end ===
	start_button.modulate.a = 0.0
	start_button.disabled = true
	var btn_tween: Tween = create_tween()
	var total_wait: float = directive_delay + 0.3 + full_memo.length() * 0.02 + 0.3
	btn_tween.tween_interval(total_wait)
	btn_tween.tween_property(start_button, "modulate:a", 1.0, 0.3)
	btn_tween.tween_callback(func() -> void:
		start_button.disabled = false
	)

func _on_start_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	start_button.disabled = true
	ScreenTransition.transition_to("res://scenes/game_day/game_day.tscn")
