extends CanvasLayer
## Handles smooth fade transitions between scenes and hosts global CRT overlay.

@onready var fade_rect: ColorRect = $FadeRect
@onready var crt_rect: ColorRect = $CRTOverlay

var _is_transitioning: bool = false

func _ready() -> void:
	layer = 100
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Start with black screen, fade in
	_fade_in(0.6)

func transition_to(scene_path: String, fade_out_time: float = 0.4, fade_in_time: float = 0.4) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	# Fade out
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, fade_out_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished

	# Change scene
	get_tree().change_scene_to_file(scene_path)

	# Wait for scene tree to settle
	await get_tree().process_frame
	await get_tree().process_frame

	# Fade in
	var tween2: Tween = create_tween()
	tween2.tween_property(fade_rect, "color:a", 0.0, fade_in_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween2.finished

	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false

func _fade_in(duration: float) -> void:
	fade_rect.color.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func is_transitioning() -> bool:
	return _is_transitioning
