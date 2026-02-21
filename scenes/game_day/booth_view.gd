extends Control
## Top half of the split-screen: office hallway, character, speech bubbles.

@onready var character: Control = %CharacterSprite
@onready var speech_label: Label = %SpeechLabel
@onready var speech_panel: PanelContainer = %SpeechPanel
@onready var receive_button: Button = %ReceiveDocsButton
@onready var status_day: Label = %StatusDay
@onready var status_time: Label = %StatusTime
@onready var status_candidates: Label = %StatusCandidates
@onready var status_violations: Label = %StatusViolations

var _current_candidate: CandidateData = null

func _ready() -> void:
	speech_panel.visible = false
	receive_button.visible = false
	receive_button.pressed.connect(_on_receive_pressed)
	EventBus.candidate_arrived.connect(_on_candidate_arrived)
	EventBus.candidate_left.connect(_on_candidate_left)
	EventBus.show_speech.connect(_show_speech)
	EventBus.hide_speech.connect(_hide_speech)

func update_status(day: int, time_remaining: float, candidates_left: int, violations: int) -> void:
	status_day.text = "GÜN: %d/5" % day
	var minutes: int = int(time_remaining) / 60
	var seconds: int = int(time_remaining) % 60
	status_time.text = "SAAT: %02d:%02d" % [minutes, seconds]
	if time_remaining < 30.0:
		status_time.add_theme_color_override("font_color", Color(0.9, 0.3, 0.1))
	else:
		status_time.add_theme_color_override("font_color", Color(0.75, 0.72, 0.65))
	status_candidates.text = "KALAN: %d" % candidates_left
	status_violations.text = "İHLAL: %d/3" % violations

func _on_candidate_arrived(candidate: Resource) -> void:
	_current_candidate = candidate as CandidateData
	if _current_candidate == null:
		return

	# Setup character appearance
	character.setup_from_seed(_current_candidate.photo_seed, _current_candidate.gender)

	# Walk in animation
	character.position.x = 960.0
	character.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_property(character, "position:x", size.x / 2.0 - character.size.x / 2.0, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(_show_greeting)

func _show_greeting() -> void:
	if _current_candidate:
		_show_speech(_current_candidate.greeting)
		receive_button.visible = true

func _on_receive_pressed() -> void:
	receive_button.visible = false
	var handover: String = CandidatePool.DOCUMENT_HANDOVERS[randi() % CandidatePool.DOCUMENT_HANDOVERS.size()]
	_show_speech(handover)
	# Brief hand animation
	var orig_x: float = character.position.x
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
	var tween: Tween = create_tween()
	tween.tween_property(character, "position:x", -100.0, 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func() -> void:
		_hide_speech()
		EventBus.candidate_left.emit()
	)

func _on_candidate_left() -> void:
	_current_candidate = null

func _show_speech(text: String) -> void:
	speech_label.text = text
	speech_panel.visible = true

func _hide_speech() -> void:
	speech_panel.visible = false
