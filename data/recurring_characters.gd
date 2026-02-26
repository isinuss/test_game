class_name RecurringCharacters
extends RefCounted
## Named characters that appear across multiple days with consistent appearances.
## Provides character definitions and day-specific greetings.

const CHARACTERS: Dictionary = {
	"selim_patronoglu": {
		"name": "Selim Patronoğlu",
		"photo_seed": 99999,
		"gender": "E",
		"role": "CEO'nun yeğeni",
		"appears_on": [3, 14],
		"greetings": {
			3: "Merhaba. CEO'nun yeğeniyim. Sanırım beni bekliyordunuz.",
			14: "Beni hatırlarsın. Artık senin üstünüm.",
		},
	},
	"ahmet_yilmaz": {
		"name": "Ahmet Yılmaz",
		"photo_seed": 88888,
		"gender": "E",
		"role": "Sendika adayı",
		"appears_on": [4, 11],
		"greetings": {
			4: "Merhaba, sendika beni yönlendirdi.",
			11: "Yeni yönetim de beni tanıyor. Bu sefer kalıcıyım.",
		},
	},
	"deniz_firat": {
		"name": "Deniz Fırat",
		"photo_seed": 77777,
		"gender": "K",
		"role": "İhbarcı",
		"appears_on": [4, 12],
		"greetings": {
			4: "Bu şirkette ciddi yolsuzluk var...",
			12: "Söylediklerimle ilgili bir şey yaptınız mı?",
		},
	},
	"elif_korkmaz": {
		"name": "Elif Korkmaz",
		"photo_seed": 66666,
		"gender": "K",
		"role": "Gazeteci",
		"appears_on": [8, 15],
		"greetings": {
			8: "Merhaba, iş başvurusu için geldim. Güzel bir şirketmiş.",
			15: "Hatırladınız mı beni? Yazdığım haber yarın çıkıyor.",
		},
	},
	"hakan_sezer": {
		"name": "Hakan Sezer",
		"photo_seed": 55555,
		"gender": "E",
		"role": "Denetçi",
		"appears_on": [10, 13],
		"greetings": {
			10: "Kayıtlarınızı inceliyorum. Bazı ilginç kararlar var.",
			13: "Bu sefer savcılık adına geldim.",
		},
	},
	"canan_hanim": {
		"name": "Canan Yıldırım",
		"photo_seed": 44444,
		"gender": "K",
		"role": "İK Müdürü (sizin müdürünüz)",
		"appears_on": [1, 5, 9, 14],
		"greetings": {
			1: "Hoş geldiniz. Ben Canan, İK müdürünüz.",
			5: "Denetçiler pazartesi geliyor. Hazırlıklı olun.",
			9: "CEO sizi görmek istiyor. Dikkatli olun.",
			14: "Üç haftadır seni izliyorum.",
		},
	},
}

static func get_character(char_id: String) -> Dictionary:
	return CHARACTERS.get(char_id, {})

static func get_character_greeting(char_id: String, day: int) -> String:
	var char_data: Dictionary = get_character(char_id)
	var greetings: Dictionary = char_data.get("greetings", {})
	return greetings.get(day, char_data.get("greetings", {}).values()[0] if not greetings.is_empty() else "")

static func get_character_seed(char_id: String) -> int:
	return get_character(char_id).get("photo_seed", 0)

static func get_characters_for_day(day: int) -> Array[String]:
	var result: Array[String] = []
	for char_id: String in CHARACTERS:
		var char_data: Dictionary = CHARACTERS[char_id]
		if day in char_data.get("appears_on", []):
			result.append(char_id)
	return result
