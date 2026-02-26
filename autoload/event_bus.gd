extends Node
## Global signal bus for decoupled communication between systems.

# Day flow
signal day_started(day_number: int)
signal day_ended(day_number: int)

# Candidate flow
signal candidate_arrived(candidate_data: Resource)
signal candidate_left()
signal documents_received()

# Player actions
signal decision_made(candidate_data: Resource, hired: bool)
signal violation_received(reason: String)

# Events
signal event_triggered(event_id: String)
signal event_choice_made(event_id: String, choice_index: int)

# Interrogation
signal interrogation_requested(inconsistency_type: String, detail: String, doc_index: int)
signal interrogation_resolved(was_guilty: bool, player_correct: bool)

# Phone system
signal phone_ringing(call_data: Dictionary)
signal phone_answered(call_data: Dictionary)
signal phone_ignored(call_data: Dictionary)

# Stress
signal stress_changed(new_stress: float)

# UI
signal directive_changed()
signal money_changed(new_amount: int)
signal show_speech(text: String)
signal hide_speech()
