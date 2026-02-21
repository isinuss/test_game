extends Control
## Document inspection panel with tab buttons for switching between document types.

@onready var tab_container: HBoxContainer = %DocTabs
@onready var content_panel: PanelContainer = %DocContent
@onready var content_label: RichTextLabel = %DocContentLabel
@onready var doc_title_label: Label = %DocTitleLabel

var _documents: Array[Resource] = []
var _current_tab: int = 0

const DOC_TYPE_NAMES: Dictionary = {
	"cv": "ÖZGEÇMİŞ",
	"diploma": "DİPLOMA",
	"reference": "REFERANS",
	"id_card": "KİMLİK",
}

func _ready() -> void:
	content_panel.visible = false

func load_documents(documents: Array[Resource]) -> void:
	_documents = documents
	_current_tab = 0

	# Clear existing tabs
	for child: Node in tab_container.get_children():
		child.queue_free()

	# Create tab buttons
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

	content_panel.visible = true
	if documents.size() > 0:
		_show_document(0)

func _show_document(index: int) -> void:
	if index < 0 or index >= _documents.size():
		return
	_current_tab = index
	var doc: DocumentData = _documents[index] as DocumentData
	if doc == null:
		return

	doc_title_label.text = DOC_TYPE_NAMES.get(doc.doc_type, doc.doc_type)

	# Build rich text content
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
	for child: Node in tab_container.get_children():
		child.queue_free()
	content_panel.visible = false
	content_label.text = ""
