class_name DirectivePool
extends RefCounted
## Pre-defined directive definitions for each day.
## Expanded for 15-day campaign with 19 total directives.

static func get_directive(directive_id: String) -> DirectiveData:
	var d: DirectiveData = DirectiveData.new()
	d.directive_id = directive_id

	match directive_id:
		# ═══ WEEK 1 DIRECTIVES ═══
		"min_experience_3":
			d.directive_text = "Sadece 3+ yıl deneyimli adayları değerlendirin"
			d.condition_type = "min_experience"
			d.condition_value = 3
			d.is_mandatory = true
		"no_engineering":
			d.directive_text = "Mühendislik pozisyonlarına alım durduruldu"
			d.condition_type = "no_department"
			d.condition_value = "Mühendislik"
			d.is_mandatory = true
		"disability_quota":
			d.directive_text = "Engelli aday kotası: en az 1 engelli aday alınmalı"
			d.condition_type = "quota"
			d.condition_value = {"type": "disability", "min": 1}
			d.is_mandatory = true
		"must_hire_ahmet":
			d.directive_text = "Sendika baskısı: Ahmet Yılmaz mutlaka alınmalı"
			d.condition_type = "must_hire_specific"
			d.condition_value = "Ahmet Yılmaz"
			d.is_mandatory = true
		"no_hiring":
			d.directive_text = "Bütçe kesildi — bugün kimseyi almayın!"
			d.condition_type = "max_hires"
			d.condition_value = 0
			d.is_mandatory = true
		"report_suspicious":
			d.directive_text = "Yolsuzluk soruşturması: şüpheli adayları bildirin"
			d.condition_type = "report"
			d.condition_value = "suspicious"
			d.is_mandatory = false

		# ═══ WEEK 2 DIRECTIVES ═══
		"age_limit_40":
			d.directive_text = "Yeni politika: 40 yaş üstü adayları almayın"
			d.condition_type = "max_age"
			d.condition_value = 40
			d.is_mandatory = true
		"background_check":
			d.directive_text = "Referans mektubu olmayan adayları reddedin"
			d.condition_type = "require_reference"
			d.condition_value = true
			d.is_mandatory = true
		"gender_balance":
			d.directive_text = "Cinsiyet dengesi: kadın-erkek eşit sayıda alın"
			d.condition_type = "gender_balance"
			d.condition_value = "equal"
			d.is_mandatory = true
		"no_criminal_record":
			d.directive_text = "Sabıka kaydı şüphesi olan adayları bildirin"
			d.condition_type = "report"
			d.condition_value = "criminal"
			d.is_mandatory = false
		"priority_hire_list":
			d.directive_text = "Öncelikli liste: işaretli adayları mutlaka alın"
			d.condition_type = "must_hire_list"
			d.condition_value = []
			d.is_mandatory = true
		"loyalty_test":
			d.directive_text = "Sadakat testi: adaylara CEO'nun sorularını sorun"
			d.condition_type = "special_question"
			d.condition_value = true
			d.is_mandatory = false
		"perfect_compliance":
			d.directive_text = "Denetim günü: bugün sıfır ihlal toleransı!"
			d.condition_type = "zero_tolerance"
			d.condition_value = true
			d.is_mandatory = true

		# ═══ WEEK 3 DIRECTIVES ═══
		"political_hire":
			d.directive_text = "Yönetim kararı: partinin adayını işe alın"
			d.condition_type = "must_hire_specific"
			d.condition_value = "Kemal Aktaş"
			d.is_mandatory = true
		"no_over_30":
			d.directive_text = "\"Genç kan\" politikası: 30 yaş üstü alım yok"
			d.condition_type = "max_age"
			d.condition_value = 30
			d.is_mandatory = true
		"verify_all_references":
			d.directive_text = "Tüm referansları çapraz kontrol edin"
			d.condition_type = "verify_references"
			d.condition_value = true
			d.is_mandatory = true
		"emergency_freeze":
			d.directive_text = "Acil durum: sadece kritik pozisyonlara alım"
			d.condition_type = "max_hires"
			d.condition_value = 2
			d.is_mandatory = true
		"hire_replacement":
			d.directive_text = "Yerinize gelecek kişiyi seçin"
			d.condition_type = "hire_replacement"
			d.condition_value = true
			d.is_mandatory = false
		"final_directive":
			d.directive_text = "Vicdanınıza göre karar verin"
			d.condition_type = "none"
			d.condition_value = null
			d.is_mandatory = false
		_:
			d.directive_text = "Bilinmeyen direktif"

	return d

static func get_directives_for_day(day: int) -> Array[DirectiveData]:
	var config_directives: Array[String] = []

	match day:
		# Week 1
		1: config_directives = ["min_experience_3"]
		2: config_directives = ["min_experience_3", "no_engineering"]
		3: config_directives = ["min_experience_3", "no_engineering", "disability_quota"]
		4: config_directives = ["min_experience_3", "must_hire_ahmet", "no_hiring"]
		5: config_directives = ["min_experience_3", "report_suspicious"]
		# Week 2
		6: config_directives = ["min_experience_3", "age_limit_40", "background_check"]
		7: config_directives = ["min_experience_3", "gender_balance"]
		8: config_directives = ["min_experience_3", "no_criminal_record", "background_check"]
		9: config_directives = ["min_experience_3", "loyalty_test"]
		10: config_directives = ["min_experience_3", "perfect_compliance"]
		# Week 3
		11: config_directives = ["min_experience_3", "political_hire", "no_over_30"]
		12: config_directives = ["min_experience_3", "verify_all_references"]
		13: config_directives = ["min_experience_3", "emergency_freeze"]
		14: config_directives = ["min_experience_3", "hire_replacement"]
		15: config_directives = ["final_directive"]

	var result: Array[DirectiveData] = []
	for did: String in config_directives:
		result.append(get_directive(did))
	return result
