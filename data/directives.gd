class_name DirectivePool
extends RefCounted
## Pre-defined directive definitions for each day.

static func get_directive(directive_id: String) -> DirectiveData:
	var d: DirectiveData = DirectiveData.new()
	d.directive_id = directive_id

	match directive_id:
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
		_:
			d.directive_text = "Bilinmeyen direktif"

	return d

static func get_directives_for_day(day: int) -> Array[DirectiveData]:
	var config_directives: Array[String] = []

	match day:
		1: config_directives = ["min_experience_3"]
		2: config_directives = ["min_experience_3", "no_engineering"]
		3: config_directives = ["min_experience_3", "no_engineering", "disability_quota"]
		4: config_directives = ["min_experience_3", "must_hire_ahmet", "no_hiring"]
		5: config_directives = ["min_experience_3", "report_suspicious"]

	var result: Array[DirectiveData] = []
	for did: String in config_directives:
		result.append(get_directive(did))
	return result
