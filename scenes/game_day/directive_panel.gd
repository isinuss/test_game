extends Control
## Slide-out overlay panel showing active directives and player stats.
## Slides in from left edge; tap overlay background to dismiss.

@onready var directives_list: VBoxContainer = %DirectivesList
@onready var money_label: Label = %MoneyLabel
@onready var violations_label: Label = %ViolationsLabel
@onready var _overlay: ColorRect = %Overlay
@onready var _slide_panel: PanelContainer = %SlidePanel
@onready var _close_btn: Button = %CloseBtn

var _prev_money: int = 0
var _prev_violations: int = 0
var _is_open: bool = false

func _ready() -> void:
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.violation_received.connect(_on_violation)
	_overlay.gui_input.connect(_on_overlay_input)
	_close_btn.pressed.connect(hide_panel)

func load_directives(day: int) -> void:
	# Clear old
	for child: Node in directives_list.get_children():
		child.queue_free()

	var directives: Array[DirectiveData] = DirectivePool.get_directives_for_day(day)
	var delay: float = 0.0
	for d: DirectiveData in directives:
		var lbl: Label = Label.new()
		lbl.text = "• " + d.directive_text
		lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.modulate.a = 0.0
		directives_list.add_child(lbl)

		# Stagger directive appearance
		var tween: Tween = create_tween()
		tween.tween_interval(delay)
		tween.tween_property(lbl, "modulate:a", 1.0, 0.3)
		delay += 0.2

	_prev_money = GameManager.money
	_prev_violations = GameManager.violations
	_update_stats()

func show_panel() -> void:
	if _is_open:
		return
	_is_open = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	_overlay.visible = true
	_overlay.color = Color(0, 0, 0, 0)
	var overlay_tween: Tween = create_tween()
	overlay_tween.tween_property(_overlay, "color:a", 0.5, 0.2)

	_slide_panel.visible = true
	_slide_panel.position.x = -320.0
	var slide_tween: Tween = create_tween()
	slide_tween.tween_property(_slide_panel, "position:x", 0.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func hide_panel() -> void:
	if not _is_open:
		return
	_is_open = false

	var slide_tween: Tween = create_tween()
	slide_tween.tween_property(_slide_panel, "position:x", -320.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	slide_tween.parallel().tween_property(_overlay, "color:a", 0.0, 0.2)
	slide_tween.tween_callback(func() -> void:
		_slide_panel.visible = false
		_overlay.visible = false
		visible = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	)

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		hide_panel()

func _update_stats() -> void:
	money_label.text = "PARA: ₺%d" % GameManager.money
	violations_label.text = "İHLAL: %d/3" % GameManager.violations

func _on_money_changed(_amount: int) -> void:
	var gained: bool = GameManager.money > _prev_money
	_prev_money = GameManager.money
	_update_stats()

	# Flash green for money gain
	if gained:
		var tween: Tween = create_tween()
		tween.tween_property(money_label, "modulate", Color(0.3, 1.2, 0.3), 0.1)
		tween.tween_property(money_label, "modulate", Color.WHITE, 0.3)

func _on_violation(_reason: String) -> void:
	_prev_violations = GameManager.violations
	_update_stats()

	# Flash and shake for violation
	var tween: Tween = create_tween()
	tween.tween_property(violations_label, "modulate", Color(1.3, 0.2, 0.1), 0.08)
	tween.tween_property(violations_label, "modulate", Color.WHITE, 0.08)
	tween.tween_property(violations_label, "modulate", Color(1.3, 0.2, 0.1), 0.08)
	tween.tween_property(violations_label, "modulate", Color.WHITE, 0.2)

	# Scale bump
	violations_label.pivot_offset = Vector2(0, violations_label.size.y / 2.0)
	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(violations_label, "scale", Vector2(1.2, 1.2), 0.1)
	scale_tween.tween_property(violations_label, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)
