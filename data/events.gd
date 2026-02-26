class_name EventPool
extends RefCounted
## Scripted event definitions for moral dilemmas and story beats.
## Expanded for 15-day campaign: 22 events across 3 weeks.

static func get_event(event_id: String) -> Dictionary:
	match event_id:
		# ═══════════ WEEK 1: ORIENTATION ═══════════

		"office_tour":
			return {
				"id": "office_tour",
				"title": "OFİS TURU",
				"text": "Müdürünüz Canan Hanım sizi karşılıyor:\n\n\"Hoş geldiniz. Ben Canan, İK müdürünüz. Burada işler basit: adayları incele, belgeleri kontrol et, damga bas.\"\n\n\"Önceki İK'cı... neyse, o konu kapandı.\"",
				"choices": [
					{"text": "Önceki İK'cıya ne oldu?", "flag": "curious_about_past", "value": true},
					{"text": "Anladım, hemen başlayalım", "flag": "obedient", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}

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

		"internal_audit_warning":
			return {
				"id": "internal_audit_warning",
				"title": "DENETİM UYARISI",
				"text": "Gün sonu yaklaşırken müdürünüz Canan Hanım kapıyı aralıyor:\n\n\"Pazartesi denetçiler geliyor. Bu haftaki tüm kararlarınız incelenecek.\"\n\n\"Kayıtlarınızın temiz olduğundan emin olun.\"",
				"choices": [
					{"text": "Endişelenmeli miyim?", "flag": "audit_anxious", "value": true},
					{"text": "Kayıtlarım temiz", "flag": "audit_confident", "value": true},
				],
				"trigger": "day_end",
				"blocking": true,
			}

		# ═══════════ WEEK 2: PRESSURE ═══════════

		"new_hr_policy":
			return {
				"id": "new_hr_policy",
				"title": "YENİ İK POLİTİKASI",
				"text": "Yönetim kurulundan yeni bir genelge geldi:\n\n\"Şirketin dinamik yapısını korumak adına, 40 yaş üstü adaylara alım durdurulmuştur.\"\n\nBu yaş ayrımcılığı değil mi?",
				"choices": [
					{"text": "Yanlış ama uygulamak zorundayım", "flag": "compliant_ageism", "value": true},
					{"text": "Bir yolunu bulup direnebilirim", "flag": "resisted_ageism", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}

		"returning_candidate":
			return {
				"id": "returning_candidate",
				"title": "TANIDIK BİR YÜZ",
				"text": "Sıradaki aday tanıdık geliyor... Geçen hafta reddettiğiniz biri mi?\n\nİsmi farklı ama yüzü aynı. Belgeleri de yeni görünüyor.",
				"choices": [
					{"text": "Sizi hatırlıyorum...", "flag": "recognized_returner", "value": true},
					{"text": "Belgelerinizi tekrar inceleyeyim", "flag": "treated_as_new", "value": true},
				],
				"trigger": "candidate_2",
				"blocking": true,
			}

		"anonymous_tip":
			return {
				"id": "anonymous_tip",
				"title": "İSİMSİZ İHBAR",
				"text": "Masanızda isimsiz bir not buldunuz:\n\n\"Bugünkü adaylardan biri sahte belgelerle geldi. Dikkat edin.\"\n\nNot üzerinde bir isim var ama silinmiş.",
				"choices": [
					{"text": "Araştıracağım", "flag": "investigated_tip", "value": true},
					{"text": "Çöpe at, isimsiz ihbarlara güvenmem", "flag": "ignored_tip", "value": true},
				],
				"trigger": "day_end",
				"blocking": true,
			}

		"journalist_visit":
			return {
				"id": "journalist_visit",
				"title": "GAZETECİ ZİYARETİ",
				"text": "Güvenlikten bir uyarı geldi:\n\n\"Bugün binaya bir gazeteci girmiş olabilir. Aday kılığında olabilir. Basına açıklama yapmayın.\"\n\nDikkatli olun — ya da belki gazeteci doğru kişidir.",
				"choices": [
					{"text": "Dikkatli olacağım, bilgi sızdırmam", "flag": "cautious_journalist", "value": true},
					{"text": "Gazeteci doğruyu ortaya çıkarabilir", "flag": "open_to_journalist", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}

		"secret_meeting":
			return {
				"id": "secret_meeting",
				"title": "GİZLİ TOPLANTI",
				"text": "CEO sizi odasına çağırdı. Kapı kapatıldı.\n\n\"Zor zamanlardan geçiyoruz. Kime güvenebileceğimi bilmem lazım.\"\n\n\"Siz hangi taraftasınız?\"",
				"choices": [
					{"text": "Şirkete sadığım, size güvenebilirsiniz", "flag": "pledged_loyalty", "value": true},
					{"text": "Ben doğru olanı yapmaya sadığım", "flag": "pledged_integrity", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}

		"double_agent":
			return {
				"id": "double_agent",
				"title": "ŞÜPHELİ ADAY",
				"text": "Sıradaki adayın belgeleri mükemmel — belki de fazla mükemmel.\n\nSorularına verdiği cevaplar ezbere gibi. Ve masanızdaki dosyalara çok ilgili görünüyor.",
				"choices": [
					{"text": "CEO'ya rapor et — şirket casusu olabilir", "flag": "reported_spy_to_ceo", "value": true},
					{"text": "Yetkililere bildir — endüstriyel casusluk", "flag": "reported_spy_to_law", "value": true},
					{"text": "Görmezden gel, beni ilgilendirmez", "flag": "ignored_spy", "value": true},
				],
				"trigger": "candidate_4",
				"blocking": true,
			}

		"audit_review":
			return {
				"id": "audit_review",
				"title": "DENETİM RAPORU",
				"text": "Denetçi Hakan Sezer masanıza oturdu:\n\n\"Geçen haftaki kararlarınızı inceledim. Bazı... ilginç kararlar var.\"\n\nDosyalarınızı tek tek gözden geçiriyor.",
				"choices": [
					{"text": "İncelemenizi bekleyeyim", "flag": "", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}

		"week2_choice":
			return {
				"id": "week2_choice",
				"title": "DENETÇİNİN SORUSU",
				"text": "Denetçi Hakan Sezer size bir belge uzatıyor:\n\n\"Bu, geçen haftaki işe alım süreçlerinizin özeti. İmzalamanız gerekiyor.\"\n\n\"Herhangi bir düzensizlik var mıydı?\"",
				"choices": [
					{"text": "Her şey kurallara uygundu", "flag": "lied_to_auditor", "value": true},
					{"text": "Bazı... komplikasyonlar yaşandı", "flag": "told_auditor_truth", "value": true},
				],
				"trigger": "day_end",
				"blocking": true,
			}

		# ═══════════ WEEK 3: RECKONING ═══════════

		"regime_change":
			return {
				"id": "regime_change",
				"title": "YÖNETİM DEĞİŞİKLİĞİ",
				"text": "Sabah geldiğinizde her şey farklı.\n\nEski CEO'nun fotoğrafları kaldırılmış. Yeni bir isim plakası asılmış.\n\n\"Yeni yönetim kurulu kararıyla görevden alındı. Bugünden itibaren yeni kurallar geçerli.\"\n\nYeni kurallar eski kurallardan daha kötü.",
				"choices": [
					{"text": "Her yönetim aynı, uygularım", "flag": "accepted_regime", "value": true},
					{"text": "Bu sefer dayanma sınırım aşılabilir", "flag": "questioning_regime", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}

		"ghost_employees":
			return {
				"id": "ghost_employees",
				"title": "HAYALET ÇALIŞANLAR",
				"text": "Sıradaki adayın TC kimlik numarasını sisteme girdiğinizde bir hata çıktı:\n\n\"Bu kişi zaten şirkette çalışıyor.\"\n\nAma aday ilk kez buraya geliyor. Birisi bu isimle maaş alıyor — bir hayalet çalışan.",
				"choices": [
					{"text": "Sisteme bildir, bu sahtecilik", "flag": "flagged_ghost", "value": true},
					{"text": "Görmezden gel, başıma iş açılmasın", "flag": "ignored_ghost", "value": true},
				],
				"trigger": "candidate_3",
				"blocking": true,
			}

		"informant_return":
			return {
				"id": "informant_return",
				"title": "İHBARCININ DÖNÜŞÜ",
				"text": "Gün sonunda tanıdık bir yüz kapınızda belirdi — Deniz Fırat, 4. günkü ihbarcı.\n\n\"Söylediklerimle ilgili bir şey yaptınız mı?\"",
				"choices": [
					{"text": "Evet, belgeleri sakladım", "flag": "reassured_informant", "value": true},
					{"text": "Elimden bir şey gelmedi", "flag": "disappointed_informant", "value": true},
				],
				"trigger": "day_end",
				"blocking": true,
			}

		"prosecutor_visit":
			return {
				"id": "prosecutor_visit",
				"title": "SAVCILIK ZİYARETİ",
				"text": "İki kişi kimliklerini gösterdi — savcılık müfettişleri.\n\n\"Son iki haftadaki işe alım kayıtlarınıza ihtiyacımız var. Tam işbirliği bekliyoruz.\"\n\n\"Veya avukatınızla görüşebilirsiniz.\"",
				"choices": [
					{"text": "Tam işbirliği yapacağım", "flag": "cooperated_prosecutor", "value": true},
					{"text": "Önce hukuk danışmanıma sorayım", "flag": "stalled_prosecutor", "value": true},
				],
				"trigger": "day_start",
				"blocking": true,
			}

		"evidence_choice":
			return {
				"id": "evidence_choice",
				"title": "KANIT",
				"text": "Gün sonunda masanızın çekmecesinde bir USB bellek buldunuz.\n\nÜzerinde \"İK kayıtları — gerçek\" yazıyor.\n\nBu, şirketteki tüm sahte işe alımların kaydını içeriyor olabilir.",
				"choices": [
					{"text": "Kopyala ve sakla", "flag": "copied_evidence", "value": true},
					{"text": "Savcılığa teslim et", "flag": "gave_evidence", "value": true},
					{"text": "Yok et — riskli", "flag": "destroyed_evidence", "value": true},
				],
				"trigger": "day_end",
				"blocking": true,
			}

		"confrontation":
			return {
				"id": "confrontation",
				"title": "YÜZLEŞME",
				"text": "İlk adayınız... Selim Patronoğlu. CEO'nun yeğeni geri döndü.\n\nAma bu sefer aday olarak değil.\n\n\"Yeni yönetim beni buraya atadı. Artık senin üstünüm.\"",
				"choices": [
					{"text": "Tebrikler, nasıl yardımcı olabilirim?", "flag": "submitted_to_nephew", "value": true},
					{"text": "Belgelerin hâlâ yetersiz, Selim Bey", "flag": "defied_nephew", "value": true},
				],
				"trigger": "candidate_1",
				"blocking": true,
			}

		"ally_or_enemy":
			return {
				"id": "ally_or_enemy",
				"title": "DOST MU DÜŞMAN MI?",
				"text": "Gün sonunda Canan Hanım ofisinize geldi. Kapıyı kapattı.\n\n\"Üç haftadır seni izliyorum. Bazıları seni sevdi, bazıları senden korktu.\"\n\n\"Son bir günün var. Ne yapacaksın?\"",
				"choices": [
					{"text": "Doğru olanı yapacağım, ne olursa olsun", "flag": "final_resolve_moral", "value": true},
					{"text": "Hayatta kalmak önemli", "flag": "final_resolve_survival", "value": true},
				],
				"trigger": "day_end",
				"blocking": true,
			}

		"final_choice_expanded":
			return {
				"id": "final_choice_expanded",
				"title": "SON KARAR",
				"text": "Son gün, son aday da gitti. Masanızda dört seçenek var:\n\n1. Savcılığa hazırladığınız dosya\n2. Yönetim kuruluna sunum\n3. \"Altın paraşüt\" — tazminat teklifi ve sessizlik anlaşması\n4. İstifa mektubu\n\nBu şirketteki son kararınız.",
				"choices": [
					{"text": "Kanıtları basına sızdır", "flag": "reported_fraud", "value": true, "requires_flag": "copied_evidence"},
					{"text": "Yönetim kurulunda ifade ver", "flag": "reported_fraud", "value": true, "requires_flag": "cooperated_prosecutor"},
					{"text": "Altın paraşütü kabul et, sessizce ayrıl", "flag": "ignored_fraud", "value": true},
					{"text": "Her şeyi yakıp yeniden başla", "flag": "burned_bridges", "value": true},
				],
				"trigger": "day_end",
				"blocking": true,
			}

		# Kept for backwards compatibility with Week 1 day 5 original
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


## Returns event with conditional text based on player's prior choices.
## Use this for events that branch based on accumulated flags.
static func get_event_conditional(event_id: String, game_flags: Dictionary) -> Dictionary:
	var base: Dictionary = get_event(event_id)

	match event_id:
		"informant_return":
			if game_flags.get("listened_whistleblower", false):
				base["text"] = "Gün sonunda tanıdık bir yüz kapınızda belirdi — Deniz Fırat.\n\n\"Söylediklerimi dinlemiştiniz. Teşekkür ederim.\"\n\n\"Ama daha fazlası var. Hayalet çalışanlar sadece başlangıç.\""
				base["choices"] = [
					{"text": "Ne biliyorsan anlat", "flag": "deepened_informant", "value": true},
					{"text": "Yeterince risk aldım", "flag": "cut_off_informant", "value": true},
				]
			else:
				base["text"] = "Gün sonunda tanıdık bir yüz kapınızda belirdi — Deniz Fırat, geçen hafta ihbar eden aday.\n\nYüzünde hayal kırıklığı var.\n\n\"Hiçbir şey yapmadınız, değil mi?\""
				base["choices"] = [
					{"text": "Elimden gelen buydu", "flag": "disappointed_informant", "value": true},
					{"text": "Şimdi dinliyorum, anlat", "flag": "late_informant_listen", "value": true},
				]

		"confrontation":
			if game_flags.get("accepted_nepotism", false):
				base["text"] = "İlk adayınız... Selim Patronoğlu. CEO'nun yeğeni geri döndü.\n\nSizi tanıdı ve gülümsedi.\n\n\"Beni işe alan sendin. Yeni yönetim de beni buraya atadı. Artık senin üstünüm.\"\n\n\"İyi anlaşacağız, değil mi?\""
				base["choices"] = [
					{"text": "Tabii ki, Selim Bey", "flag": "submitted_to_nephew", "value": true},
					{"text": "O gün hata yaptım", "flag": "regretted_nepotism", "value": true},
				]
			else:
				base["text"] = "İlk adayınız... Selim Patronoğlu. CEO'nun yeğeni geri döndü.\n\nYüzü soğuk.\n\n\"Beni reddettin. Ama yeni yönetim beni yine de aldı. Artık senin üstünüm.\"\n\n\"Karma diye bir şey var.\""
				base["choices"] = [
					{"text": "Doğru kararı verdim, hâlâ arkasındayım", "flag": "defied_nephew", "value": true},
					{"text": "Geçmişi geçmişte bırakalım", "flag": "submitted_to_nephew", "value": true},
				]

		"ally_or_enemy":
			var moral: int = 0
			if game_flags.get("rejected_nepotism", false): moral += 1
			if game_flags.get("listened_whistleblower", false): moral += 1
			if game_flags.get("resisted_ageism", false): moral += 1
			if game_flags.get("cooperated_prosecutor", false): moral += 1

			if moral >= 3:
				base["text"] = "Gün sonunda Canan Hanım ofisinize geldi. Kapıyı kapattı.\n\n\"Üç haftadır seni izliyorum. Doğru olanı yapmaya çalıştın.\"\n\n\"Yarın son günün. Seni destekleyeceğim — ama dikkatli ol.\""
				base["choices"] = [
					{"text": "Teşekkürler, Canan Hanım", "flag": "gained_ally", "value": true},
					{"text": "Kimseye güvenemem artık", "flag": "lone_wolf", "value": true},
				]
			else:
				base["text"] = "Gün sonunda Canan Hanım ofisinize geldi. Kapıyı kapattı.\n\n\"Üç haftadır seni izliyorum. Ne yaptığından emin değilim.\"\n\n\"Son bir günün var. Tavsiyem: fazla dikkat çekme.\""
				base["choices"] = [
					{"text": "Doğru olanı yapacağım, ne olursa olsun", "flag": "final_resolve_moral", "value": true},
					{"text": "Hayatta kalmak önemli", "flag": "final_resolve_survival", "value": true},
				]

	return base
