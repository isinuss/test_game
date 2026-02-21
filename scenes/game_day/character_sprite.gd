extends Control
## Procedural pixel-art character drawn with _draw(). Papers Please style.

# Appearance parameters (set from CandidateData.photo_seed)
var skin_color: Color = Color(0.87, 0.72, 0.58)
var hair_color: Color = Color(0.2, 0.15, 0.1)
var hair_style: int = 0  # 0=short, 1=long, 2=bald, 3=hijab
var shirt_color: Color = Color(0.3, 0.35, 0.5)
var jacket_color: Color = Color(0.15, 0.15, 0.2)
var has_glasses: bool = false
var has_beard: bool = false
var is_male: bool = true
var expression: int = 0  # 0=neutral, 1=happy, 2=sad
var is_blinking: bool = false

# Pixel scale: each "pixel" in the character is this many actual pixels
const PX: float = 6.0
# Character width/height in character-pixels
const CHAR_W: int = 16
const CHAR_H: int = 24

const SKIN_TONES: Array[Color] = [
	Color(0.96, 0.87, 0.77),  # Light
	Color(0.87, 0.72, 0.58),  # Medium light
	Color(0.76, 0.60, 0.42),  # Medium
	Color(0.60, 0.44, 0.30),  # Medium dark
	Color(0.44, 0.30, 0.20),  # Dark
]

const HAIR_COLORS: Array[Color] = [
	Color(0.1, 0.08, 0.05),   # Black
	Color(0.35, 0.22, 0.12),  # Brown
	Color(0.55, 0.25, 0.12),  # Auburn
	Color(0.78, 0.65, 0.35),  # Blonde
	Color(0.5, 0.5, 0.5),     # Gray
	Color(0.85, 0.85, 0.85),  # White
]

const SHIRT_COLORS: Array[Color] = [
	Color(0.85, 0.85, 0.9),   # White shirt
	Color(0.6, 0.7, 0.85),    # Light blue
	Color(0.75, 0.7, 0.75),   # Light purple
	Color(0.7, 0.8, 0.7),     # Light green
	Color(0.85, 0.8, 0.7),    # Beige
]

const JACKET_COLORS: Array[Color] = [
	Color(0.15, 0.15, 0.2),   # Dark navy
	Color(0.2, 0.2, 0.2),     # Charcoal
	Color(0.3, 0.2, 0.15),    # Brown
	Color(0.1, 0.1, 0.1),     # Black
	Color(0.25, 0.22, 0.3),   # Dark purple
]

var _blink_timer: float = 0.0
var _blink_interval: float = 3.0

func setup_from_seed(seed_val: int, gender: String) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_val

	is_male = (gender == "E")
	skin_color = SKIN_TONES[rng.randi() % SKIN_TONES.size()]
	hair_color = HAIR_COLORS[rng.randi() % HAIR_COLORS.size()]
	shirt_color = SHIRT_COLORS[rng.randi() % SHIRT_COLORS.size()]
	jacket_color = JACKET_COLORS[rng.randi() % JACKET_COLORS.size()]

	if is_male:
		hair_style = rng.randi_range(0, 2)  # short, long, bald
		has_beard = rng.randi() % 3 == 0
	else:
		hair_style = rng.randi_range(0, 3)  # short, long, bald, hijab
		has_beard = false

	has_glasses = rng.randi() % 2 == 0
	_blink_interval = rng.randf_range(2.0, 5.0)
	expression = 0
	queue_redraw()

func set_expression(expr: int) -> void:
	expression = expr
	queue_redraw()

func _process(delta: float) -> void:
	_blink_timer += delta
	if _blink_timer >= _blink_interval:
		_blink_timer = 0.0
		is_blinking = true
		queue_redraw()
		# Unblink after short delay
		get_tree().create_timer(0.15).timeout.connect(_unblink)

func _unblink() -> void:
	is_blinking = false
	queue_redraw()

func _draw() -> void:
	var ox: float = (size.x - CHAR_W * PX) / 2.0
	var oy: float = size.y - CHAR_H * PX - 4.0

	# Helper to draw a "pixel"
	var px := func(x: int, y: int, c: Color) -> void:
		draw_rect(Rect2(ox + x * PX, oy + y * PX, PX, PX), c)

	# Helper to draw a filled rectangle of pixels
	var px_rect := func(x: int, y: int, w: int, h: int, c: Color) -> void:
		draw_rect(Rect2(ox + x * PX, oy + y * PX, w * PX, h * PX), c)

	# === BODY (jacket + shirt) ===
	# Torso: jacket
	px_rect.call(3, 12, 10, 7, jacket_color)
	# Shirt visible in V-neck area
	px_rect.call(6, 12, 4, 3, shirt_color)

	# Arms
	px_rect.call(1, 13, 2, 6, jacket_color)
	px_rect.call(13, 13, 2, 6, jacket_color)

	# Hands
	px_rect.call(1, 19, 2, 2, skin_color)
	px_rect.call(13, 19, 2, 2, skin_color)

	# Legs
	px_rect.call(5, 19, 3, 5, Color(0.2, 0.2, 0.25))  # dark trousers
	px_rect.call(9, 19, 3, 5, Color(0.2, 0.2, 0.25))

	# === HEAD ===
	# Neck
	px_rect.call(6, 10, 4, 2, skin_color)

	# Head shape (oval-ish)
	px_rect.call(4, 2, 8, 8, skin_color)
	px_rect.call(3, 3, 1, 6, skin_color)
	px_rect.call(12, 3, 1, 6, skin_color)

	# === HAIR ===
	match hair_style:
		0:  # Short
			px_rect.call(3, 1, 10, 2, hair_color)
			px_rect.call(3, 2, 1, 2, hair_color)
			px_rect.call(12, 2, 1, 2, hair_color)
		1:  # Long
			px_rect.call(3, 1, 10, 2, hair_color)
			px_rect.call(2, 2, 2, 6, hair_color)
			px_rect.call(12, 2, 2, 6, hair_color)
			px_rect.call(2, 8, 2, 3, hair_color)
			px_rect.call(12, 8, 2, 3, hair_color)
		2:  # Bald
			px_rect.call(4, 1, 8, 1, skin_color)
		3:  # Hijab
			px_rect.call(2, 0, 12, 3, hair_color)
			px_rect.call(2, 3, 2, 8, hair_color)
			px_rect.call(12, 3, 2, 8, hair_color)
			px_rect.call(3, 10, 10, 2, hair_color)

	# === FACE ===
	var eye_y: int = 5
	var eye_color: Color = Color(0.15, 0.12, 0.1)

	if is_blinking:
		# Closed eyes: horizontal line
		px_rect.call(5, eye_y, 2, 1, eye_color)
		px_rect.call(9, eye_y, 2, 1, eye_color)
	else:
		# Open eyes
		px_rect.call(5, eye_y, 2, 2, Color.WHITE)
		px_rect.call(9, eye_y, 2, 2, Color.WHITE)
		# Pupils
		px.call(6, eye_y + 1, eye_color)
		px.call(10, eye_y + 1, eye_color)

	# Glasses
	if has_glasses:
		var glass_color: Color = Color(0.3, 0.3, 0.35)
		# Left lens frame
		px.call(4, eye_y - 1, glass_color)
		px.call(7, eye_y - 1, glass_color)
		px.call(4, eye_y + 2, glass_color)
		px.call(7, eye_y + 2, glass_color)
		# Right lens frame
		px.call(8, eye_y - 1, glass_color)
		px.call(11, eye_y - 1, glass_color)
		px.call(8, eye_y + 2, glass_color)
		px.call(11, eye_y + 2, glass_color)
		# Bridge
		px.call(7, eye_y, glass_color)
		px.call(8, eye_y, glass_color)

	# Nose
	px.call(7, 7, skin_color.darkened(0.15))
	px.call(8, 7, skin_color.darkened(0.15))

	# Mouth (expression-dependent)
	match expression:
		0:  # Neutral
			px_rect.call(6, 8, 4, 1, Color(0.6, 0.35, 0.3))
		1:  # Happy
			px_rect.call(6, 8, 4, 1, Color(0.7, 0.35, 0.3))
			px.call(5, 8, Color(0.6, 0.35, 0.3))
			px.call(10, 8, Color(0.6, 0.35, 0.3))
		2:  # Sad
			px_rect.call(6, 9, 4, 1, Color(0.5, 0.3, 0.28))
			px.call(5, 8, Color(0.5, 0.3, 0.28))
			px.call(10, 8, Color(0.5, 0.3, 0.28))

	# Beard
	if has_beard:
		var beard_c: Color = hair_color.darkened(0.1)
		px_rect.call(4, 8, 2, 2, beard_c)
		px_rect.call(10, 8, 2, 2, beard_c)
		px_rect.call(5, 9, 6, 1, beard_c)
