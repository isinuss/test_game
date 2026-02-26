class_name CandidateData
extends Resource
## All data for a single job candidate.

@export var candidate_name: String = ""
@export var age: int = 25
@export var gender: String = "E"  # E=Erkek, K=Kadın
@export var city: String = ""
@export var tc_kimlik_no: String = ""
@export var photo_seed: int = 0

# Education
@export var university: String = ""
@export var department: String = ""
@export var graduation_year: int = 2020
@export var gpa: float = 3.0

# Experience
@export var position_applied: String = ""
@export var experience_years: int = 0
@export var previous_companies: Array[String] = []
@export var skills: Array[String] = []
@export var has_employment_gap: bool = false

# Reference
@export var has_reference: bool = true
@export var reference_author: String = ""
@export var reference_company: String = ""
@export var reference_quality: String = "good"  # excellent/good/suspicious/fake

# Background check documents
@export var has_criminal_record: bool = false
@export var criminal_record_clean: bool = true
@export var has_health_report: bool = false
@export var health_report_fit: bool = true

# Special flags
@export var has_disability: bool = false
@export var is_ceo_nephew: bool = false
@export var is_union_candidate: bool = false
@export var is_returning_candidate: bool = false
@export var is_journalist: bool = false
@export var is_spy: bool = false
@export var original_candidate_name: String = ""

# Documents
@export var documents: Array[Resource] = []
@export var inconsistencies: Array[String] = []

# Scoring ground truth
@export var is_valid_hire: bool = true
@export var rejection_reasons: Array[String] = []

# Event link
@export var special_event_id: String = ""

# Dialogue
@export var greeting: String = ""
@export var interview_lines: Array[String] = []
@export var reaction_hired: String = ""
@export var reaction_rejected: String = ""
