extends Node
## Central game state manager. Handles day progression, scoring, and candidate flow.

enum GameState { MENU, BRIEFING, DAY_ACTIVE, DAY_REVIEW, GAME_OVER }

var state: GameState = GameState.MENU
var current_day: int = 1
var max_days: int = 5

# Scoring
var violations: int = 0
var max_violations: int = 3
var money: int = 0
var career_points: int = 0

# Per-day tracking
var candidates_today: Array = []
var current_candidate_index: int = -1
var day_decisions: Array = []  # Array of {candidate, hired, correct}
var day_time_remaining: float = 0.0
var day_duration: float = 180.0
var hired_today: int = 0

# Event flags for endings
var flags: Dictionary = {}

# Day configs
var day_configs: Array = []

func _ready() -> void:
	_init_day_configs()

func _init_day_configs() -> void:
	day_configs = [
		{
			"day": 1,
			"title": "Pazartesi — 1. Gün",
			"headline": "ŞİRKET YENİ ÇALIŞAN ARIYOR",
			"num_candidates": 3,
			"duration": 240.0,
			"directives": ["min_experience_3"],
			"events": [],
			"inconsistency_ratio": 0.2,
			"max_hires": 99,
		},
		{
			"day": 2,
			"title": "Salı — 2. Gün",
			"headline": "MÜHENDİSLİK SEKTÖRÜNDE KRİZ",
			"num_candidates": 4,
			"duration": 210.0,
			"directives": ["min_experience_3", "no_engineering"],
			"events": ["complaint_letter"],
			"inconsistency_ratio": 0.3,
			"max_hires": 2,
		},
		{
			"day": 3,
			"title": "Çarşamba — 3. Gün",
			"headline": "CEO'NUN AİLESİ GÜNDEMDE",
			"num_candidates": 5,
			"duration": 195.0,
			"directives": ["min_experience_3", "no_engineering", "disability_quota"],
			"events": ["ceo_nephew"],
			"inconsistency_ratio": 0.35,
			"max_hires": 99,
		},
		{
			"day": 4,
			"title": "Perşembe — 4. Gün",
			"headline": "SENDİKA GREVİ TEHDİDİ",
			"num_candidates": 5,
			"duration": 180.0,
			"directives": ["min_experience_3", "must_hire_ahmet", "no_hiring"],
			"events": ["union_pressure", "whistleblower"],
			"inconsistency_ratio": 0.4,
			"max_hires": 0,
		},
		{
			"day": 5,
			"title": "Cuma — 5. Gün",
			"headline": "YOLSUZLUK SORUŞTURMASI BAŞLADI",
			"num_candidates": 6,
			"duration": 150.0,
			"directives": ["min_experience_3", "report_suspicious"],
			"events": ["final_choice"],
			"inconsistency_ratio": 0.5,
			"max_hires": 99,
		},
	]

func get_day_config() -> Dictionary:
	if current_day >= 1 and current_day <= day_configs.size():
		return day_configs[current_day - 1]
	return day_configs[0]

func start_new_game() -> void:
	state = GameState.BRIEFING
	current_day = 1
	violations = 0
	money = 0
	career_points = 0
	flags = {}
	hired_today = 0

func start_day() -> void:
	state = GameState.DAY_ACTIVE
	var config: Dictionary = get_day_config()
	day_time_remaining = config.get("duration", 180.0)
	day_duration = day_time_remaining
	current_candidate_index = -1
	day_decisions = []
	hired_today = 0
	EventBus.day_started.emit(current_day)

func get_current_candidate() -> Resource:
	if current_candidate_index >= 0 and current_candidate_index < candidates_today.size():
		return candidates_today[current_candidate_index]
	return null

func next_candidate() -> Resource:
	current_candidate_index += 1
	if current_candidate_index < candidates_today.size():
		var candidate: Resource = candidates_today[current_candidate_index]
		EventBus.candidate_arrived.emit(candidate)
		return candidate
	return null

func record_decision(hired: bool) -> Dictionary:
	var candidate: Resource = get_current_candidate()
	if candidate == null:
		return {}

	var correct: bool
	var config: Dictionary = get_day_config()
	var max_h: int = config.get("max_hires", 99)

	if hired and hired_today >= max_h:
		correct = false
	else:
		correct = (hired == candidate.is_valid_hire)

	var violation: bool = not correct
	var reason: String = ""

	if violation:
		violations += 1
		money -= 200
		if hired and not candidate.is_valid_hire:
			reason = "Uygun olmayan aday işe alındı"
		elif not hired and candidate.is_valid_hire:
			reason = "Uygun aday reddedildi"
		if hired and hired_today >= max_h:
			reason = "Alım limiti aşıldı"
		EventBus.violation_received.emit(reason)
	else:
		money += 500
		career_points += 10
		EventBus.money_changed.emit(money)

	if hired:
		hired_today += 1

	var result: Dictionary = {
		"candidate": candidate,
		"hired": hired,
		"correct": correct,
		"violation": violation,
		"reason": reason,
	}
	day_decisions.append(result)
	EventBus.decision_made.emit(candidate, hired)
	return result

func end_day() -> Dictionary:
	state = GameState.DAY_REVIEW

	# Auto-reject remaining candidates
	var auto_rejected: int = 0
	var auto_violations: int = 0
	for i in range(current_candidate_index + 1, candidates_today.size()):
		var c: Resource = candidates_today[i]
		if c.is_valid_hire:
			auto_violations += 1
			violations += 1
		auto_rejected += 1
		day_decisions.append({
			"candidate": c,
			"hired": false,
			"correct": not c.is_valid_hire,
			"violation": c.is_valid_hire,
			"reason": "Zaman doldu — otomatik red" if c.is_valid_hire else "",
		})

	# Base salary
	money += 100

	EventBus.day_ended.emit(current_day)

	var summary: Dictionary = {
		"day": current_day,
		"total_candidates": candidates_today.size(),
		"reviewed": current_candidate_index + 1,
		"auto_rejected": auto_rejected,
		"decisions": day_decisions,
		"violations_today": day_decisions.filter(func(d: Dictionary) -> bool: return d.get("violation", false)).size(),
		"total_violations": violations,
		"money": money,
		"career_points": career_points,
	}
	return summary

func advance_day() -> void:
	if violations >= max_violations:
		state = GameState.GAME_OVER
		return
	current_day += 1
	if current_day > max_days:
		state = GameState.GAME_OVER
		return
	state = GameState.BRIEFING

func get_ending() -> Dictionary:
	# Check endings in priority order
	if violations >= max_violations:
		return {
			"id": "fired",
			"title": "KOVULDUNUZ",
			"text": "Çok fazla ihlal yaptınız. Masanız toplandı, kimlik kartınız iptal edildi.\n\nGüvenlik sizi kapıya kadar eşlik ediyor.\n\n\"Bir daha bu binaya adımınızı atmayın.\"\n\nİK departmanı sizi hiç tanımadı.",
		}

	if flags.get("reported_fraud", false) and flags.get("supported_union", false):
		return {
			"id": "whistleblower",
			"title": "MUHBİR",
			"text": "Yolsuzluğu ifşa ettiniz. Şirket soruşturma altında.\n\nİşinizi kaybettiniz ama vicdanınız rahat.\n\nGazeteler sizi \"cesur İK'cı\" olarak anıyor.\n\nBazen doğru olanı yapmak her şeye mal olur.",
		}

	if flags.get("accepted_nepotism", false) and flags.get("ignored_fraud", false):
		return {
			"id": "corrupt",
			"title": "YOLSUZLUK",
			"text": "Sisteme ayak uydurdunuz. CEO sizi seviyor.\n\nMaaşınız arttı, köşe ofis sizin.\n\nAma her sabah aynaya bakmak biraz daha zor.\n\n\"Herkes yapıyor\" diyorsunuz kendinize. Herkes yapıyor.",
		}

	if violations <= 1 and career_points >= 100:
		return {
			"id": "promoted",
			"title": "TERFİ",
			"text": "Mükemmel bir hafta geçirdiniz. Sıfır hata, maksimum verim.\n\nİK Direktörü olarak terfi ettiniz.\n\nArtık kuralları siz koyuyorsunuz.\n\n...ya da öyle sanıyorsunuz.",
		}

	return {
		"id": "neutral",
		"title": "SIRADAN BİR GÜN",
		"text": "Bir hafta daha bitti. Ne kahraman oldunuz ne de hain.\n\nMasanızda yarın da aynı dosyalar olacak.\n\nAynı yüzler, aynı yalanlar, aynı damgalar.\n\nMakine dönmeye devam ediyor.",
	}

func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value

func has_flag(key: String) -> bool:
	return flags.has(key)
