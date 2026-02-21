class_name DirectiveData
extends Resource
## A management directive that constrains hiring decisions.

@export var directive_id: String = ""
@export var directive_text: String = ""  # Turkish display text
@export var condition_type: String = ""  # min_experience, no_department, must_hire_specific, etc.
@export var condition_value: Variant = null
@export var is_mandatory: bool = true
