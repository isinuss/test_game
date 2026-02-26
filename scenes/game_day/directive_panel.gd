extends PanelContainer
## Side panel showing active directives and player stats.
## Enhanced with money flash and violation shake animations.

@onready var directives_list: VBoxContainer = %DirectivesList
@onready var money_label: Label = %MoneyLabel
@onready var violations_label: Label = %ViolationsLabel

var _prev_money: int = 0
var _prev_violations: int = 0

func _ready() -> void:
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.violation_received.connect(_on_violation)

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
		lbl.add_theme_font_size_override("font_size", 11)
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

func _update_stats() -> void:
	money_label.text = "PARA: ₺%d" % GameManager.money
	violations_label.text = "İHLAL: %d/%d" % [GameManager.violations, GameManager.max_violations]

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
