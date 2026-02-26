extends Node
## Central game state manager. Handles day progression, scoring, and candidate flow.
## Expanded for 15-day, 3-week campaign with moral tracking and 10 endings.

enum GameState { MENU, BRIEFING, DAY_ACTIVE, DAY_REVIEW, GAME_OVER }

var state: GameState = GameState.MENU
var current_day: int = 1
var max_days: int = 15

# Scoring
var violations: int = 0
var max_violations: int = 5
var money: int = 0
var career_points: int = 0

# Stress system
var stress: float = 0.0

# Per-day tracking
var candidates_today: Array = []
var current_candidate_index: int = -1
var day_decisions: Array = []  # Array of {candidate, hired, correct}
var day_time_remaining: float = 0.0
var day_duration: float = 180.0
var hired_today: int = 0

# Event flags for endings
var flags: Dictionary = {}

# Recurring character state across days
var recurring_characters: Dictionary = {}

# Day configs
var day_configs: Array = []

func _ready() -> void:
	_init_day_configs()

func _init_day_configs() -> void:
	day_configs = [
		# ═══════════ WEEK 1: ORIENTATION ═══════════
		{
			"day": 1,
			"title": "Pazartesi — 1. Gün",
			"headline": "ŞİRKET YENİ ÇALIŞAN ARIYOR",
			"num_candidates": 3,
			"duration": 240.0,
			"directives": ["min_experience_3"],
			"events": ["office_tour"],
			"inconsistency_ratio": 0.15,
			"max_hires": 99,
			"phone_calls": [],
		},
		{
			"day": 2,
			"title": "Salı — 2. Gün",
			"headline": "MÜHENDİSLİK SEKTÖRÜNDE KRİZ",
			"num_candidates": 4,
			"duration": 210.0,
			"directives": ["min_experience_3", "no_engineering"],
			"events": ["complaint_letter"],
			"inconsistency_ratio": 0.25,
			"max_hires": 2,
			"phone_calls": [],
		},
		{
			"day": 3,
			"title": "Çarşamba — 3. Gün",
			"headline": "CEO'NUN AİLESİ GÜNDEMDE",
			"num_candidates": 5,
			"duration": 195.0,
			"directives": ["min_experience_3", "no_engineering", "disability_quota"],
			"events": ["ceo_nephew"],
			"inconsistency_ratio": 0.30,
			"max_hires": 99,
			"phone_calls": [
				{"time_trigger": 120.0, "caller": "ceo", "text": "Yeğenim oraya gelecek. Lütfen onu iyi karşılayın.", "flag": ""},
			],
		},
		{
			"day": 4,
			"title": "Perşembe — 4. Gün",
			"headline": "SENDİKA GREVİ TEHDİDİ",
			"num_candidates": 5,
			"duration": 180.0,
			"directives": ["min_experience_3", "must_hire_ahmet", "no_hiring"],
			"events": ["union_pressure", "whistleblower"],
			"inconsistency_ratio": 0.35,
			"max_hires": 0,
			"phone_calls": [
				{"time_trigger": 140.0, "caller": "sendika", "text": "Ahmet Yılmaz'ı işe alın, yoksa grev başlatırız.", "flag": ""},
			],
		},
		{
			"day": 5,
			"title": "Cuma — 5. Gün",
			"headline": "DENETİM HABERLERİ YAYILIYOR",
			"num_candidates": 6,
			"duration": 150.0,
			"directives": ["min_experience_3", "report_suspicious"],
			"events": ["internal_audit_warning"],
			"inconsistency_ratio": 0.40,
			"max_hires": 99,
			"phone_calls": [],
		},
		# ═══════════ WEEK 2: PRESSURE ═══════════
		{
			"day": 6,
			"title": "Pazartesi — 6. Gün",
			"headline": "YENİ İK POLİTİKASI AÇIKLANDI",
			"num_candidates": 5,
			"duration": 210.0,
			"directives": ["min_experience_3", "age_limit_40", "background_check"],
			"events": ["new_hr_policy"],
			"inconsistency_ratio": 0.30,
			"max_hires": 99,
			"phone_calls": [
				{"time_trigger": 150.0, "caller": "müdür", "text": "Yeni politika hakkında sorularınız varsa bana gelin. Ama uygulayın.", "flag": ""},
			],
		},
		{
			"day": 7,
			"title": "Salı — 7. Gün",
			"headline": "ESKİ ADAYLAR GERİ DÖNÜYOR",
			"num_candidates": 6,
			"duration": 195.0,
			"directives": ["min_experience_3", "gender_balance"],
			"events": ["returning_candidate", "anonymous_tip"],
			"inconsistency_ratio": 0.35,
			"max_hires": 99,
			"phone_calls": [],
		},
		{
			"day": 8,
			"title": "Çarşamba — 8. Gün",
			"headline": "BASIN ŞİRKETİ İNCELİYOR",
			"num_candidates": 6,
			"duration": 180.0,
			"directives": ["min_experience_3", "no_criminal_record", "background_check"],
			"events": ["journalist_visit"],
			"inconsistency_ratio": 0.40,
			"max_hires": 99,
			"phone_calls": [
				{"time_trigger": 100.0, "caller": "güvenlik", "text": "Bugün bir gazeteci binaya girmiş. Dikkatli olun.", "flag": ""},
			],
		},
		{
			"day": 9,
			"title": "Perşembe — 9. Gün",
			"headline": "CEO GİZLİ TOPLANTI ÇAĞIRDI",
			"num_candidates": 7,
			"duration": 165.0,
			"directives": ["min_experience_3", "loyalty_test"],
			"events": ["secret_meeting", "double_agent"],
			"inconsistency_ratio": 0.45,
			"max_hires": 99,
			"phone_calls": [
				{"time_trigger": 130.0, "caller": "ceo", "text": "Toplantıdan sonra bana rapor ver. Kimin güvenilir olduğunu bilmem lazım.", "flag": ""},
			],
		},
		{
			"day": 10,
			"title": "Cuma — 10. Gün",
			"headline": "DENETİM RAPORU HAZIRLANIYOR",
			"num_candidates": 7,
			"duration": 150.0,
			"directives": ["min_experience_3", "perfect_compliance"],
			"events": ["audit_review", "week2_choice"],
			"inconsistency_ratio": 0.50,
			"max_hires": 99,
			"phone_calls": [
				{"time_trigger": 120.0, "caller": "denetçi", "text": "Kayıtlarınızı inceliyorum. Herhangi bir düzensizlik var mı?", "flag": ""},
			],
		},
		# ═══════════ WEEK 3: RECKONING ═══════════
		{
			"day": 11,
			"title": "Pazartesi — 11. Gün",
			"headline": "YÖNETİM DEĞİŞTİ!",
			"num_candidates": 6,
			"duration": 180.0,
			"directives": ["min_experience_3", "political_hire", "no_over_30"],
			"events": ["regime_change"],
			"inconsistency_ratio": 0.40,
			"max_hires": 99,
			"phone_calls": [
				{"time_trigger": 140.0, "caller": "yeni_ceo", "text": "Ben yeni CEO'yum. Eski düzen bitti. Benim kurallarıma uyacaksınız.", "flag": ""},
			],
		},
		{
			"day": 12,
			"title": "Salı — 12. Gün",
			"headline": "HAYALET ÇALIŞANLAR ORTAYA ÇIKTI",
			"num_candidates": 7,
			"duration": 165.0,
			"directives": ["min_experience_3", "verify_all_references"],
			"events": ["ghost_employees", "informant_return"],
			"inconsistency_ratio": 0.45,
			"max_hires": 99,
			"phone_calls": [],
		},
		{
			"day": 13,
			"title": "Çarşamba — 13. Gün",
			"headline": "SAVCILIK SORUŞTURMASI",
			"num_candidates": 7,
			"duration": 150.0,
			"directives": ["min_experience_3", "emergency_freeze"],
			"events": ["prosecutor_visit", "evidence_choice"],
			"inconsistency_ratio": 0.50,
			"max_hires": 2,
			"phone_calls": [
				{"time_trigger": 100.0, "caller": "savcı", "text": "İşe alım kayıtlarınıza ihtiyacımız var. Tam işbirliği bekliyoruz.", "flag": ""},
			],
		},
		{
			"day": 14,
			"title": "Perşembe — 14. Gün",
			"headline": "SON MÜLAKATLAR YAKLAŞIYOR",
			"num_candidates": 8,
			"duration": 135.0,
			"directives": ["min_experience_3", "hire_replacement"],
			"events": ["confrontation", "ally_or_enemy"],
			"inconsistency_ratio": 0.55,
			"max_hires": 99,
			"phone_calls": [
				{"time_trigger": 90.0, "caller": "müdür", "text": "Yerinize birini seçmeniz gerekiyor. Son kararınızı bugün verin.", "flag": ""},
			],
		},
		{
			"day": 15,
			"title": "Cuma — 15. Gün",
			"headline": "VEDA GÜNÜ",
			"num_candidates": 8,
			"duration": 120.0,
			"directives": ["final_directive"],
			"events": ["final_choice_expanded"],
			"inconsistency_ratio": 0.60,
			"max_hires": 99,
			"phone_calls": [],
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
	stress = 0.0
	flags = {}
	recurring_characters = {}
	hired_today = 0

func start_day() -> void:
	state = GameState.DAY_ACTIVE
	var config: Dictionary = get_day_config()
	day_time_remaining = config.get("duration", 180.0)
	day_duration = day_time_remaining
	current_candidate_index = -1
	day_decisions = []
	hired_today = 0
	# Slight stress recovery between days
	stress = maxf(0.0, stress - 0.05)
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

func add_stress(amount: float) -> void:
	stress = clampf(stress + amount, 0.0, 1.0)

func compute_moral_score() -> int:
	var ms: int = 0
	# Positive actions
	if has_flag("rejected_nepotism"): ms += 2
	if has_flag("supported_union"): ms += 1
	if has_flag("listened_whistleblower"): ms += 2
	if has_flag("reported_fraud"): ms += 3
	if has_flag("resisted_ageism"): ms += 2
	if has_flag("cooperated_prosecutor"): ms += 2
	if has_flag("gave_evidence"): ms += 3
	if has_flag("flagged_ghost"): ms += 1
	if has_flag("told_auditor_truth"): ms += 2
	if has_flag("curious_about_past"): ms += 1
	if has_flag("investigated_tip"): ms += 1
	if has_flag("reported_spy_to_law"): ms += 1
	if has_flag("pledged_integrity"): ms += 1
	# Negative actions
	if has_flag("accepted_nepotism"): ms -= 2
	if has_flag("ignored_fraud"): ms -= 3
	if has_flag("compliant_ageism"): ms -= 2
	if has_flag("lied_to_auditor"): ms -= 2
	if has_flag("destroyed_evidence"): ms -= 3
	if has_flag("ignored_ghost"): ms -= 1
	if has_flag("pledged_loyalty"): ms -= 1
	if has_flag("ignored_tip"): ms -= 1
	if has_flag("reported_spy_to_ceo"): ms -= 1
	return ms

func get_ending() -> Dictionary:
	var ms: int = compute_moral_score()

	# FIRED — always takes priority
	if violations >= max_violations:
		return {
			"id": "fired",
			"title": "KOVULDUNUZ",
			"text": "Çok fazla ihlal yaptınız. Masanız toplandı, kimlik kartınız iptal edildi.\n\nGüvenlik sizi kapıya kadar eşlik ediyor.\n\n\"Bir daha bu binaya adımınızı atmayın.\"\n\nİK departmanı sizi hiç tanımadı.",
		}

	# HERO — highest moral path with concrete evidence
	if ms >= 12 and has_flag("cooperated_prosecutor") and has_flag("gave_evidence"):
		return {
			"id": "hero",
			"title": "KAHRAMAN",
			"text": "Dava ulusal haber oldu. Tanıklığınız yönetim kurulunu devirdi.\n\nSize bir madalya teklif ettiler. \"Ben sadece işimi yaptım\" dediniz.\n\nGazeteler sizi aylarca yazdı. Yeni İK yasası sizin adınızla anılıyor.\n\nBazen bir kişi fark yaratır.",
		}

	# VANISHED — extreme corruption, system erases you
	if ms <= -8:
		return {
			"id": "vanished",
			"title": "KAYIP",
			"text": "Bir pazartesi sabahı masanız boştu. İstifa mektubu yok. Yönlendirme adresi yok.\n\nİK kayıtlarında adınız silinmiş.\n\nSistem sizi sildi. Tıpkı sizin o dosyaları sildiğiniz gibi.\n\nHiç var oldunuz mu?",
		}

	# DOUBLE AGENT — contradictory loyalties
	if has_flag("pledged_loyalty") and has_flag("cooperated_prosecutor"):
		return {
			"id": "double_agent",
			"title": "ÇİFTE AJAN",
			"text": "İki tarafı da oynadınız. İki taraf da biliyor.\n\nCEO sizi bir toplantıda görmezden geldi. Savcı dosyanızı \"güvenilmez\" olarak işaretledi.\n\nGüven harcadığınız bir para birimi. Ve bakiyeniz sıfır.\n\nKimse sizi aramamaya başladı.",
		}

	# REFORMER — high moral, low violations, resisted injustice
	if ms >= 8 and violations <= 2 and has_flag("resisted_ageism"):
		return {
			"id": "reformer",
			"title": "REFORMCU",
			"text": "Yeni yönetim kurulu sizden şirketin etik şartını yazmanızı istedi.\n\nİronik — ya da tam da doğru kişi.\n\nKuralları değiştirmek için önce kurallara karşı durmanız gerekiyordu.\n\nArtık kalem sizin elinizde.",
		}

	# EXILE — told truth but had no evidence
	if has_flag("told_auditor_truth") and not has_flag("gave_evidence"):
		return {
			"id": "exile",
			"title": "SÜRGÜN",
			"text": "Kimse size inanmadı. Elinizde kanıt yoktu.\n\nİK kariyeriniz bitti. Başka bir şirkette dosya arşivliyorsunuz.\n\nKimsenin okumadığı kağıtları dosyalıyorsunuz.\n\nDoğruyu söylediniz. Ama doğru yetmedi.",
		}

	# WHISTLEBLOWER — reported fraud with union support
	if ms >= 6 and has_flag("reported_fraud"):
		return {
			"id": "whistleblower",
			"title": "MUHBİR",
			"text": "Yolsuzluğu ifşa ettiniz. Şirket soruşturma altında.\n\nİşinizi kaybettiniz ama vicdanınız rahat.\n\nGazeteler sizi \"cesur İK'cı\" olarak anıyor.\n\nBazen doğru olanı yapmak her şeye mal olur.",
		}

	# CORRUPT — embraced the system's darkness
	if ms <= -4 and has_flag("accepted_nepotism"):
		return {
			"id": "corrupt",
			"title": "YOLSUZLUK",
			"text": "Sisteme ayak uydurdunuz. CEO sizi seviyor.\n\nMaaşınız arttı, köşe ofis sizin.\n\nAma her sabah aynaya bakmak biraz daha zor.\n\n\"Herkes yapıyor\" diyorsunuz kendinize. Herkes yapıyor.",
		}

	# PROMOTED — clean record, good performance
	if violations <= 2 and career_points >= 200:
		return {
			"id": "promoted",
			"title": "TERFİ",
			"text": "Üç hafta boyunca kusursuz çalıştınız. Sıfıra yakın hata, maksimum verim.\n\nİK Direktörü olarak terfi ettiniz.\n\nArtık kuralları siz koyuyorsunuz.\n\n...ya da öyle sanıyorsunuz.",
		}

	# NEUTRAL — the default bureaucratic existence
	return {
		"id": "neutral",
		"title": "SIRADAN BİR GÜN",
		"text": "Üç hafta daha bitti. Ne kahraman oldunuz ne de hain.\n\nMasanızda yarın da aynı dosyalar olacak.\n\nAynı yüzler, aynı yalanlar, aynı damgalar.\n\nMakine dönmeye devam ediyor.",
	}

func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value

func has_flag(key: String) -> bool:
	return flags.has(key)
