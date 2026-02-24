extends Control
## Top half of the split-screen: office hallway, character, speech bubbles.
## Enhanced with ambient lighting, dust particles, animated clock, and typewriter speech.

@onready var character: Control = %CharacterSprite
@onready var speech_label: Label = %SpeechLabel
@onready var speech_panel: PanelContainer = %SpeechPanel
@onready var receive_button: Button = %ReceiveDocsButton
@onready var status_day: Label = %StatusDay
@onready var status_time: Label = %StatusTime
@onready var status_candidates: Label = %StatusCandidates
@onready var status_violations: Label = %StatusViolations

# Ambient lighting nodes
@onready var fluorescent_lamp: ColorRect = $FluorescentLamp
@onready var lamp_glow: ColorRect = $LampGlow

# Clock nodes
@onready var clock_hand_h: ColorRect = $ClockHandH
@onready var clock_hand_m: ColorRect = $ClockHandM

var _current_candidate: CandidateData = null

# Fluorescent light flicker state
var _flicker_timer: float = 0.0
var _flicker_interval: float = 3.0
var _is_flickering: bool = false
var _flicker_count: int = 0
var _flicker_max: int = 0
var _lamp_base_alpha: float = 1.0
var _glow_base_alpha: float = 0.3

# Typewriter speech
var _typewriter_tween: Tween = null
var _full_speech_text: String = ""
var _mumble_timer: float = 0.0
var _is_speaking: bool = false

# Character idle sway
var _idle_time: float = 0.0
var _character_base_x: float = 0.0
var _character_arrived: bool = false

func _ready() -> void:
	speech_panel.visible = false
	receive_button.visible = false
	receive_button.pressed.connect(_on_receive_pressed)
	EventBus.candidate_arrived.connect(_on_candidate_arrived)
	EventBus.candidate_left.connect(_on_candidate_left)
	EventBus.show_speech.connect(_show_speech)
	EventBus.hide_speech.connect(_hide_speech)

	# Initialize flicker timing
	_flicker_interval = randf_range(4.0, 12.0)
	_lamp_base_alpha = fluorescent_lamp.color.a
	_glow_base_alpha = lamp_glow.color.a

func _process(delta: float) -> void:
	# Fluorescent light flicker logic
	_process_light_flicker(delta)

	# Clock animation
	_process_clock(delta)

	# Character mumble during speech
	if _is_speaking:
		_mumble_timer -= delta
		if _mumble_timer <= 0.0:
			_mumble_timer = randf_range(0.2, 0.4)
			var seed_val: int = _current_candidate.photo_seed if _current_candidate else randi()
			AudioManager.play_mumble(seed_val + randi_range(0, 100), randf_range(0.1, 0.2))

	# Idle character sway
	if _character_arrived and _current_candidate != null:
		_idle_time += delta
		var sway: float = sin(_idle_time * 0.8) * 1.2
		character.position.x = _character_base_x + sway

func _process_light_flicker(delta: float) -> void:
	_flicker_timer += delta

	if _is_flickering:
		# During a flicker burst
		_flicker_count -= 1
		if _flicker_count <= 0:
			_is_flickering = false
			fluorescent_lamp.modulate.a = 1.0
			lamp_glow.modulate.a = 1.0
			_flicker_interval = randf_range(5.0, 15.0)
			_flicker_timer = 0.0
		else:
			# Rapid on/off
			var on: bool = _flicker_count % 2 == 0
			fluorescent_lamp.modulate.a = 1.0 if on else randf_range(0.3, 0.6)
			lamp_glow.modulate.a = 1.0 if on else randf_range(0.1, 0.3)
	else:
		if _flicker_timer >= _flicker_interval:
			_is_flickering = true
			_flicker_count = randi_range(2, 6)
			_flicker_timer = 0.0

	# Subtle constant hum variation
	if not _is_flickering:
		var hum: float = sin(_flicker_timer * 12.0) * 0.02 + 1.0
		fluorescent_lamp.modulate.a = hum
		lamp_glow.modulate.a = hum

func _process_clock(delta: float) -> void:
	if GameManager.state != GameManager.GameState.DAY_ACTIVE:
		return

	# Map remaining time to clock hand rotation
	var total: float = GameManager.day_duration
	var remaining: float = GameManager.day_time_remaining
	var elapsed_ratio: float = 1.0 - (remaining / total) if total > 0.0 else 0.0

	# Minute hand: full rotation over the day
	var minute_angle: float = elapsed_ratio * TAU
	clock_hand_m.rotation = minute_angle

	# Hour hand: quarter rotation over the day
	var hour_angle: float = elapsed_ratio * TAU * 0.25
	clock_hand_h.rotation = hour_angle

func update_status(day: int, time_remaining: float, candidates_left: int, violations: int) -> void:
	status_day.text = "GÜN: %d/5" % day
	var minutes: int = int(time_remaining) / 60
	var seconds: int = int(time_remaining) % 60
	status_time.text = "SAAT: %02d:%02d" % [minutes, seconds]
	if time_remaining < 30.0:
		status_time.add_theme_color_override("font_color", Color(0.9, 0.3, 0.1))
		# Pulse effect when low time
		var pulse: float = (sin(Time.get_ticks_msec() * 0.008) + 1.0) * 0.5
		status_time.modulate.a = 0.6 + pulse * 0.4
	else:
		status_time.add_theme_color_override("font_color", Color(0.75, 0.72, 0.65))
		status_time.modulate.a = 1.0
	status_candidates.text = "KALAN: %d" % candidates_left
	status_violations.text = "İHLAL: %d/3" % violations

	# Violations flash red when high
	if violations >= 2:
		violations_label_pulse()

func violations_label_pulse() -> void:
	var pulse: float = (sin(Time.get_ticks_msec() * 0.005) + 1.0) * 0.5
	status_violations.add_theme_color_override("font_color", Color(0.9, 0.15 + pulse * 0.2, 0.1))

func _on_candidate_arrived(candidate: Resource) -> void:
	_current_candidate = candidate as CandidateData
	if _current_candidate == null:
		return

	_character_arrived = false
	_idle_time = 0.0

	# Setup character appearance
	character.setup_from_seed(_current_candidate.photo_seed, _current_candidate.gender)

	# Walk in animation — from door on the right
	character.position.x = 960.0
	character.modulate.a = 0.0
	var target_x: float = size.x / 2.0 - character.size.x / 2.0

	var tween: Tween = create_tween()
	# Fade in quickly as they enter
	tween.tween_property(character, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(character, "position:x", target_x, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func() -> void:
		_character_base_x = target_x
		_character_arrived = true
		_show_greeting()
	)

func _show_greeting() -> void:
	if _current_candidate:
		_show_speech(_current_candidate.greeting)
		# Reveal receive button with fade
		receive_button.modulate.a = 0.0
		receive_button.visible = true
		var tween: Tween = create_tween()
		tween.tween_property(receive_button, "modulate:a", 1.0, 0.3)

func _on_receive_pressed() -> void:
	receive_button.visible = false
	var handover: String = CandidatePool.DOCUMENT_HANDOVERS[randi() % CandidatePool.DOCUMENT_HANDOVERS.size()]
	_show_speech(handover)
	# Brief hand animation — reach forward
	var orig_x: float = character.position.x
	_character_base_x = orig_x
	var tween: Tween = create_tween()
	tween.tween_property(character, "position:x", orig_x - 8.0, 0.15)
	tween.tween_property(character, "position:x", orig_x, 0.15)
	tween.tween_callback(func() -> void:
		EventBus.documents_received.emit()
	)
	tween.tween_interval(1.0)
	tween.tween_callback(_hide_speech)

func show_reaction(hired: bool) -> void:
	if _current_candidate == null:
		return
	if hired:
		character.set_expression(1)  # Happy
		_show_speech(_current_candidate.reaction_hired)
	else:
		character.set_expression(2)  # Sad
		_show_speech(_current_candidate.reaction_rejected)

func walk_out() -> void:
	_character_arrived = false
	var tween: Tween = create_tween()
	tween.tween_property(character, "position:x", -150.0, 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(character, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tween.tween_callback(func() -> void:
		_hide_speech()
		EventBus.candidate_left.emit()
	)

func _on_candidate_left() -> void:
	_current_candidate = null
	_character_arrived = false

func _show_speech(text: String) -> void:
	# Kill any existing typewriter animation
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()

	_full_speech_text = text
	speech_label.text = ""
	speech_panel.visible = true
	_is_speaking = true
	_mumble_timer = 0.05

	# Pop-in animation for speech panel
	speech_panel.scale = Vector2(0.8, 0.8)
	speech_panel.modulate.a = 0.0
	var pop_tween: Tween = create_tween()
	pop_tween.set_parallel(true)
	pop_tween.tween_property(speech_panel, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(speech_panel, "modulate:a", 1.0, 0.1)

	# Typewriter effect
	_typewriter_tween = create_tween()
	_typewriter_tween.tween_interval(0.15)  # Wait for pop-in

	var char_delay: float = 0.025
	for i in range(text.length()):
		var idx: int = i + 1
		_typewriter_tween.tween_callback(func() -> void:
			speech_label.text = _full_speech_text.substr(0, idx)
		)
		_typewriter_tween.tween_interval(char_delay)
	_typewriter_tween.tween_callback(func() -> void:
		_is_speaking = false
	)

func _hide_speech() -> void:
	_is_speaking = false
	AudioManager.stop_mumble()
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
	# Quick fade out
	var tween: Tween = create_tween()
	tween.tween_property(speech_panel, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		speech_panel.visible = false
		speech_panel.modulate.a = 1.0
	)
