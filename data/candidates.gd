class_name CandidatePool
extends RefCounted
## Procedural candidate generation with Turkish name pools and controlled inconsistencies.

const MALE_NAMES: Array[String] = [
	"Ahmet", "Mehmet", "Mustafa", "Ali", "Hüseyin", "Hasan", "İbrahim", "Emre",
	"Burak", "Can", "Cem", "Deniz", "Efe", "Fatih", "Gökhan", "Halil", "İsmail",
	"Kadir", "Kemal", "Levent", "Murat", "Oğuz", "Onur", "Ömer", "Serkan",
	"Sinan", "Tarık", "Tolga", "Uğur", "Volkan", "Yusuf", "Zafer", "Barış",
	"Cenk", "Doğan", "Erdem", "Ferhat", "Gürkan", "Harun", "Kaan", "Orhan",
	"Selim", "Taner", "Ufuk", "Vedat", "Yavuz", "Berk", "Cihan", "Erkan",
]

const FEMALE_NAMES: Array[String] = [
	"Ayşe", "Fatma", "Emine", "Zeynep", "Elif", "Merve", "Büşra", "Esra",
	"Seda", "Derya", "Gamze", "Hande", "İrem", "Kübra", "Melis", "Nurgül",
	"Özge", "Pınar", "Sevgi", "Şeyma", "Tuğba", "Yasemin", "Zehra", "Aslı",
	"Başak", "Ceren", "Didem", "Ebru", "Gül", "Sibel", "Burcu", "Cansu",
	"Defne", "Ece", "Fulya", "Gizem", "Hilal", "Işıl", "Jale", "Lale",
	"Meltem", "Nihan", "Oya", "Rengin", "Selin", "Tuba", "Yeliz", "Zülal",
]

const SURNAMES: Array[String] = [
	"Yılmaz", "Kaya", "Demir", "Çelik", "Şahin", "Yıldız", "Yıldırım",
	"Öztürk", "Aydın", "Özdemir", "Arslan", "Doğan", "Kılıç", "Aslan",
	"Çetin", "Koç", "Kurt", "Özkan", "Şimşek", "Polat", "Erdoğan", "Aktaş",
	"Güneş", "Korkmaz", "Ünal", "Aksoy", "Acar", "Bulut", "Kaplan", "Tekin",
	"Balcı", "Bayrak", "Candan", "Duman", "Elmas", "Fırat", "Gündüz",
	"Işık", "Karaca", "Mutlu", "Sezer", "Taşkın", "Tunç", "Uysal", "Varol",
]

const UNIVERSITIES: Array[String] = [
	"İstanbul Teknik Üniversitesi", "Boğaziçi Üniversitesi",
	"Orta Doğu Teknik Üniversitesi", "Hacettepe Üniversitesi",
	"Ankara Üniversitesi", "Ege Üniversitesi", "Dokuz Eylül Üniversitesi",
	"Marmara Üniversitesi", "Gazi Üniversitesi", "Yıldız Teknik Üniversitesi",
	"Sakarya Üniversitesi", "Atatürk Üniversitesi", "Anadolu Üniversitesi",
	"Erciyes Üniversitesi", "Karadeniz Teknik Üniversitesi",
	"Fırat Üniversitesi",
]

const FAKE_UNIVERSITIES: Array[String] = [
	"Güneydoğu Bilim Üniversitesi", "Avrasya Teknik Üniversitesi",
	"Marmara Bilişim Üniversitesi",
]

const DEPARTMENTS: Array[String] = [
	"Bilgisayar Mühendisliği", "Elektrik-Elektronik Mühendisliği",
	"Makine Mühendisliği", "İşletme", "İktisat", "Hukuk", "Mimarlık",
	"İnşaat Mühendisliği", "Endüstri Mühendisliği", "Psikoloji",
	"İletişim", "Pazarlama", "Muhasebe ve Finansman",
]

const ENGINEERING_DEPARTMENTS: Array[String] = [
	"Bilgisayar Mühendisliği", "Elektrik-Elektronik Mühendisliği",
	"Makine Mühendisliği", "İnşaat Mühendisliği", "Endüstri Mühendisliği",
]

const POSITIONS: Array[String] = [
	"Yazılım Mühendisi", "Muhasebeci", "Pazarlama Uzmanı",
	"İK Asistanı", "Satış Temsilcisi", "Proje Yöneticisi",
	"Veri Analisti", "Grafik Tasarımcı", "İdari Asistan",
]

const COMPANIES: Array[String] = [
	"Koç Holding", "Sabancı Holding", "Türk Telekom", "Garanti BBVA",
	"İş Bankası", "Arçelik", "Tüpraş", "Eczacıbaşı", "Turkcell",
	"Vestel", "Pegasus", "Doğuş Grubu", "Tekfen", "Aselsan",
	"THY", "Enerjisa", "Ford Otosan", "TAV", "Migros", "Getir",
]

const SKILLS: Array[String] = [
	"Python", "Java", "Excel", "SAP", "AutoCAD", "Photoshop",
	"İngilizce (C1)", "Almanca (B2)", "Proje Yönetimi", "Sunum",
	"Veri Analizi", "Liderlik", "İletişim", "SQL", "PowerPoint",
]

const CITIES: Array[String] = [
	"İstanbul", "Ankara", "İzmir", "Bursa", "Antalya", "Adana",
	"Konya", "Gaziantep", "Mersin", "Kayseri", "Eskişehir", "Trabzon",
	"Samsun", "Denizli", "Diyarbakır", "Malatya",
]

const GREETINGS: Array[String] = [
	"Merhaba, iş başvurusu için geldim.",
	"İyi günler, mülakat için buradayım.",
	"Selam, başvurumu yaptım, çağrıldım.",
	"Merhaba, ilanınızı gördüm ve başvurdum.",
	"İyi günler, sizinle görüşmek istiyordum.",
	"Hoş buldum, başvurum için geldim.",
]

const HIRED_REACTIONS: Array[String] = [
	"Çok teşekkür ederim! Ne zaman başlıyorum?",
	"Harika! Çok mutluyum, teşekkürler!",
	"Gerçekten mi? Çok sevindim!",
	"Teşekkürler, elimden gelenin en iyisini yapacağım.",
	"Müthiş! Sabırsızlanıyorum başlamak için.",
]

const REJECTED_REACTIONS: Array[String] = [
	"Anlıyorum... Teşekkürler yine de.",
	"Peki... Başka bir fırsat olur belki.",
	"Ama neden? Bence çok uygunum!",
	"Hayal kırıklığı... Neyse, iyi günler.",
	"Tamam... Başka kapılar da var.",
]

static func generate_tc_kimlik(valid: bool = true) -> String:
	var digits: Array[int] = []
	digits.append(randi_range(1, 9))  # First digit nonzero
	for i in range(8):
		digits.append(randi_range(0, 9))

	var odd_sum: int = digits[0] + digits[2] + digits[4] + digits[6] + digits[8]
	var even_sum: int = digits[1] + digits[3] + digits[5] + digits[7]
	var d10: int = (odd_sum * 7 - even_sum) % 10
	if d10 < 0:
		d10 += 10
	digits.append(d10)

	var total: int = 0
	for d: int in digits:
		total += d
	digits.append(total % 10)

	if not valid:
		# Corrupt the last digit
		digits[10] = (digits[10] + randi_range(1, 9)) % 10

	var result: String = ""
	for d: int in digits:
		result += str(d)
	return result

static func generate_candidate(seed_val: int, day: int) -> CandidateData:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_val

	var c: CandidateData = CandidateData.new()
	c.photo_seed = seed_val

	# Gender
	c.gender = "K" if rng.randi() % 2 == 0 else "E"

	# Name
	var first: String
	if c.gender == "E":
		first = MALE_NAMES[rng.randi() % MALE_NAMES.size()]
	else:
		first = FEMALE_NAMES[rng.randi() % FEMALE_NAMES.size()]
	var last: String = SURNAMES[rng.randi() % SURNAMES.size()]
	c.candidate_name = first + " " + last

	# Age and education
	c.age = rng.randi_range(22, 50)
	c.university = UNIVERSITIES[rng.randi() % UNIVERSITIES.size()]
	c.department = DEPARTMENTS[rng.randi() % DEPARTMENTS.size()]
	c.graduation_year = 2026 - c.age + rng.randi_range(21, 24)
	if c.graduation_year > 2025:
		c.graduation_year = 2025
	c.gpa = snapped(rng.randf_range(2.0, 4.0), 0.01)

	# Experience
	var max_exp: int = 2026 - c.graduation_year
	if max_exp < 0:
		max_exp = 0
	c.experience_years = rng.randi_range(0, max_exp)
	c.position_applied = POSITIONS[rng.randi() % POSITIONS.size()]

	# Previous companies
	var num_companies: int = rng.randi_range(1, mini(3, c.experience_years + 1))
	for i in range(num_companies):
		c.previous_companies.append(COMPANIES[rng.randi() % COMPANIES.size()])

	# Skills
	var num_skills: int = rng.randi_range(2, 5)
	var used_skills: Array[String] = []
	for i in range(num_skills):
		var s: String = SKILLS[rng.randi() % SKILLS.size()]
		if s not in used_skills:
			used_skills.append(s)
	c.skills = used_skills

	# City
	c.city = CITIES[rng.randi() % CITIES.size()]

	# TC Kimlik
	c.tc_kimlik_no = generate_tc_kimlik(true)

	# Reference
	c.has_reference = rng.randi() % 4 != 0  # 75% chance
	if c.has_reference:
		var ref_first: String = MALE_NAMES[rng.randi() % MALE_NAMES.size()] if rng.randi() % 2 == 0 else FEMALE_NAMES[rng.randi() % FEMALE_NAMES.size()]
		c.reference_author = ref_first + " " + SURNAMES[rng.randi() % SURNAMES.size()]
		c.reference_company = COMPANIES[rng.randi() % COMPANIES.size()]
		c.reference_quality = ["excellent", "good", "good", "suspicious"][rng.randi() % 4]

	# Dialogue
	c.greeting = GREETINGS[rng.randi() % GREETINGS.size()]
	c.reaction_hired = HIRED_REACTIONS[rng.randi() % HIRED_REACTIONS.size()]
	c.reaction_rejected = REJECTED_REACTIONS[rng.randi() % REJECTED_REACTIONS.size()]

	# Interview lines
	c.interview_lines = [
		str(c.experience_years) + " yıldır bu alanda çalışıyorum.",
		c.university + " mezunuyum.",
		c.position_applied + " pozisyonuna başvurdum.",
	]

	# Generate documents
	_generate_documents(c)

	return c

static func _generate_documents(c: CandidateData) -> void:
	# CV
	var cv: DocumentData = DocumentData.new()
	cv.doc_type = "cv"
	cv.content = {
		"Ad Soyad": c.candidate_name,
		"Yaş": str(c.age),
		"Şehir": c.city,
		"Pozisyon": c.position_applied,
		"Deneyim": str(c.experience_years) + " yıl",
		"Üniversite": c.university,
		"Bölüm": c.department,
		"Mezuniyet": str(c.graduation_year),
		"Beceriler": ", ".join(c.skills),
		"Önceki Şirketler": ", ".join(c.previous_companies),
	}
	c.documents.append(cv)

	# Diploma
	var diploma: DocumentData = DocumentData.new()
	diploma.doc_type = "diploma"
	diploma.content = {
		"Öğrenci Adı": c.candidate_name,
		"Üniversite": c.university,
		"Bölüm": c.department,
		"Mezuniyet Yılı": str(c.graduation_year),
		"Not Ortalaması": str(c.gpa),
	}
	c.documents.append(diploma)

	# Reference
	if c.has_reference:
		var ref: DocumentData = DocumentData.new()
		ref.doc_type = "reference"
		var quality_text: String
		match c.reference_quality:
			"excellent":
				quality_text = c.candidate_name + " son derece başarılı ve güvenilir bir çalışandır. Kendisini en yüksek tavsiyemle öneriyorum."
			"good":
				quality_text = c.candidate_name + " iyi bir çalışandır. Görevlerini zamanında ve düzgün bir şekilde yerine getirmiştir."
			"suspicious":
				quality_text = c.candidate_name + " şirketimizde çalışmıştır. Performansı hakkında detaylı bilgi veremiyorum."
			_:
				quality_text = c.candidate_name + " hakkında olumlu şeyler söyleyebilirim."
		ref.content = {
			"Aday": c.candidate_name,
			"Referans Veren": c.reference_author,
			"Şirket": c.reference_company,
			"Değerlendirme": quality_text,
		}
		c.documents.append(ref)

	# ID Card
	var id_card: DocumentData = DocumentData.new()
	id_card.doc_type = "id_card"
	id_card.content = {
		"TC Kimlik No": c.tc_kimlik_no,
		"Ad Soyad": c.candidate_name,
		"Doğum Yılı": str(2026 - c.age),
		"Cinsiyet": c.gender,
		"İl": c.city,
	}
	c.documents.append(id_card)

static func inject_inconsistency(c: CandidateData, inc_type: String) -> void:
	match inc_type:
		"name_mismatch":
			# Change name on diploma
			if c.documents.size() > 1:
				var alt_surname: String = SURNAMES[randi() % SURNAMES.size()]
				var original: String = c.candidate_name
				var parts: PackedStringArray = original.split(" ")
				if parts.size() >= 2:
					var fake_name: String = parts[0] + " " + alt_surname
					c.documents[1].content["Öğrenci Adı"] = fake_name
					c.documents[1].has_inconsistency = true
					c.documents[1].inconsistency_type = "name_mismatch"
					c.documents[1].inconsistency_detail = "Diplomadaki isim ÖZgeçmiştekiyle uyuşmuyor"
					c.inconsistencies.append("İsim uyuşmazlığı: CV'de " + original + ", Diplomada " + fake_name)

		"date_mismatch":
			# Graduation year different on CV vs diploma
			if c.documents.size() > 1:
				var fake_year: int = c.graduation_year + [-2, -1, 1, 2][randi() % 4]
				c.documents[0].content["Mezuniyet"] = str(fake_year)
				c.documents[0].has_inconsistency = true
				c.documents[0].inconsistency_type = "date_mismatch"
				c.documents[0].inconsistency_detail = "Mezuniyet yılı belgeler arasında farklı"
				c.inconsistencies.append("Tarih uyuşmazlığı: CV'de " + str(fake_year) + ", Diplomada " + str(c.graduation_year))

		"university_mismatch":
			# Different university on CV vs diploma
			if c.documents.size() > 1:
				var alt_uni: String = UNIVERSITIES[randi() % UNIVERSITIES.size()]
				while alt_uni == c.university:
					alt_uni = UNIVERSITIES[randi() % UNIVERSITIES.size()]
				c.documents[0].content["Üniversite"] = alt_uni
				c.documents[0].has_inconsistency = true
				c.documents[0].inconsistency_type = "university_mismatch"
				c.documents[0].inconsistency_detail = "Üniversite adı belgeler arasında farklı"
				c.inconsistencies.append("Üniversite uyuşmazlığı: CV'de " + alt_uni + ", Diplomada " + c.university)

		"experience_inflation":
			# Claims more years than possible
			var inflated: int = c.experience_years + randi_range(5, 10)
			c.documents[0].content["Deneyim"] = str(inflated) + " yıl"
			c.documents[0].has_inconsistency = true
			c.documents[0].inconsistency_type = "experience_inflation"
			c.documents[0].inconsistency_detail = "Deneyim yılı mezuniyet tarihiyle uyuşmuyor"
			c.inconsistencies.append("Deneyim şişirmesi: " + str(inflated) + " yıl iddia edilmiş ama " + str(2026 - c.graduation_year) + " yıl önce mezun")

		"fake_reference":
			# Reference company doesn't match any previous employer
			for doc: Resource in c.documents:
				if doc.doc_type == "reference":
					var fake_company: String = "Hayalet Danışmanlık A.Ş."
					doc.content["Şirket"] = fake_company
					doc.has_inconsistency = true
					doc.inconsistency_type = "fake_reference"
					doc.inconsistency_detail = "Referans şirketi adayın hiçbir önceki işyeriyle uyuşmuyor"
					c.inconsistencies.append("Sahte referans: " + fake_company + " adayın çalışma geçmişinde yok")
					break

		"fake_university":
			# Use a fake university name
			var fake_uni: String = FAKE_UNIVERSITIES[randi() % FAKE_UNIVERSITIES.size()]
			c.university = fake_uni
			c.documents[0].content["Üniversite"] = fake_uni
			if c.documents.size() > 1:
				c.documents[1].content["Üniversite"] = fake_uni
			c.inconsistencies.append("Sahte üniversite: " + fake_uni)

		"tc_invalid":
			# Corrupt the TC number
			var bad_tc: String = generate_tc_kimlik(false)
			c.tc_kimlik_no = bad_tc
			for doc: Resource in c.documents:
				if doc.doc_type == "id_card":
					doc.content["TC Kimlik No"] = bad_tc
					doc.has_inconsistency = true
					doc.inconsistency_type = "tc_invalid"
					doc.inconsistency_detail = "TC Kimlik numarası geçersiz"
					break
			c.inconsistencies.append("Geçersiz TC Kimlik No")

		"gpa_mismatch":
			# GPA differs between CV and diploma
			if c.documents.size() > 1:
				var fake_gpa: float = snapped(c.gpa + randf_range(0.5, 1.0), 0.01)
				if fake_gpa > 4.0:
					fake_gpa = c.gpa - randf_range(0.5, 1.0)
				c.documents[0].content["Not Ortalaması"] = str(snapped(fake_gpa, 0.01))
				c.documents[0].has_inconsistency = true
				c.documents[0].inconsistency_type = "gpa_mismatch"
				c.documents[0].inconsistency_detail = "Not ortalaması belgeler arasında farklı"
				c.inconsistencies.append("Not uyuşmazlığı: CV'de " + str(snapped(fake_gpa, 0.01)) + ", Diplomada " + str(c.gpa))

static func generate_candidates_for_day(day: int, directives: Array[String], num: int, inconsistency_ratio: float) -> Array[CandidateData]:
	var candidates: Array[CandidateData] = []
	var base_seed: int = day * 1000 + randi() % 500

	# Determine how many should be hireable
	var hire_count: int = maxi(1, int(num * randf_range(0.35, 0.6)))
	var reject_count: int = num - hire_count

	# Generate hireable candidates
	for i in range(hire_count):
		var c: CandidateData = generate_candidate(base_seed + i, day)
		_ensure_directive_compliance(c, directives)
		c.is_valid_hire = true
		candidates.append(c)

	# Generate rejectable candidates
	for i in range(reject_count):
		var c: CandidateData = generate_candidate(base_seed + hire_count + i, day)
		_apply_directive_violation(c, directives)
		c.is_valid_hire = false
		candidates.append(c)

	# Inject inconsistencies into a subset
	var inc_count: int = maxi(0, int(num * inconsistency_ratio))
	var inc_types: Array[String] = ["name_mismatch", "date_mismatch", "university_mismatch",
		"experience_inflation", "fake_reference", "gpa_mismatch"]
	if day >= 4:
		inc_types.append("tc_invalid")
		inc_types.append("fake_university")

	var shuffled: Array[CandidateData] = candidates.duplicate()
	shuffled.shuffle()
	for i in range(mini(inc_count, shuffled.size())):
		inject_inconsistency(shuffled[i], inc_types[randi() % inc_types.size()])

	# Shuffle order
	candidates.shuffle()
	return candidates

static func _ensure_directive_compliance(c: CandidateData, directives: Array[String]) -> void:
	for d: String in directives:
		match d:
			"min_experience_3":
				if c.experience_years < 3:
					c.experience_years = randi_range(3, 8)
					c.documents[0].content["Deneyim"] = str(c.experience_years) + " yıl"
			"no_engineering":
				if c.department in ENGINEERING_DEPARTMENTS:
					c.department = "İşletme"
					c.documents[0].content["Bölüm"] = c.department
					if c.documents.size() > 1:
						c.documents[1].content["Bölüm"] = c.department
			"disability_quota":
				pass  # Handled specially
			"no_hiring":
				pass  # Contradictory directive - handled at scoring level
			"must_hire_ahmet":
				pass  # Special candidate
			"report_suspicious":
				pass  # Doesn't affect validity

static func _apply_directive_violation(c: CandidateData, directives: Array[String]) -> void:
	# Pick one directive to violate
	var violatable: Array[String] = []
	for d: String in directives:
		if d in ["min_experience_3", "no_engineering"]:
			violatable.append(d)

	if violatable.is_empty():
		# Default: make them underqualified
		c.experience_years = randi_range(0, 2)
		c.documents[0].content["Deneyim"] = str(c.experience_years) + " yıl"
		c.rejection_reasons.append("Yetersiz deneyim")
		return

	var violation: String = violatable[randi() % violatable.size()]
	match violation:
		"min_experience_3":
			c.experience_years = randi_range(0, 2)
			c.documents[0].content["Deneyim"] = str(c.experience_years) + " yıl"
			c.rejection_reasons.append("3 yıldan az deneyim")
		"no_engineering":
			c.department = ENGINEERING_DEPARTMENTS[randi() % ENGINEERING_DEPARTMENTS.size()]
			c.documents[0].content["Bölüm"] = c.department
			if c.documents.size() > 1:
				c.documents[1].content["Bölüm"] = c.department
			c.rejection_reasons.append("Mühendislik bölümü — alım durduruldu")
