extends PanelContainer
## Side panel showing active directives and player stats.

@onready var directives_list: VBoxContainer = %DirectivesList
@onready var money_label: Label = %MoneyLabel
@onready var violations_label: Label = %ViolationsLabel

func _ready() -> void:
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.violation_received.connect(_on_violation)

func load_directives(day: int) -> void:
	# Clear old
	for child: Node in directives_list.get_children():
		child.queue_free()

	var directives: Array[DirectiveData] = DirectivePool.get_directives_for_day(day)
	for d: DirectiveData in directives:
		var lbl: Label = Label.new()
		lbl.text = "• " + d.directive_text
		lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		directives_list.add_child(lbl)

	_update_stats()

func _update_stats() -> void:
	money_label.text = "PARA: ₺%d" % GameManager.money
	violations_label.text = "İHLAL: %d/3" % GameManager.violations

func _on_money_changed(_amount: int) -> void:
	_update_stats()

func _on_violation(_reason: String) -> void:
	_update_stats()
