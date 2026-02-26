extends Control
## Document inspection panel with tab buttons for switching between document types.
## Enhanced with slide-in animations, paper texture feel, and clickable suspicious fields.
## Clicking a suspicious field triggers an interrogation sequence.

@onready var tab_container: HBoxContainer = %DocTabs
@onready var content_panel: PanelContainer = %DocContent
@onready var content_label: RichTextLabel = %DocContentLabel
@onready var doc_title_label: Label = %DocTitleLabel

var _documents: Array[Resource] = []
var _current_tab: int = 0
var _content_tween: Tween = null
var _stress_time: float = 0.0
var _content_panel_base_pos: Vector2 = Vector2.ZERO
var _blur_timer: float = 0.0

const DOC_TYPE_NAMES: Dictionary = {
	"cv": "ÖZGEÇMİŞ",
	"diploma": "DİPLOMA",
	"reference": "REFERANS",
	"id_card": "KİMLİK",
	"criminal_record": "SABIKA KAYDI",
	"health_report": "SAĞLIK RAPORU",
}

func _ready() -> void:
	content_panel.visible = false
	content_label.bbcode_enabled = true
	content_label.meta_clicked.connect(_on_meta_clicked)
	_content_panel_base_pos = content_panel.position

func _process(delta: float) -> void:
	var s: float = GameManager.stress
	_stress_time += delta

	# Stress >= 0.3: Subtle hand tremor — document panel oscillates
	if s >= 0.3 and content_panel.visible:
		var tremor_intensity: float = (s - 0.3) * 4.0  # 0 to ~2.8
		var offset_x: float = sin(_stress_time * 6.0) * tremor_intensity
		var offset_y: float = cos(_stress_time * 8.0) * tremor_intensity * 0.5
		content_panel.position = _content_panel_base_pos + Vector2(offset_x, offset_y)
	elif content_panel.visible:
		content_panel.position = _content_panel_base_pos

	# Stress >= 0.5: Text occasionally blurs (alpha flicker)
	if s >= 0.5:
		_blur_timer += delta
		if _blur_timer > 3.0 + randf() * 4.0:
			_blur_timer = 0.0
			var blur_tween: Tween = create_tween()
			blur_tween.tween_property(content_label, "modulate:a", 0.4, 0.08)
			blur_tween.tween_property(content_label, "modulate:a", 1.0, 0.15)

func _on_meta_clicked(meta: Variant) -> void:
	# meta is the inconsistency info encoded as "type|detail|doc_index"
	var parts: PackedStringArray = str(meta).split("|")
	if parts.size() >= 3:
		EventBus.interrogation_requested.emit(parts[0], parts[1], parts[2].to_int())

func load_documents(documents: Array[Resource]) -> void:
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
	_current_tab = index
	var doc: DocumentData = _documents[index] as DocumentData
	if doc == null:
		return

	doc_title_label.text = DOC_TYPE_NAMES.get(doc.doc_type, doc.doc_type)

	# Build content with BBCode
	var text: String = ""
	match doc.doc_type:
		"cv":
			text = _format_cv(doc, index)
		"diploma":
			text = _format_diploma(doc, index)
		"reference":
			text = _format_reference(doc, index)
		"id_card":
			text = _format_id_card(doc, index)
		"criminal_record":
			text = _format_criminal_record(doc, index)
		"health_report":
			text = _format_health_report(doc, index)

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

## Wraps a value in a clickable BBCode link if the document has an inconsistency.
func _make_suspicious(value: String, doc: DocumentData, doc_index: int) -> String:
	if doc.has_inconsistency:
		var meta: String = doc.inconsistency_type + "|" + doc.inconsistency_detail + "|" + str(doc_index)
		return "[color=#c87533][url=" + meta + "]" + value + "[/url][/color]"
	return value

## Format a specific field as suspicious if it matches the inconsistency type's affected field.
func _suspicious_field(key: String, value: String, doc: DocumentData, doc_index: int, affected_keys: Array[String]) -> String:
	if doc.has_inconsistency and key in affected_keys:
		var meta: String = doc.inconsistency_type + "|" + doc.inconsistency_detail + "|" + str(doc_index)
		return "[color=#c87533][url=" + meta + "]" + value + "[/url][/color]"
	return value

func _get_affected_keys(inc_type: String) -> Array[String]:
	match inc_type:
		"name_mismatch":
			return ["Öğrenci Adı", "Ad Soyad"]
		"date_mismatch":
			return ["Mezuniyet", "Mezuniyet Yılı"]
		"university_mismatch":
			return ["Üniversite"]
		"experience_inflation":
			return ["Deneyim"]
		"fake_reference":
			return ["Şirket"]
		"fake_university":
			return ["Üniversite"]
		"gpa_mismatch":
			return ["Not Ortalaması"]
		"tc_invalid":
			return ["TC Kimlik No"]
		"address_mismatch":
			return ["Şehir", "İl"]
		_:
			return []

func _format_cv(doc: DocumentData, doc_index: int) -> String:
	var affected: Array[String] = _get_affected_keys(doc.inconsistency_type) if doc.has_inconsistency else []
	var t: String = ""
	t += "═══════════════════════\n"
	t += "     ÖZGEÇMİŞ\n"
	t += "═══════════════════════\n\n"
	for key: String in doc.content:
		var val: String = str(doc.content[key])
		val = _suspicious_field(key, val, doc, doc_index, affected)
		t += key + ": " + val + "\n"
	return t

func _format_diploma(doc: DocumentData, doc_index: int) -> String:
	var affected: Array[String] = _get_affected_keys(doc.inconsistency_type) if doc.has_inconsistency else []
	var t: String = ""
	t += "╔═══════════════════════╗\n"
	t += "║      DİPLOMA          ║\n"
	t += "╚═══════════════════════╝\n\n"
	var uni: String = _suspicious_field("Üniversite", doc.content.get("Üniversite", ""), doc, doc_index, affected)
	t += "  " + uni + "\n"
	t += "  ─────────────────\n\n"
	var name_val: String = _suspicious_field("Öğrenci Adı", doc.content.get("Öğrenci Adı", ""), doc, doc_index, affected)
	t += "  Öğrenci: " + name_val + "\n"
	t += "  Bölüm: " + doc.content.get("Bölüm", "") + "\n"
	var year_val: String = _suspicious_field("Mezuniyet Yılı", str(doc.content.get("Mezuniyet Yılı", "")), doc, doc_index, affected)
	t += "  Yıl: " + year_val + "\n"
	var gpa_val: String = _suspicious_field("Not Ortalaması", str(doc.content.get("Not Ortalaması", "")), doc, doc_index, affected)
	t += "  GNO: " + gpa_val + "\n"
	t += "\n         [MÜHÜR]\n"
	return t

func _format_reference(doc: DocumentData, doc_index: int) -> String:
	var affected: Array[String] = _get_affected_keys(doc.inconsistency_type) if doc.has_inconsistency else []
	var t: String = ""
	t += "───── REFERANS MEKTUBU ─────\n\n"
	t += "Kimden: " + doc.content.get("Referans Veren", "") + "\n"
	var company_val: String = _suspicious_field("Şirket", doc.content.get("Şirket", ""), doc, doc_index, affected)
	t += "Şirket: " + company_val + "\n"
	t += "─────────────────────────\n\n"
	t += doc.content.get("Değerlendirme", "") + "\n"
	t += "\n─────────────────────────\n"
	t += "İmza: " + doc.content.get("Referans Veren", "") + "\n"
	return t

func _format_id_card(doc: DocumentData, doc_index: int) -> String:
	var affected: Array[String] = _get_affected_keys(doc.inconsistency_type) if doc.has_inconsistency else []
	var t: String = ""
	t += "┌─────────────────────┐\n"
	t += "│  T.C. KİMLİK KARTI  │\n"
	t += "├─────────────────────┤\n"
	t += "│                     │\n"
	var tc_val: String = _suspicious_field("TC Kimlik No", doc.content.get("TC Kimlik No", ""), doc, doc_index, affected)
	t += "│  TC No: " + tc_val + "\n"
	t += "│  Ad: " + doc.content.get("Ad Soyad", "") + "\n"
	t += "│  Doğum: " + doc.content.get("Doğum Yılı", "") + "\n"
	t += "│  Cinsiyet: " + doc.content.get("Cinsiyet", "") + "\n"
	var city_val: String = _suspicious_field("İl", doc.content.get("İl", ""), doc, doc_index, affected)
	t += "│  İl: " + city_val + "\n"
	t += "│                     │\n"
	t += "└─────────────────────┘\n"
	return t

func _format_criminal_record(doc: DocumentData, doc_index: int) -> String:
	var t: String = ""
	t += "┌─────────────────────────┐\n"
	t += "│    SABIKA KAYDI         │\n"
	t += "├─────────────────────────┤\n"
	t += "│                         │\n"
	t += "│  TC No: " + doc.content.get("TC Kimlik No", "") + "\n"
	t += "│  Ad: " + doc.content.get("Ad Soyad", "") + "\n"
	t += "│  Durum: " + doc.content.get("Durum", "Temiz") + "\n"
	t += "│  Tarih: " + doc.content.get("Tarih", "") + "\n"
	t += "│                         │\n"
	t += "└─────────────────────────┘\n"
	return t

func _format_health_report(doc: DocumentData, doc_index: int) -> String:
	var t: String = ""
	t += "╔═════════════════════════╗\n"
	t += "║    SAĞLIK RAPORU        ║\n"
	t += "╚═════════════════════════╝\n\n"
	t += "  Ad: " + doc.content.get("Ad Soyad", "") + "\n"
	t += "  Durum: " + doc.content.get("Durum", "Sağlıklı") + "\n"
	if doc.content.has("Engellilik Oranı"):
		t += "  Engellilik: %" + str(doc.content.get("Engellilik Oranı", "0")) + "\n"
	t += "  Tarih: " + doc.content.get("Tarih", "") + "\n"
	t += "\n  [DOKTOR İMZASI]\n"
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
