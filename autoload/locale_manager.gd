extends Node
## Localization manager — loads key-based translations from JSON files.
## Provides t() for strings, ta() for arrays, trand() for random array elements.

var _locale: String = "tr"
var _translations: Dictionary = {}

func _ready() -> void:
	load_locale(_locale)

func load_locale(locale_id: String) -> void:
	_locale = locale_id
	var path: String = "res://localization/" + locale_id + ".json"
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("LocaleManager: Could not open " + path)
		return
	var json: JSON = JSON.new()
	var err: Error = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_warning("LocaleManager: JSON parse error in " + path + ": " + json.get_error_message())
		return
	_translations = json.data

func get_locale() -> String:
	return _locale

## Returns translated string for a key. Falls back to the key itself.
## Supports format args: t("ui.day_status") % [day, max_days]
func t(key: String) -> String:
	var val: Variant = _translations.get(key, null)
	if val is String:
		return val
	return key

## Returns translated array for a key. Falls back to empty array.
func ta(key: String) -> Array:
	var val: Variant = _translations.get(key, null)
	if val is Array:
		return val
	return []

## Returns a random element from a translated array. Falls back to the key.
func trand(key: String) -> String:
	var arr: Array = ta(key)
	if arr.size() > 0:
		return str(arr[randi() % arr.size()])
	return key
