extends Control
## Ambient floating dust particles for the office booth atmosphere.

const MAX_PARTICLES: int = 18
const PARTICLE_MIN_SIZE: float = 1.0
const PARTICLE_MAX_SIZE: float = 2.5

var _particles: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(MAX_PARTICLES):
		_particles.append(_create_particle(true))

func _create_particle(random_start: bool) -> Dictionary:
	var p: Dictionary = {}
	p["x"] = _rng.randf_range(0.0, size.x) if random_start else _rng.randf_range(0.0, size.x)
	p["y"] = _rng.randf_range(0.0, size.y) if random_start else size.y + 10.0
	p["vx"] = _rng.randf_range(-8.0, 8.0)
	p["vy"] = _rng.randf_range(-12.0, -3.0)
	p["size"] = _rng.randf_range(PARTICLE_MIN_SIZE, PARTICLE_MAX_SIZE)
	p["alpha"] = _rng.randf_range(0.05, 0.18)
	p["drift_phase"] = _rng.randf_range(0.0, TAU)
	p["drift_speed"] = _rng.randf_range(0.5, 1.5)
	p["life"] = _rng.randf_range(0.0, 1.0) if random_start else 0.0
	p["max_life"] = _rng.randf_range(4.0, 10.0)
	return p

func _process(delta: float) -> void:
	for i in range(_particles.size()):
		var p: Dictionary = _particles[i]
		p["life"] += delta

		# Drift motion
		var drift: float = sin(p["life"] * p["drift_speed"] + p["drift_phase"]) * 6.0
		p["x"] += (p["vx"] + drift) * delta
		p["y"] += p["vy"] * delta

		# Reset if out of bounds or expired
		if p["life"] > p["max_life"] or p["y"] < -10.0 or p["x"] < -20.0 or p["x"] > size.x + 20.0:
			_particles[i] = _create_particle(false)

	queue_redraw()

func _draw() -> void:
	var dust_color: Color = Color(0.65, 0.58, 0.45)
	for p: Dictionary in _particles:
		# Fade in and out over lifetime
		var life_ratio: float = p["life"] / p["max_life"]
		var fade: float = 1.0
		if life_ratio < 0.15:
			fade = life_ratio / 0.15
		elif life_ratio > 0.7:
			fade = 1.0 - (life_ratio - 0.7) / 0.3
		fade = clampf(fade, 0.0, 1.0)

		var c: Color = dust_color
		c.a = p["alpha"] * fade
		draw_rect(Rect2(p["x"], p["y"], p["size"], p["size"]), c)
