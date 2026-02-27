extends Control
## End-of-day summary screen. Shows decisions, violations, money.
## Uses screen transitions for scene changes.

@onready var title_label: Label = %TitleLabel
@onready var results_container: VBoxContainer = %ResultsContainer
@onready var summary_label: Label = %SummaryLabel
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue)
	_populate()

func _populate() -> void:
	var summary: Variant = GameManager.flags.get("_last_summary", {})
	if summary is not Dictionary:
		summary = {}

	var day: int = summary.get("day", GameManager.current_day)

	# Title with typewriter
	var full_title: String = LocaleManager.t("summary.title") % day
	title_label.text = ""
	var title_tween: Tween = create_tween()
	title_tween.tween_interval(0.3)
	for i in range(full_title.length()):
		var idx: int = i + 1
		title_tween.tween_callback(func() -> void:
			title_label.text = full_title.substr(0, idx)
		)
		title_tween.tween_interval(0.03)

	# Show each decision
	var decisions: Array = summary.get("decisions", [])
	var line_delay: float = 0.6
	for decision: Variant in decisions:
		if decision is not Dictionary:
			continue
		var d: Dictionary = decision
		var candidate: Variant = d.get("candidate", null)
		var candidate_name: String = LocaleManager.t("summary.unknown")
		if candidate is CandidateData:
			candidate_name = (candidate as CandidateData).candidate_name

		var hired: bool = d.get("hired", false)
		var correct: bool = d.get("correct", true)
		var violation: bool = d.get("violation", false)
		var reason: String = d.get("reason", "")

		var lbl: Label = Label.new()
		var status_text: String = LocaleManager.t("summary.hired") if hired else LocaleManager.t("summary.rejected")
		var result_text: String = LocaleManager.t("summary.correct") if correct else LocaleManager.t("summary.violation")
		lbl.text = "%s — %s %s" % [candidate_name, status_text, result_text]

		if violation:
			lbl.add_theme_color_override("font_color", Color(0.9, 0.3, 0.1))
			if reason != "":
				lbl.text += " (%s)" % reason
		else:
			lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 0.5))

		lbl.add_theme_font_size_override("font_size", 12)
		lbl.modulate.a = 0.0
		lbl.position.x = -10.0
		results_container.add_child(lbl)

		# Animate each line appearing with slide
		var tween: Tween = create_tween()
		tween.tween_interval(line_delay)
		tween.tween_property(lbl, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(lbl, "position:x", 0.0, 0.3).set_ease(Tween.EASE_OUT)
		line_delay += 0.4

	# Summary stats
	var violations_today: int = summary.get("violations_today", 0)
	var total_violations: int = summary.get("total_violations", GameManager.violations)
	var money: int = summary.get("money", GameManager.money)
	var reviewed: int = summary.get("reviewed", 0)
	var total: int = summary.get("total_candidates", 0)
	var auto_rejected: int = summary.get("auto_rejected", 0)

	var summary_text: String = "\n"
	summary_text += (LocaleManager.t("summary.reviewed") % [reviewed, total]) + "\n"
	if auto_rejected > 0:
		summary_text += (LocaleManager.t("summary.auto_rejected") % auto_rejected) + "\n"
	summary_text += (LocaleManager.t("summary.violations_today") % violations_today) + "\n"
	summary_text += (LocaleManager.t("summary.total_violations") % [total_violations, GameManager.max_violations]) + "\n"
	summary_text += (LocaleManager.t("summary.total_money") % money) + "\n"

	if total_violations >= GameManager.max_violations:
		summary_text += LocaleManager.t("summary.fired_warning")

	summary_label.text = summary_text

	# Animate summary appearing
	summary_label.modulate.a = 0.0
	var summary_tween: Tween = create_tween()
	summary_tween.tween_interval(line_delay + 0.5)
	summary_tween.tween_property(summary_label, "modulate:a", 1.0, 0.5)

	# Show continue button after all animations
	continue_button.modulate.a = 0.0
	continue_button.disabled = true
	var btn_tween: Tween = create_tween()
	btn_tween.tween_interval(line_delay + 1.5)
	btn_tween.tween_property(continue_button, "modulate:a", 1.0, 0.3)
	btn_tween.tween_callback(func() -> void:
		continue_button.disabled = false
	)

	if GameManager.violations >= GameManager.max_violations or GameManager.current_day >= GameManager.max_days:
		continue_button.text = LocaleManager.t("ui.result")
	else:
		continue_button.text = LocaleManager.t("ui.continue")

func _on_continue() -> void:
	continue_button.disabled = true
	GameManager.advance_day()
	if GameManager.state == GameManager.GameState.GAME_OVER:
		ScreenTransition.transition_to("res://scenes/ending/ending.tscn", 0.6, 0.8)
	else:
		ScreenTransition.transition_to("res://scenes/day_briefing/day_briefing.tscn")
