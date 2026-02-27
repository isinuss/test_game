extends PanelContainer
## Side panel showing active directives and player stats.
## Enhanced with money flash and violation shake animations.

@onready var directives_list: VBoxContainer = %DirectivesList
@onready var money_label: Label = %MoneyLabel
@onready var violations_label: Label = %ViolationsLabel

var _prev_money: int = 0
var _prev_violations: int = 0

# Stress bar (created dynamically since .tscn may not have it yet)
var _stress_bar: ProgressBar = null
var _stress_label: Label = null

func _ready() -> void:
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.violation_received.connect(_on_violation)
	EventBus.stress_changed.connect(_on_stress_changed)
	_create_stress_bar()

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
	money_label.text = LocaleManager.t("status.money") % GameManager.money
	violations_label.text = LocaleManager.t("status.violations") % [GameManager.violations, GameManager.max_violations]

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

func _create_stress_bar() -> void:
	# Dynamically add stress bar below violations label
	_stress_label = Label.new()
	_stress_label.text = LocaleManager.t("status.stress")
	_stress_label.add_theme_font_size_override("font_size", 10)
	_stress_label.add_theme_color_override("font_color", Color(0.7, 0.65, 0.55))
	violations_label.add_sibling(_stress_label)

	_stress_bar = ProgressBar.new()
	_stress_bar.min_value = 0
	_stress_bar.max_value = 100
	_stress_bar.value = GameManager.stress * 100
	_stress_bar.custom_minimum_size = Vector2(0, 8)
	_stress_bar.show_percentage = false
	_stress_label.add_sibling(_stress_bar)
	_update_stress_color()

func _on_stress_changed(_new_stress: float) -> void:
	if _stress_bar == null:
		return
	_stress_bar.value = GameManager.stress * 100
	_update_stress_color()

func _update_stress_color() -> void:
	if _stress_bar == null:
		return
	var s: float = GameManager.stress
	# Green → Yellow → Red interpolation
	var bar_color: Color
	if s < 0.5:
		bar_color = Color(0.3 + s * 1.0, 0.7, 0.2)  # green to yellow
	else:
		bar_color = Color(0.9, 0.7 - (s - 0.5) * 1.2, 0.1)  # yellow to red
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bar_color
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	_stress_bar.add_theme_stylebox_override("fill", style)

	# Update label color to match
	if s >= 0.7:
		_stress_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.2))
	elif s >= 0.4:
		_stress_label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3))
	else:
		_stress_label.add_theme_color_override("font_color", Color(0.7, 0.65, 0.55))
