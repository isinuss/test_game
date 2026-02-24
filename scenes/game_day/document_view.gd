extends Control
## Document inspection panel with tab buttons for switching between document types.
## Enhanced with slide-in animations and paper texture feel.

@onready var tab_container: HBoxContainer = %DocTabs
@onready var content_panel: PanelContainer = %DocContent
@onready var content_label: RichTextLabel = %DocContentLabel
@onready var doc_title_label: Label = %DocTitleLabel

var _documents: Array[Resource] = []
var _current_tab: int = 0
var _content_tween: Tween = null

const DOC_TYPE_NAMES: Dictionary = {
	"cv": "ÖZGEÇMİŞ",
	"diploma": "DİPLOMA",
	"reference": "REFERANS",
	"id_card": "KİMLİK",
}

func _ready() -> void:
	content_panel.visible = false

func load_documents(documents: Array[Resource]) -> void:
	AudioManager.play_sfx("paper")
	_documents = documents
	_current_tab = 0

	# Clear existing tabs
	for child: Node in tab_container.get_children():
		child.queue_free()

	# Create tab buttons with staggered animation
	for i in range(documents.size()):
		var doc: DocumentData = documents[i] as DocumentData
		if doc == null:
			continue
		var btn: Button = Button.new()
		btn.text = DOC_TYPE_NAMES.get(doc.doc_type, doc.doc_type)
		btn.custom_minimum_size = Vector2(90, 28)
		btn.add_theme_font_size_override("font_size", 11)
		var idx: int = i
		btn.pressed.connect(func() -> void: _show_document(idx))
		tab_container.add_child(btn)

		# Tab buttons slide in from top
		btn.modulate.a = 0.0
		btn.position.y = -15.0
		var tab_tween: Tween = create_tween()
		tab_tween.tween_interval(i * 0.08)
		tab_tween.tween_property(btn, "modulate:a", 1.0, 0.2)
		tab_tween.parallel().tween_property(btn, "position:y", 0.0, 0.2).set_ease(Tween.EASE_OUT)

	# Show first document with paper slide-in
	content_panel.visible = true
	if documents.size() > 0:
		# Paper appears from below
		content_panel.modulate.a = 0.0
		content_panel.position.y = 30.0
		var panel_tween: Tween = create_tween()
		panel_tween.tween_interval(0.15)
		panel_tween.tween_property(content_panel, "modulate:a", 1.0, 0.25)
		panel_tween.parallel().tween_property(content_panel, "position:y", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		panel_tween.tween_callback(func() -> void: _show_document(0))

func _show_document(index: int) -> void:
	if index < 0 or index >= _documents.size():
		return

	var same_tab: bool = (index == _current_tab and content_label.text != "")
	if not same_tab:
		AudioManager.play_sfx("tab_click")
	_current_tab = index
	var doc: DocumentData = _documents[index] as DocumentData
	if doc == null:
		return

	doc_title_label.text = DOC_TYPE_NAMES.get(doc.doc_type, doc.doc_type)

	# Build content
	var text: String = ""
	match doc.doc_type:
		"cv":
			text = _format_cv(doc)
		"diploma":
			text = _format_diploma(doc)
		"reference":
			text = _format_reference(doc)
		"id_card":
			text = _format_id_card(doc)

	# Animate content swap if switching tabs
	if _content_tween and _content_tween.is_valid():
		_content_tween.kill()

	if not same_tab:
		_content_tween = create_tween()
		# Quick fade out of old content
		_content_tween.tween_property(content_label, "modulate:a", 0.0, 0.08)
		_content_tween.tween_callback(func() -> void:
			content_label.text = text
		)
		# Slide in new content from right
		_content_tween.tween_property(content_label, "position:x", 12.0, 0.0)
		_content_tween.tween_property(content_label, "modulate:a", 1.0, 0.15)
		_content_tween.parallel().tween_property(content_label, "position:x", 0.0, 0.15).set_ease(Tween.EASE_OUT)
	else:
		content_label.text = text

	# Update tab button appearances
	for i in range(tab_container.get_child_count()):
		var btn: Button = tab_container.get_child(i) as Button
		if btn:
			if i == index:
				btn.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
			else:
				btn.remove_theme_color_override("font_color")

func _format_cv(doc: DocumentData) -> String:
	var t: String = ""
	t += "═══════════════════════\n"
	t += "     ÖZGEÇMİŞ\n"
	t += "═══════════════════════\n\n"
	for key: String in doc.content:
		t += key + ": " + str(doc.content[key]) + "\n"
	return t

func _format_diploma(doc: DocumentData) -> String:
	var t: String = ""
	t += "╔═══════════════════════╗\n"
	t += "║      DİPLOMA          ║\n"
	t += "╚═══════════════════════╝\n\n"
	var uni: String = doc.content.get("Üniversite", "")
	t += "  " + uni + "\n"
	t += "  ─────────────────\n\n"
	t += "  Öğrenci: " + doc.content.get("Öğrenci Adı", "") + "\n"
	t += "  Bölüm: " + doc.content.get("Bölüm", "") + "\n"
	t += "  Yıl: " + str(doc.content.get("Mezuniyet Yılı", "")) + "\n"
	t += "  GNO: " + str(doc.content.get("Not Ortalaması", "")) + "\n"
	t += "\n         [MÜHÜR]\n"
	return t

func _format_reference(doc: DocumentData) -> String:
	var t: String = ""
	t += "───── REFERANS MEKTUBU ─────\n\n"
	t += "Kimden: " + doc.content.get("Referans Veren", "") + "\n"
	t += "Şirket: " + doc.content.get("Şirket", "") + "\n"
	t += "─────────────────────────\n\n"
	t += doc.content.get("Değerlendirme", "") + "\n"
	t += "\n─────────────────────────\n"
	t += "İmza: " + doc.content.get("Referans Veren", "") + "\n"
	return t

func _format_id_card(doc: DocumentData) -> String:
	var t: String = ""
	t += "┌─────────────────────┐\n"
	t += "│  T.C. KİMLİK KARTI  │\n"
	t += "├─────────────────────┤\n"
	t += "│                     │\n"
	t += "│  TC No: " + doc.content.get("TC Kimlik No", "") + "\n"
	t += "│  Ad: " + doc.content.get("Ad Soyad", "") + "\n"
	t += "│  Doğum: " + doc.content.get("Doğum Yılı", "") + "\n"
	t += "│  Cinsiyet: " + doc.content.get("Cinsiyet", "") + "\n"
	t += "│  İl: " + doc.content.get("İl", "") + "\n"
	t += "│                     │\n"
	t += "└─────────────────────┘\n"
	return t

func clear_documents() -> void:
	_documents = []
	if _content_tween and _content_tween.is_valid():
		_content_tween.kill()
	for child: Node in tab_container.get_children():
		child.queue_free()
	# Slide paper out
	if content_panel.visible:
		var tween: Tween = create_tween()
		tween.tween_property(content_panel, "modulate:a", 0.0, 0.15)
		tween.parallel().tween_property(content_panel, "position:y", 20.0, 0.15)
		tween.tween_callback(func() -> void:
			content_panel.visible = false
			content_panel.position.y = 0.0
			content_panel.modulate.a = 1.0
			content_label.text = ""
		)
	else:
		content_panel.visible = false
		content_label.text = ""
