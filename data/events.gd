class_name EventPool
extends RefCounted
## Scripted event definitions for moral dilemmas and story beats.

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
		_:
			return {"id": "", "title": "", "text": "", "choices": [], "trigger": "", "blocking": false}
