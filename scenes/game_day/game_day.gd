extends Control
## Core gameplay scene. Orchestrates the split-screen day flow:
## Top: booth with walking characters. Bottom: desk with documents + stamps.

signal _event_popup_dismissed

@onready var booth_view: Control = %BoothView
@onready var document_view: Control = %DocumentView
@onready var directive_panel: PanelContainer = %DirectivePanel
@onready var stamp_area: Control = %StampArea
@onready var drawer_panel: Control = %DrawerPanel

var _waiting_for_next: bool = false
var _day_over: bool = false
var _used_random_events: Array[String] = []

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

	# Drawer button
	var drawer_btn: Button = directive_panel.find_child("DrawerButton", true, false)
	if drawer_btn:
		drawer_btn.pressed.connect(_on_drawer_pressed)

	# Audio: stop menu music, start office ambient
	AudioManager.stop_music()
	AudioManager.play_ambient()

	# Check for violation redemption (rare random event)
	await _check_violation_redemption()

	# Check for day-start events (blocking — waits for player to dismiss)
	await _check_day_start_events()

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
				# Insert CEO's nephew as candidate 2 (index 1)
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
				# Update documents
				nephew.documents.clear()
				CandidatePool._generate_documents(nephew)
				nephew.documents[0].content["Deneyim"] = "1 yıl"
				# Nephew is NOT a valid hire by directive rules (< 3 years exp)
				nephew.is_valid_hire = false
				nephew.rejection_reasons = ["3 yıldan az deneyim"]
				if GameManager.candidates_today.size() > 1:
					GameManager.candidates_today.insert(1, nephew)
				else:
					GameManager.candidates_today.append(nephew)

func _check_violation_redemption() -> void:
	if GameManager.violations <= 0 or GameManager.current_day <= 1:
		return
	# ~20% chance per existing violation (capped at 60%)
	var chance: float = minf(0.2 * GameManager.violations, 0.6)
	if randf() < chance:
		GameManager.violations -= 1
		var event: Dictionary = EventPool.get_event("violation_redemption")
		_show_event_popup(event)
		await _event_popup_dismissed

func _check_day_start_events() -> void:
	var config: Dictionary = GameManager.get_day_config()
	for event_id: String in config.get("events", []):
		var event: Dictionary = EventPool.get_event(event_id)
		if event.get("trigger", "") == "day_start" and event.get("blocking", false):
			_show_event_popup(event)
			await _event_popup_dismissed

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
			AudioManager.play_sfx("ui_click")
			var flag_key: String = choice_data.get("flag", "")
			if flag_key != "":
				GameManager.set_flag(flag_key, choice_data.get("value", true))
			EventBus.event_choice_made.emit(ev_id, i)
			# Fade out popup then signal dismissal
			var close_tween: Tween = create_tween()
			close_tween.tween_property(overlay, "modulate:a", 0.0, 0.2)
			close_tween.tween_callback(func() -> void:
				overlay.queue_free()
				_event_popup_dismissed.emit()
			)
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
	await _check_candidate_events()

func _check_candidate_events() -> void:
	var config: Dictionary = GameManager.get_day_config()
	for event_id: String in config.get("events", []):
		var event: Dictionary = EventPool.get_event(event_id)
		var trigger: String = event.get("trigger", "")
		if trigger.begins_with("candidate_"):
			var trigger_idx: int = trigger.split("_")[1].to_int() - 1
			if trigger_idx == GameManager.current_candidate_index:
				_show_event_popup(event)
				await _event_popup_dismissed

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

	# Check for day-end events (blocking — waits for player dismissal)
	var had_day_end: bool = await _check_day_end_events()

	# Random event between candidates (~25% chance, max 1 per unique event per day)
	if not _day_over and not had_day_end and randf() < 0.25:
		var rand_event: Dictionary = EventPool.get_random_event(GameManager.current_day)
		var rand_id: String = rand_event.get("id", "")
		if rand_id != "" and rand_id not in _used_random_events:
			_used_random_events.append(rand_id)
			_show_event_popup(rand_event)
			await _event_popup_dismissed
			# Apply time penalty if any
			var penalty: float = rand_event.get("time_penalty", 0.0)
			if penalty > 0.0:
				GameManager.day_time_remaining -= penalty

	_present_next_candidate()

func _check_day_end_events() -> bool:
	# Check if we're at the last candidate and there's a day_end event
	if GameManager.current_candidate_index >= GameManager.candidates_today.size() - 1:
		var config: Dictionary = GameManager.get_day_config()
		for event_id: String in config.get("events", []):
			var event: Dictionary = EventPool.get_event(event_id)
			if event.get("trigger", "") == "day_end":
				_show_event_popup(event)
				await _event_popup_dismissed
				return true
	return false

func _on_drawer_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	drawer_panel.show_drawer(GameManager.current_day)

func _end_day() -> void:
	AudioManager.stop_ambient()
	stamp_area.set_buttons_enabled(false)
	var summary: Dictionary = GameManager.end_day()
	# Store summary for the summary screen to read
	GameManager.set_flag("_last_summary", summary)
	await get_tree().create_timer(1.5).timeout
	ScreenTransition.transition_to("res://scenes/day_summary/day_summary.tscn")
