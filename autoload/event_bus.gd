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

# UI
signal directive_changed()
signal money_changed(new_amount: int)
signal show_speech(text: String)
signal hide_speech()
