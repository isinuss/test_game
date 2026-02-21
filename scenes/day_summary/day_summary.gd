extends Control
## End-of-day summary screen. Shows decisions, violations, money.

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
	title_label.text = "GÜN %d — RAPOR" % day

	# Show each decision
	var decisions: Array = summary.get("decisions", [])
	var line_delay: float = 0.0
	for decision: Variant in decisions:
		if decision is not Dictionary:
			continue
		var d: Dictionary = decision
		var candidate: Variant = d.get("candidate", null)
		var candidate_name: String = "Bilinmeyen"
		if candidate is CandidateData:
			candidate_name = (candidate as CandidateData).candidate_name

		var hired: bool = d.get("hired", false)
		var correct: bool = d.get("correct", true)
		var violation: bool = d.get("violation", false)
		var reason: String = d.get("reason", "")

		var lbl: Label = Label.new()
		var status_text: String = "İŞE ALINDI" if hired else "REDDEDİLDİ"
		var result_text: String = "✓" if correct else "✗ İHLAL"
		lbl.text = "%s — %s %s" % [candidate_name, status_text, result_text]

		if violation:
			lbl.add_theme_color_override("font_color", Color(0.9, 0.3, 0.1))
			if reason != "":
				lbl.text += " (%s)" % reason
		else:
			lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 0.5))

		lbl.add_theme_font_size_override("font_size", 12)
		lbl.modulate.a = 0.0
		results_container.add_child(lbl)

		# Animate each line appearing
		var tween: Tween = create_tween()
		tween.tween_interval(line_delay)
		tween.tween_property(lbl, "modulate:a", 1.0, 0.3)
		line_delay += 0.4

	# Summary stats
	var violations_today: int = summary.get("violations_today", 0)
	var total_violations: int = summary.get("total_violations", GameManager.violations)
	var money: int = summary.get("money", GameManager.money)
	var reviewed: int = summary.get("reviewed", 0)
	var total: int = summary.get("total_candidates", 0)
	var auto_rejected: int = summary.get("auto_rejected", 0)

	var summary_text: String = "\n"
	summary_text += "İncelenen: %d / %d aday\n" % [reviewed, total]
	if auto_rejected > 0:
		summary_text += "Zaman doldu — %d aday otomatik reddedildi\n" % auto_rejected
	summary_text += "Bugünkü ihlaller: %d\n" % violations_today
	summary_text += "Toplam ihlal: %d / 3\n" % total_violations
	summary_text += "Toplam para: ₺%d\n" % money

	if total_violations >= 3:
		summary_text += "\n⚠ ÇOK FAZLA İHLAL — KOVULDUNUZ!"

	summary_label.text = summary_text

	# Animate summary appearing
	summary_label.modulate.a = 0.0
	var summary_tween: Tween = create_tween()
	summary_tween.tween_interval(line_delay + 0.5)
	summary_tween.tween_property(summary_label, "modulate:a", 1.0, 0.5)

	# Show continue button after all animations
	continue_button.modulate.a = 0.0
	var btn_tween: Tween = create_tween()
	btn_tween.tween_interval(line_delay + 1.5)
	btn_tween.tween_property(continue_button, "modulate:a", 1.0, 0.3)

	if GameManager.violations >= GameManager.max_violations or GameManager.current_day >= GameManager.max_days:
		continue_button.text = "SONUÇ"
	else:
		continue_button.text = "SONRAKİ GÜN →"

func _on_continue() -> void:
	GameManager.advance_day()
	if GameManager.state == GameManager.GameState.GAME_OVER:
		get_tree().change_scene_to_file("res://scenes/ending/ending.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/day_briefing/day_briefing.tscn")
