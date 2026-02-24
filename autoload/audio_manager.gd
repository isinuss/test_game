extends Node
## Procedural audio manager. Generates all game sounds from code — no audio files needed.

const SR: int = 22050

var _sfx_player: AudioStreamPlayer
var _sfx_player_2: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _mumble_player: AudioStreamPlayer

var _streams: Dictionary = {}

func _ready() -> void:
	_create_players()
	_generate_sounds()

func _create_players() -> void:
	_sfx_player = _add_player(-8.0)
	_sfx_player_2 = _add_player(-8.0)
	_ambient_player = _add_player(-18.0)
	_music_player = _add_player(-20.0)
	_mumble_player = _add_player(-10.0)

func _add_player(vol_db: float) -> AudioStreamPlayer:
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	p.volume_db = vol_db
	add_child(p)
	return p

func _generate_sounds() -> void:
	_streams["ui_click"] = _gen_ui_click()
	_streams["stamp_hire"] = _gen_stamp(true)
	_streams["stamp_reject"] = _gen_stamp(false)
	_streams["paper"] = _gen_paper()
	_streams["tab_click"] = _gen_tab_click()
	_streams["violation"] = _gen_violation()
	_streams["money"] = _gen_money()
	_streams["ambient"] = _gen_ambient()
	_streams["music"] = _gen_music()
	_streams["drawer_open"] = _gen_drawer_open()
	_streams["drawer_close"] = _gen_drawer_close()

# ── Public API ─────────────────────────────────────────────────────────────

func play_sfx(sound_name: String) -> void:
	if not _streams.has(sound_name):
		return
	var player: AudioStreamPlayer = _sfx_player
	if _sfx_player.playing:
		player = _sfx_player_2
	player.stream = _streams[sound_name]
	player.play()

func play_ambient() -> void:
	if _ambient_player.playing:
		return
	if _streams.has("ambient"):
		_ambient_player.stream = _streams["ambient"]
		_ambient_player.play()

func stop_ambient() -> void:
	if _ambient_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(_ambient_player, "volume_db", -40.0, 0.8)
		tween.tween_callback(func() -> void:
			_ambient_player.stop()
			_ambient_player.volume_db = -18.0
		)

func play_music() -> void:
	if _music_player.playing:
		return
	if _streams.has("music"):
		_music_player.stream = _streams["music"]
		_music_player.volume_db = -20.0
		_music_player.play()

func stop_music() -> void:
	if not _music_player.playing:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_music_player, "volume_db", -45.0, 1.5)
	tween.tween_callback(func() -> void:
		_music_player.stop()
		_music_player.volume_db = -20.0
	)

func play_mumble(pitch_seed: int = 0, duration: float = 0.25) -> void:
	_mumble_player.stream = _gen_mumble(pitch_seed, duration)
	_mumble_player.play()

func stop_mumble() -> void:
	_mumble_player.stop()

# ── Sound Generators ──────────────────────────────────────────────────────

func _gen_ui_click() -> AudioStreamWAV:
	var num: int = int(SR * 0.03)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	for i in range(num):
		var t: float = float(i) / SR
		var env: float = (1.0 - float(i) / num)
		env *= env
		data[i] = sin(TAU * 880.0 * t) * env * 0.25
	return _make_stream(data)

func _gen_tab_click() -> AudioStreamWAV:
	var num: int = int(SR * 0.018)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	for i in range(num):
		var t: float = float(i) / SR
		var env: float = (1.0 - float(i) / num)
		env *= env * env
		data[i] = sin(TAU * 1200.0 * t) * env * 0.18
	return _make_stream(data)

func _gen_stamp(is_hire: bool) -> AudioStreamWAV:
	var num: int = int(SR * 0.22)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	var freq: float = 85.0 if is_hire else 65.0
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42 if is_hire else 99
	for i in range(num):
		var t: float = float(i) / SR
		var env: float = exp(-t * 18.0)
		var noise: float = rng.randf_range(-1.0, 1.0) * env * 0.35
		var tone: float = sin(TAU * freq * t) * env * 0.45
		var click: float = 0.0
		if i < int(SR * 0.004):
			click = (1.0 - float(i) / (SR * 0.004)) * 0.5
		data[i] = clampf(noise + tone + click, -1.0, 1.0)
	return _make_stream(data)

func _gen_paper() -> AudioStreamWAV:
	var num: int = int(SR * 0.2)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 321
	var prev: float = 0.0
	for i in range(num):
		var t: float = float(i) / num
		var env: float
		if t < 0.12:
			env = t / 0.12
		else:
			env = 1.0 - (t - 0.12) / 0.88
		env *= env
		var noise: float = rng.randf_range(-1.0, 1.0)
		prev = prev + 0.15 * (noise - prev)
		data[i] = prev * env * 0.3
	return _make_stream(data)

func _gen_violation() -> AudioStreamWAV:
	var num: int = int(SR * 0.4)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	for i in range(num):
		var t: float = float(i) / SR
		var in_burst: bool = (t < 0.12) or (t > 0.2 and t < 0.32)
		if not in_burst:
			data[i] = 0.0
			continue
		var wave: float = sin(TAU * 150.0 * t) * 0.35
		wave += sin(TAU * 300.0 * t) * 0.12
		wave += sin(TAU * 450.0 * t) * 0.06
		data[i] = clampf(wave, -1.0, 1.0)
	return _make_stream(data)

func _gen_money() -> AudioStreamWAV:
	var num: int = int(SR * 0.3)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	for i in range(num):
		var t: float = float(i) / SR
		var env: float = exp(-t * 5.5)
		var freq: float = 523.0 if t < 0.1 else 659.0
		data[i] = sin(TAU * freq * t) * env * 0.22
	return _make_stream(data)

func _gen_mumble(pitch_seed: int, duration: float) -> AudioStreamWAV:
	var num: int = int(SR * duration)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = pitch_seed if pitch_seed != 0 else randi()

	var base_freq: float = rng.randf_range(130.0, 260.0)
	var syllable_len: int = int(SR * rng.randf_range(0.04, 0.07))

	var cur_freq: float = base_freq
	for i in range(num):
		if syllable_len > 0 and i % syllable_len == 0:
			cur_freq = base_freq + rng.randf_range(-35.0, 35.0)
		var t: float = float(i) / SR
		var syl_t: float = float(i % syllable_len) / syllable_len if syllable_len > 0 else 0.0
		var env: float = sin(syl_t * PI) * 0.55
		var fade: float = 1.0 - float(i) / num * 0.3
		var wave: float = sin(TAU * cur_freq * t) * 0.4
		wave += sin(TAU * cur_freq * 2.1 * t) * 0.18
		wave += sin(TAU * cur_freq * 3.0 * t) * 0.08
		data[i] = wave * env * fade * 0.3
	return _make_stream(data)

func _gen_ambient() -> AudioStreamWAV:
	var num: int = int(SR * 3.0)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 777
	var prev: float = 0.0
	for i in range(num):
		var t: float = float(i) / SR
		var hum: float = sin(TAU * 60.0 * t) * 0.12
		hum += sin(TAU * 120.0 * t) * 0.04
		var noise: float = rng.randf_range(-1.0, 1.0)
		prev = prev + 0.025 * (noise - prev)
		data[i] = clampf((hum + prev * 0.18) * 0.4, -1.0, 1.0)
	return _make_stream(data, true)

func _gen_music() -> AudioStreamWAV:
	var num: int = int(SR * 8.0)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	var freqs: Array[float] = [110.0, 130.81, 164.81, 220.0]
	var amps: Array[float] = [0.22, 0.14, 0.1, 0.08]
	for i in range(num):
		var t: float = float(i) / SR
		var sample: float = 0.0
		for j in range(freqs.size()):
			var trem: float = 1.0 + sin(TAU * (0.08 + j * 0.06) * t) * 0.25
			sample += sin(TAU * freqs[j] * t) * amps[j] * trem
		var swell: float = 0.7 + sin(TAU * 0.04 * t) * 0.3
		data[i] = sample * swell * 0.35
	return _make_stream(data, true)

func _gen_drawer_open() -> AudioStreamWAV:
	var num: int = int(SR * 0.15)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 555
	var prev: float = 0.0
	for i in range(num):
		var t: float = float(i) / num
		var env: float = sin(t * PI) * 0.6
		var noise: float = rng.randf_range(-1.0, 1.0)
		prev = prev + 0.08 * (noise - prev)
		var wood: float = sin(TAU * 180.0 * float(i) / SR) * env * 0.15
		data[i] = (prev * env * 0.25 + wood) * 0.5
	return _make_stream(data)

func _gen_drawer_close() -> AudioStreamWAV:
	var num: int = int(SR * 0.1)
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(num)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 666
	var prev: float = 0.0
	for i in range(num):
		var t: float = float(i) / num
		var env: float = (1.0 - t) * (1.0 - t)
		var noise: float = rng.randf_range(-1.0, 1.0)
		prev = prev + 0.1 * (noise - prev)
		var thud: float = sin(TAU * 120.0 * float(i) / SR) * env * 0.2
		data[i] = (prev * env * 0.2 + thud) * 0.5
	return _make_stream(data)

# ── Utility ────────────────────────────────────────────────────────────────

func _make_stream(samples: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SR
	stream.stereo = false

	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in range(samples.size()):
		var s: float = clampf(samples[i], -1.0, 1.0)
		bytes.encode_s16(i * 2, int(s * 32767.0))

	stream.data = bytes
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream
