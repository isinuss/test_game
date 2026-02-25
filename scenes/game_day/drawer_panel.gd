extends Control
## Interactive desk drawer panel. Shows personal items and hidden notes
## that change per day and relate to the story's moral dilemmas.

signal drawer_closed

var _is_open: bool = false
var _overlay: ColorRect
var _desc_label: Label
var _selected_index: int = -1

const ITEMS_BY_DAY: Dictionary = {
	1: [
		{
			"name": "Aile Fotoğrafı",
			"icon": "♥",
			"desc": "Eşinin ve çocuğunun fotoğrafı. Gülümsüyorlar.\nBu sabah çıkarken \"İyi günler\" dedin mi?",
		},
		{
			"name": "Stres Topu",
			"icon": "●",
			"desc": "Yarısı sönmüş sarı bir stres topu.\nDaha ilk gün ve şimdiden sıkıyorsun.",
		},
		{
			"name": "Şirket El Kitabı",
			"icon": "▤",
			"desc": "\"İK Prosedürleri ve Etik Kurallar\"\nHiç açılmamış gibi duruyor. Belki de açmalısın.",
		},
	],
	2: [
		{
			"name": "Aile Fotoğrafı",
			"icon": "♥",
			"desc": "Aynı fotoğraf. Ama bugün bakışın biraz farklı.\n\"Eve erken geleceğim\" demiştin dün.",
		},
		{
			"name": "Aspirin",
			"icon": "◊",
			"desc": "Yarım kutu aspirin. Dün akşamdan kalma baş ağrısı.\nBu iş seni yıpratıyor.",
		},
		{
			"name": "Kişisel Not",
			"icon": "✎",
			"desc": "\"Doğru olanı yap. Her zaman.\"\nKendi el yazınla yazılmış. Ne zaman yazdığını hatırlamıyorsun.",
		},
	],
	3: [
		{
			"name": "Aile Fotoğrafı",
			"icon": "♥",
			"desc": "Bugün fotoğrafa daha çok bakıyorsun.\nOnlar için yapıyorsun bunu. Değil mi?",
		},
		{
			"name": "İstifa Mektubu Taslağı",
			"icon": "✉",
			"desc": "\"Sayın Genel Müdür, bu mektubu...\"\nYarım kalmış. Silgiyle kazınmış satırlar.",
		},
		{
			"name": "Gazete Kupürü",
			"icon": "▦",
			"desc": "\"CEO'NUN AİLESİ GÜNDEMDE\" başlıklı kupür.\nAltını çizmişsin. Neden saklıyorsun bunu?",
		},
	],
	4: [
		{
			"name": "Aile Fotoğrafı",
			"icon": "♥",
			"desc": "Fotoğrafa bakınca içini bir sıkıntı kaplıyor.\n\"Ya işimi kaybedersem?\"",
		},
		{
			"name": "Sendika Broşürü",
			"icon": "☆",
			"desc": "\"İşçi Hakları ve Senin Hakların\"\nBirisi masana bırakmış. Kimin olduğunu biliyorsun.",
		},
		{
			"name": "Gizli Memo",
			"icon": "!",
			"desc": "\"DİKKAT: Bu belge kurum dışına çıkmamalıdır.\"\nCEO'nun finansal düzensizlikleri hakkında detaylar var.",
		},
		{
			"name": "USB Bellek",
			"icon": "■",
			"desc": "Etiketinde \"YEDEK\" yazıyor. Kim bıraktı bunu?\nTaksan mı, takmasam mı...",
		},
	],
	5: [
		{
			"name": "Aile Fotoğrafı",
			"icon": "♥",
			"desc": "Son gün. Bu fotoğrafa bakışın çok farklı.\nNe olursa olsun, onlar seni seviyor.",
		},
		{
			"name": "İstifa Mektubu",
			"icon": "✉",
			"desc": "Bu sefer tamamlanmış. İmza yeri boş.\nSadece bir imza uzaklığındasın.",
		},
		{
			"name": "Kişisel Not",
			"icon": "✎",
			"desc": "\"Bugün her şey biter. Hangisini seçersen seç,\narkana bakma.\"\nTitrek bir el yazısı.",
		},
	],
}

func show_drawer(day: int) -> void:
	if _is_open:
		return
	_is_open = true
	_selected_index = -1
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	AudioManager.play_sfx("drawer_open")
	_build_drawer(day)

func hide_drawer() -> void:
	if not _is_open:
		return
	_is_open = false
	AudioManager.play_sfx("drawer_close")

	# Slide down animation
	var tween: Tween = create_tween()
	tween.tween_property(_overlay, "color:a", 0.0, 0.2)
	tween.tween_callback(func() -> void:
		for child in get_children():
			child.queue_free()
		visible = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		drawer_closed.emit()
	)

func _build_drawer(day: int) -> void:
	# Clear any existing UI
	for child in get_children():
		child.queue_free()

	# Dark overlay
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.gui_input.connect(_on_overlay_input)
	add_child(_overlay)

	var overlay_tween: Tween = create_tween()
	overlay_tween.tween_property(_overlay, "color:a", 0.6, 0.25)

	# Drawer panel
	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -250
	panel.offset_top = -220
	panel.offset_right = 250
	panel.offset_bottom = 220
	_overlay.add_child(panel)

	# Slide up animation
	panel.position.y = 100
	panel.modulate.a = 0.0
	var panel_tween: Tween = create_tween()
	panel_tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	panel_tween.parallel().tween_property(panel, "position:y", 0.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Inner margin
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	# Title + close button row
	var title_row: HBoxContainer = HBoxContainer.new()
	vbox.add_child(title_row)

	var title_lbl: Label = Label.new()
	title_lbl.text = "MASA ÇEKMECESİ"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(0.85, 0.7, 0.45))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_lbl)

	var close_btn: Button = Button.new()
	close_btn.text = "✖"
	close_btn.custom_minimum_size = Vector2(48, 48)
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.pressed.connect(hide_drawer)
	title_row.add_child(close_btn)

	# Separator
	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	# Day label
	var day_lbl: Label = Label.new()
	day_lbl.text = "%d. Gün" % day
	day_lbl.add_theme_font_size_override("font_size", 13)
	day_lbl.add_theme_color_override("font_color", Color(0.5, 0.48, 0.4))
	vbox.add_child(day_lbl)

	# Items container
	var items: Array = ITEMS_BY_DAY.get(day, ITEMS_BY_DAY.get(1, []))
	var items_vbox: VBoxContainer = VBoxContainer.new()
	items_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(items_vbox)

	for i in range(items.size()):
		var item: Dictionary = items[i]
		var btn: Button = Button.new()
		btn.text = "  %s  %s" % [item.get("icon", "?"), item.get("name", "")]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_font_size_override("font_size", 15)
		var idx: int = i
		var desc: String = item.get("desc", "")
		btn.pressed.connect(func() -> void: _show_item_desc(desc, idx))

		# Stagger appearance
		btn.modulate.a = 0.0
		items_vbox.add_child(btn)
		var btn_tween: Tween = create_tween()
		btn_tween.tween_interval(0.2 + i * 0.1)
		btn_tween.tween_property(btn, "modulate:a", 1.0, 0.15)

	# Separator
	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	# Description area
	_desc_label = Label.new()
	_desc_label.text = "Bir eşyaya tıklayarak incele..."
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_font_size_override("font_size", 14)
	_desc_label.add_theme_color_override("font_color", Color(0.7, 0.68, 0.6))
	_desc_label.custom_minimum_size = Vector2(0, 90)
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_desc_label)

func _show_item_desc(desc: String, index: int) -> void:
	if _desc_label == null:
		return
	_selected_index = index
	AudioManager.play_sfx("tab_click")

	# Typewriter effect for description
	_desc_label.text = ""
	var tween: Tween = create_tween()
	for i in range(desc.length()):
		var idx: int = i + 1
		var d: String = desc
		tween.tween_callback(func() -> void:
			_desc_label.text = d.substr(0, idx)
		)
		tween.tween_interval(0.02)

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Only close if clicked on the overlay itself (not the panel)
		hide_drawer()
