extends Control
## Core gameplay scene. Orchestrates the split-screen day flow:
## Top: booth with walking characters. Bottom: desk with documents + stamps.

@onready var booth_view: Control = %BoothView
@onready var document_view: Control = %DocumentView
@onready var directive_panel: PanelContainer = %DirectivePanel
@onready var stamp_area: Control = %StampArea

var _waiting_for_next: bool = false
var _day_over: bool = false

func _ready() -> void:
	GameManager.start_day()

	# Generate candidates for today
	var config: Dictionary = GameManager.get_day_config()
	var directive_ids: Array[String] = []
	for d: String in config.get("directives", []):
		directive_ids.append(d)
	GameManager.candidates_today = CandidatePool.generate_candidates_for_day(
		GameManager.current_day,
		directive_ids,
		config.get("num_candidates", 3),
		config.get("inconsistency_ratio", 0.2),
	)

	# Insert special event candidates
	_insert_event_candidates()

	# Setup UI
	directive_panel.load_directives(GameManager.current_day)
	stamp_area.stamp_pressed.connect(_on_stamp_decision)
	EventBus.documents_received.connect(_on_documents_received)

	# Check for day-start events
	_check_day_start_events()

	# Start with first candidate after brief delay
	await get_tree().create_timer(0.5).timeout
	_present_next_candidate()

func _process(delta: float) -> void:
	if _day_over:
		return
	if GameManager.state != GameManager.GameState.DAY_ACTIVE:
		return

	GameManager.day_time_remaining -= delta
	if GameManager.day_time_remaining <= 0.0:
		GameManager.day_time_remaining = 0.0
		_day_over = true
		_end_day()

	# Update status bar
	var remaining_candidates: int = GameManager.candidates_today.size() - GameManager.current_candidate_index - 1
	if remaining_candidates < 0:
		remaining_candidates = 0
	booth_view.update_status(
		GameManager.current_day,
		GameManager.day_time_remaining,
		remaining_candidates,
		GameManager.violations,
	)

func _insert_event_candidates() -> void:
	var config: Dictionary = GameManager.get_day_config()
	for event_id: String in config.get("events", []):
		match event_id:
			"ceo_nephew":
				_insert_ceo_nephew()
			"returning_candidate":
				_insert_returning_candidate()
			"journalist_visit":
				_insert_journalist()
			"double_agent":
				_insert_spy()
			"ghost_employees":
				_insert_ghost_employee()
			"confrontation":
				_insert_nephew_return()

func _insert_ceo_nephew() -> void:
	var nephew: CandidateData = CandidatePool.generate_candidate(
		GameManager.current_day * 10000 + 99, GameManager.current_day
	)
	nephew.candidate_name = "Selim Patronoğlu"
	nephew.is_ceo_nephew = true
	nephew.experience_years = 1
	nephew.special_event_id = "ceo_nephew"
	nephew.greeting = "Merhaba. CEO'nun yeğeniyim. Sanırım beni bekliyordunuz."
	nephew.reaction_hired = "Beklenen buydu zaten. Dayıma selamlar."
	nephew.reaction_rejected = "Ciddi misiniz? Dayım bunu duyunca..."
	nephew.interview_lines = [
		"Aslında pek deneyimim yok ama öğrenmeye açığım.",
		"Dayımın şirketinde staj yaptım... sayılır.",
	]
	nephew.documents.clear()
	CandidatePool._generate_documents(nephew)
	nephew.documents[0].content["Deneyim"] = "1 yıl"
	nephew.is_valid_hire = false
	nephew.rejection_reasons = ["3 yıldan az deneyim"]
	if GameManager.candidates_today.size() > 1:
		GameManager.candidates_today.insert(1, nephew)
	else:
		GameManager.candidates_today.append(nephew)

func _insert_returning_candidate() -> void:
	# A candidate from Week 1 returns with different documents
	var returner: CandidateData = CandidatePool.generate_candidate(
		GameManager.current_day * 10000 + 77, GameManager.current_day
	)
	returner.is_returning_candidate = true
	returner.special_event_id = "returning_candidate"
	returner.greeting = "Merhaba... Daha önce de gelmiştim ama bu sefer belgelerim tamam."
	returner.reaction_hired = "Sonunda! İkinci şans her zaman işe yarıyor."
	returner.reaction_rejected = "Yine mi? Artık umudumu kaybediyorum..."
	returner.interview_lines = [
		"Geçen seferki eksiklerimi tamamladım.",
		"Yeni bir sertifika aldım, bakabilirsiniz.",
		"Bu sefer her şey eksiksiz, söz veriyorum.",
	]
	# This candidate might have forged documents — 50% chance
	if randi() % 2 == 0:
		CandidatePool.inject_inconsistency(returner, "name_mismatch")
		returner.is_valid_hire = false
		returner.rejection_reasons.append("Belge tutarsızlığı")
	if GameManager.candidates_today.size() > 1:
		GameManager.candidates_today.insert(1, returner)
	else:
		GameManager.candidates_today.append(returner)

func _insert_journalist() -> void:
	var journalist: CandidateData = CandidatePool.generate_candidate(
		GameManager.current_day * 10000 + 88, GameManager.current_day
	)
	journalist.candidate_name = "Elif Korkmaz"
	journalist.is_journalist = true
	journalist.special_event_id = "journalist_visit"
	journalist.greeting = "Merhaba, iş başvurusu için geldim. Güzel bir şirketmiş."
	journalist.reaction_hired = "Harika, çok teşekkürler! İçeriden görmek istiyordum."
	journalist.reaction_rejected = "Anlıyorum... Peki, şirket hakkında ne düşünüyorsunuz?"
	journalist.interview_lines = [
		"Şirketin çalışma kültürü hakkında çok şey duydum.",
		"Önceki İK'cı neden ayrıldı, biliyor musunuz?",
		"Burada çalışanlar mutlu mu sizce?",
	]
	journalist.documents.clear()
	CandidatePool._generate_documents(journalist)
	journalist.is_valid_hire = true  # Technically qualified
	# Insert at a random middle position
	var pos: int = mini(2, GameManager.candidates_today.size())
	GameManager.candidates_today.insert(pos, journalist)

func _insert_spy() -> void:
	var spy: CandidateData = CandidatePool.generate_candidate(
		GameManager.current_day * 10000 + 55, GameManager.current_day
	)
	spy.is_spy = true
	spy.special_event_id = "double_agent"
	spy.greeting = "İyi günler. Başvurumu çok özenle hazırladım."
	spy.reaction_hired = "Mükemmel. Hemen başlayabilirim."
	spy.reaction_rejected = "Anlıyorum. Belki başka bir departmanda..."
	spy.interview_lines = [
		"Şirketinizin organizasyon yapısı çok ilgimi çekiyor.",
		"İK süreçleriniz hakkında detaylı bilgi alabilir miyim?",
		"Rakip firmaların ne yaptığını biliyorum, size avantaj sağlarım.",
	]
	# Perfect documents — too perfect
	spy.experience_years = 8
	spy.gpa = 3.90
	spy.documents.clear()
	CandidatePool._generate_documents(spy)
	spy.documents[0].content["Deneyim"] = "8 yıl"
	spy.is_valid_hire = true
	if GameManager.candidates_today.size() > 3:
		GameManager.candidates_today.insert(3, spy)
	else:
		GameManager.candidates_today.append(spy)

func _insert_ghost_employee() -> void:
	var ghost: CandidateData = CandidatePool.generate_candidate(
		GameManager.current_day * 10000 + 33, GameManager.current_day
	)
	ghost.special_event_id = "ghost_employees"
	ghost.greeting = "Merhaba, başvurumu yaptım."
	ghost.reaction_hired = "Teşekkürler... Aslında burada zaten çalışıyormuşum galiba?"
	ghost.reaction_rejected = "Anladım..."
	ghost.interview_lines = [
		"Bu pozisyon bana çok uygun.",
		"Daha önce burada çalışmadım... sanırım.",
	]
	ghost.documents.clear()
	CandidatePool._generate_documents(ghost)
	ghost.is_valid_hire = false
	ghost.rejection_reasons.append("Sistemde zaten kayıtlı — hayalet çalışan")
	if GameManager.candidates_today.size() > 2:
		GameManager.candidates_today.insert(2, ghost)
	else:
		GameManager.candidates_today.append(ghost)

func _insert_nephew_return() -> void:
	# CEO's nephew returns on Day 14 — not as candidate but triggers event
	var nephew_return: CandidateData = CandidatePool.generate_candidate(
		GameManager.current_day * 10000 + 99, GameManager.current_day
	)
	nephew_return.candidate_name = "Selim Patronoğlu"
	nephew_return.is_ceo_nephew = true
	nephew_return.special_event_id = "confrontation"
	if GameManager.has_flag("accepted_nepotism"):
		nephew_return.greeting = "Merhaba yine. Beni hatırlarsın. Artık senin üstünüm."
	else:
		nephew_return.greeting = "Beni reddettin. Ama yine buradayım. Karma."
	nephew_return.reaction_hired = "Doğal olarak."
	nephew_return.reaction_rejected = "Bu sefer sonuçları farklı olacak."
	nephew_return.interview_lines = [
		"Yeni yönetim beni buraya atadı.",
		"İK'yı yeniden yapılandıracağız.",
	]
	nephew_return.documents.clear()
	CandidatePool._generate_documents(nephew_return)
	nephew_return.is_valid_hire = false
	nephew_return.rejection_reasons = ["Özel aday — olay tetikleyici"]
	GameManager.candidates_today.insert(0, nephew_return)

func _check_day_start_events() -> void:
	var config: Dictionary = GameManager.get_day_config()
	for event_id: String in config.get("events", []):
		# Use conditional variant for events that branch based on prior flags
		var event: Dictionary
		if event_id in ["informant_return", "confrontation", "ally_or_enemy"]:
			event = EventPool.get_event_conditional(event_id, GameManager.flags)
		else:
			event = EventPool.get_event(event_id)
		if event.get("trigger", "") == "day_start" and event.get("blocking", false):
			_show_event_popup(event)

func _show_event_popup(event: Dictionary) -> void:
	# Create a simple modal popup with fade-in
	var overlay: ColorRect = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# Fade in overlay
	var overlay_tween: Tween = create_tween()
	overlay_tween.tween_property(overlay, "color:a", 0.7, 0.3)

	var panel: PanelContainer = PanelContainer.new()
	panel.anchors_preset = Control.PRESET_CENTER
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -250
	panel.offset_top = -150
	panel.offset_right = 250
	panel.offset_bottom = 150
	# Pop-in animation
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	panel.pivot_offset = Vector2(250, 150)
	overlay.add_child(panel)

	var panel_tween: Tween = create_tween()
	panel_tween.tween_interval(0.2)
	panel_tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	panel_tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var inner_vbox: VBoxContainer = VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 8)
	margin.add_child(inner_vbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = event.get("title", "")
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner_vbox.add_child(title_lbl)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = event.get("text", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 12)
	inner_vbox.add_child(desc_lbl)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	inner_vbox.add_child(spacer)

	var choices: Array = event.get("choices", [])
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var btn: Button = Button.new()
		btn.text = choice.get("text", "")
		btn.custom_minimum_size = Vector2(0, 32)
		var choice_data: Dictionary = choice
		var ev_id: String = event.get("id", "")
		btn.pressed.connect(func() -> void:
			var flag_key: String = choice_data.get("flag", "")
			if flag_key != "":
				GameManager.set_flag(flag_key, choice_data.get("value", true))
			EventBus.event_choice_made.emit(ev_id, i)
			# Fade out popup
			var close_tween: Tween = create_tween()
			close_tween.tween_property(overlay, "modulate:a", 0.0, 0.2)
			close_tween.tween_callback(func() -> void: overlay.queue_free())
		)
		# Stagger button appearance
		btn.modulate.a = 0.0
		inner_vbox.add_child(btn)
		var btn_tween: Tween = create_tween()
		btn_tween.tween_interval(0.5 + i * 0.15)
		btn_tween.tween_property(btn, "modulate:a", 1.0, 0.2)

func _present_next_candidate() -> void:
	if _day_over:
		return

	stamp_area.reset_status()
	document_view.clear_documents()

	var candidate: Resource = GameManager.next_candidate()
	if candidate == null:
		_day_over = true
		_end_day()
		return

	# Check for mid-candidate events
	_check_candidate_events()

func _check_candidate_events() -> void:
	var config: Dictionary = GameManager.get_day_config()
	for event_id: String in config.get("events", []):
		var event: Dictionary
		if event_id in ["informant_return", "confrontation", "ally_or_enemy"]:
			event = EventPool.get_event_conditional(event_id, GameManager.flags)
		else:
			event = EventPool.get_event(event_id)
		var trigger: String = event.get("trigger", "")
		if trigger.begins_with("candidate_"):
			var trigger_idx: int = trigger.split("_")[1].to_int() - 1
			if trigger_idx == GameManager.current_candidate_index:
				_show_event_popup(event)

func _on_documents_received() -> void:
	var candidate: CandidateData = GameManager.get_current_candidate() as CandidateData
	if candidate == null:
		return
	document_view.load_documents(candidate.documents)
	stamp_area.set_buttons_enabled(true)

func _on_stamp_decision(hired: bool) -> void:
	var result: Dictionary = GameManager.record_decision(hired)
	var correct: bool = result.get("correct", false)
	var reason: String = result.get("reason", "")

	stamp_area.show_result(correct, reason)
	booth_view.show_reaction(hired)

	# Wait, then walk out and present next
	await get_tree().create_timer(2.0).timeout

	if _day_over:
		return

	booth_view.walk_out()
	await get_tree().create_timer(1.0).timeout

	if _day_over:
		return

	# Check for day-end events
	_check_day_end_events()
	_present_next_candidate()

func _check_day_end_events() -> void:
	# Check if we're at the last candidate and there's a day_end event
	if GameManager.current_candidate_index >= GameManager.candidates_today.size() - 1:
		var config: Dictionary = GameManager.get_day_config()
		for event_id: String in config.get("events", []):
			var event: Dictionary
			if event_id in ["informant_return", "confrontation", "ally_or_enemy"]:
				event = EventPool.get_event_conditional(event_id, GameManager.flags)
			else:
				event = EventPool.get_event(event_id)
			if event.get("trigger", "") == "day_end":
				_show_event_popup(event)

func _end_day() -> void:
	stamp_area.set_buttons_enabled(false)
	var summary: Dictionary = GameManager.end_day()
	# Store summary for the summary screen to read
	GameManager.set_flag("_last_summary", summary)
	await get_tree().create_timer(1.5).timeout
	ScreenTransition.transition_to("res://scenes/day_summary/day_summary.tscn")
