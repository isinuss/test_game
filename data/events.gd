class_name EventPool
extends RefCounted
## Scripted event definitions for moral dilemmas, story beats, and random encounters.

static func get_event(event_id: String) -> Dictionary:
	match event_id:
		"complaint_letter":
			return {
				"id": "complaint_letter",
				"title": "ŞİKAYET MEKTUBU",
				"text": "Dün reddettiğiniz bir aday şikayet dilekçesi göndermiş.\n\nMüdürünüz: \"Bu tür şikayetler başımıza iş açabilir. Dikkatli olun.\"",
				"choices": [
					{"text": "Dikkate alacağım", "flag": "", "value": true},
					{"text": "Hakkını aradığı için tebrik ederim", "flag": "empathetic", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}
		"ceo_nephew":
			return {
				"id": "ceo_nephew",
				"title": "CEO'NUN YEĞENİ",
				"text": "Müdürünüz kapınızı çaldı:\n\n\"Bugün gelen adaylardan biri CEO'nun yeğeni. Durumu biliyorsunuz... Akıllıca karar verin.\"",
				"choices": [
					{"text": "Anlıyorum, 'uygun' değerlendireceğim", "flag": "accepted_nepotism", "value": true},
					{"text": "Herkese aynı kriterleri uygularım", "flag": "rejected_nepotism", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}
		"union_pressure":
			return {
				"id": "union_pressure",
				"title": "SENDİKA TEMSİLCİSİ",
				"text": "Sendika temsilcisi ofisinize geldi:\n\n\"Ahmet Yılmaz bizim adamımız. Onu işe almazsanız grev başlatırız.\"\n\n\"Ama direktif de kimseyi almayın diyor...\"",
				"choices": [
					{"text": "Sendikayı destekleyeceğim", "flag": "supported_union", "value": true},
					{"text": "Direktiflere uyacağım", "flag": "supported_union", "value": false},
				],
				"trigger": "day_start",
				"blocking": true,
			}
		"whistleblower":
			return {
				"id": "whistleblower",
				"title": "İHBARCI",
				"text": "Bir aday mülakat sırasında fısıldadı:\n\n\"Bu şirkette ciddi yolsuzluk var. Sahte işe alımlar, hayalet çalışanlar... Hepsinin belgesi bende.\"\n\n\"Bana yardım eder misiniz?\"",
				"choices": [
					{"text": "Belgeleri göster, dinliyorum", "flag": "listened_whistleblower", "value": true},
					{"text": "Bu beni ilgilendirmez", "flag": "ignored_whistleblower", "value": true},
				],
				"trigger": "candidate_3",
				"blocking": true,
			}
		"final_choice":
			return {
				"id": "final_choice",
				"title": "SON KARAR",
				"text": "Gün sonu yaklaşıyor. Masanızda iki dosya var:\n\n1. Yolsuzluk belgelerini savcılığa gönderecek dilekçe\n2. CEO'nun \"teşekkür\" zarfı — içinde hatırı sayılır bir miktar\n\nHangisini seçiyorsunuz?",
				"choices": [
					{"text": "Dilekçeyi gönder — doğru olanı yap", "flag": "reported_fraud", "value": true},
					{"text": "Zarfı al — sistem böyle çalışıyor", "flag": "ignored_fraud", "value": true},
				],
				"trigger": "day_end",
				"blocking": true,
			}
		"violation_redemption":
			return {
				"id": "violation_redemption",
				"title": "İYİ HABER",
				"text": "Dün tartışmalı bulduğunuz bir karar beklenenden iyi sonuçlandı!\n\nMüdürünüz: \"Görünüşe göre o kadar da kötü değilmiş. İhlal kaydını siliyorum.\"\n\n— 1 ihlal silindi —",
				"choices": [
					{"text": "İyi ki öyle olmuş", "flag": "", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}
		_:
			return {"id": "", "title": "", "text": "", "choices": [], "trigger": "", "blocking": false}

# ── Random Event Pool ─────────────────────────────────────────────────────

const RANDOM_EVENTS: Array[Dictionary] = [
	{
		"id": "random_phone_call",
		"title": "TELEFON",
		"text": "Telefonunuz çalıyor... Eşiniz arıyor:\n\n\"Bu akşam erken gelir misin? Çocuk seni soruyor.\"\n\nNe cevap veriyorsunuz?",
		"choices": [
			{"text": "Eve erken geleceğim", "flag": "family_first", "value": true},
			{"text": "İşim var, geç kalabilirim", "flag": "work_first", "value": true},
		],
		"trigger": "random",
		"blocking": true,
		"time_penalty": 0.0,
		"min_day": 1,
	},
	{
		"id": "random_coffee_spill",
		"title": "KAZA!",
		"text": "Kahvenizi masaya döktünüz! Belgeler ıslandı, temizlemeye çalışıyorsunuz.\n\n— 15 saniye kayıp —",
		"choices": [
			{"text": "Hızla temizle", "flag": "", "value": true},
		],
		"trigger": "random",
		"blocking": true,
		"time_penalty": 15.0,
		"min_day": 1,
	},
	{
		"id": "random_gossip",
		"title": "DEDİKODU",
		"text": "Yan masadan fısıltılar geliyor:\n\n\"Duymuş muydun? Üst kattan birini kovmuşlar. Dosyaları karıştırmış...\"\n\nDinliyor musunuz?",
		"choices": [
			{"text": "Kulak kabartayım", "flag": "", "value": true},
			{"text": "İşime bakayım", "flag": "", "value": true},
		],
		"trigger": "random",
		"blocking": true,
		"time_penalty": 0.0,
		"min_day": 1,
	},
	{
		"id": "random_system_error",
		"title": "SİSTEM HATASI",
		"text": "İK sistemi çöktü!\n\n\"Sunucu bakımda, lütfen bekleyin.\"\n\nEkranda dönen bir yükleme simgesi var...\n\n— 20 saniye kayıp —",
		"choices": [
			{"text": "Sabırla bekle", "flag": "", "value": true},
		],
		"trigger": "random",
		"blocking": true,
		"time_penalty": 20.0,
		"min_day": 2,
	},
	{
		"id": "random_old_colleague",
		"title": "ESKİ ARKADAŞ",
		"text": "Koridorda eski bir iş arkadaşınız belirdi.\n\n\"Vay, sen hâlâ burada mısın? Ben çoktan ayrıldım. Bu şirkette fazla kalma derim...\"\n\nNe düşünüyorsunuz?",
		"choices": [
			{"text": "Belki haklısın...", "flag": "", "value": true},
			{"text": "Ben durumumu hallederim", "flag": "", "value": true},
		],
		"trigger": "random",
		"blocking": true,
		"time_penalty": 0.0,
		"min_day": 2,
	},
	{
		"id": "random_inspection",
		"title": "DENETİM",
		"text": "İç denetim ekibi ofise geldi!\n\n\"Bugünkü kararlarınız ekstra incelenecek. Lütfen kurallara harfiyen uyun.\"\n\nBaskı altında hissediyorsunuz.",
		"choices": [
			{"text": "Anlaşıldı", "flag": "under_inspection", "value": true},
		],
		"trigger": "random",
		"blocking": true,
		"time_penalty": 0.0,
		"min_day": 3,
	},
	{
		"id": "random_power_outage",
		"title": "ELEKTRİK KESİNTİSİ",
		"text": "Bir anlığına karanlıkta kaldınız... Jeneratör devreye girdi.\n\nFluoresan lambalar titreşerek tekrar yandı.\n\n— 10 saniye kayıp —",
		"choices": [
			{"text": "Devam edelim", "flag": "", "value": true},
		],
		"trigger": "random",
		"blocking": true,
		"time_penalty": 10.0,
		"min_day": 1,
	},
	{
		"id": "random_headache",
		"title": "BAŞ AĞRISI",
		"text": "Şakaklarınız zonkluyor. Çekmeceyi açıp aspirine uzanıyorsunuz.\n\n\"Bu iş beni bitiriyor...\" diye düşünüyorsunuz.",
		"choices": [
			{"text": "Aspirin al, devam et", "flag": "", "value": true},
			{"text": "Biraz göz dinlendir", "flag": "", "value": true},
		],
		"trigger": "random",
		"blocking": true,
		"time_penalty": 5.0,
		"min_day": 3,
	},
]

static func get_random_event(day: int) -> Dictionary:
	var eligible: Array[Dictionary] = []
	for ev: Dictionary in RANDOM_EVENTS:
		if day >= ev.get("min_day", 1):
			eligible.append(ev)
	if eligible.is_empty():
		return {"id": "", "title": "", "text": "", "choices": [], "trigger": "", "blocking": false}
	return eligible[randi() % eligible.size()]
