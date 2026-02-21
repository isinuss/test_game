class_name DocumentData
extends Resource
## A single document (CV, diploma, reference letter, or ID card).

@export var doc_type: String = ""  # "cv", "diploma", "reference", "id_card"
@export var content: Dictionary = {}
@export var has_inconsistency: bool = false
@export var inconsistency_type: String = ""
@export var inconsistency_detail: String = ""
