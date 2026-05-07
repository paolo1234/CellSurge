## SfxGenerator.gd
## Generates procedural sound effects as AudioStreamWAV.
## No external audio files needed — everything is synthesized.
extends RefCounted

const SAMPLE_RATE := 22050
const MIX_RATE := 22050


## Generate a sine wave tone
static func generate_sine(freq: float, duration: float, volume: float = 0.8) -> AudioStreamWAV:
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)  # 16-bit = 2 bytes per sample
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var envelope := 1.0 - (float(i) / samples)  # linear decay
		var sample := sin(t * freq * TAU) * volume * envelope
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate white noise
static func generate_noise(duration: float, volume: float = 0.5) -> AudioStreamWAV:
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var envelope := 1.0 - (float(i) / samples)
		var sample := randf_range(-1.0, 1.0) * volume * envelope
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate a frequency sweep (chirp)
static func generate_sweep(start_freq: float, end_freq: float, duration: float, volume: float = 0.7) -> AudioStreamWAV:
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var freq: float = lerpf(start_freq, end_freq, progress)
		var envelope := 1.0 - progress  # linear decay
		var sample := sin(t * freq * TAU) * volume * envelope
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate a two-tone "pickup" beep (ascending)
static func generate_pickup_beep() -> AudioStreamWAV:
	var dur := 0.08
	var samples := int(SAMPLE_RATE * dur * 2)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var freq: float = 880.0 if progress < 0.5 else 1320.0
		var envelope := 1.0 - (progress * 0.5)
		var sample := sin(t * freq * TAU) * 0.6 * envelope
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate a level-up arpeggio (C-E-G-C ascending)
static func generate_levelup_arpeggio() -> AudioStreamWAV:
	var notes := [523.0, 659.0, 784.0, 1047.0]  # C5, E5, G5, C6
	var note_dur := 0.08
	var total_dur := note_dur * notes.size()
	var samples := int(SAMPLE_RATE * total_dur)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var note_idx := mini(int(progress * notes.size()), notes.size() - 1)
		var freq: float = float(notes[note_idx])
		var local_progress := fmod(progress * notes.size(), 1.0)
		var envelope := (1.0 - local_progress * 0.5) * (1.0 - progress * 0.3)
		var sample := sin(t * freq * TAU) * 0.6 * envelope
		# Add a bit of harmonics for richness
		sample += sin(t * freq * 2.0 * TAU) * 0.15 * envelope
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate a hit/impact sound (short noise burst + low sine)
static func generate_hit() -> AudioStreamWAV:
	var duration := 0.06
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 3.0)  # sharp decay
		var noise := randf_range(-1.0, 1.0) * 0.4
		var tone := sin(t * 180.0 * TAU) * 0.5
		var sample := (noise + tone) * envelope
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate a shoot/whoosh sound
static func generate_shoot() -> AudioStreamWAV:
	var duration := 0.05
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var freq: float = lerpf(1200.0, 400.0, progress)
		var envelope := pow(1.0 - progress, 2.0)
		var sample := sin(t * freq * TAU) * 0.3 * envelope
		sample += randf_range(-0.1, 0.1) * envelope  # noise component
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate a damage/hurt sound (low thump)
static func generate_damage() -> AudioStreamWAV:
	var duration := 0.1
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var freq: float = lerpf(200.0, 60.0, progress)
		var envelope := pow(1.0 - progress, 2.0)
		var noise_part := randf_range(-0.3, 0.3) * pow(1.0 - progress, 4.0)
		var sample := sin(t * freq * TAU) * 0.6 * envelope + noise_part
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate an explosion sound (long noise + sub bass)
static func generate_explosion() -> AudioStreamWAV:
	var duration := 0.3
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 1.5)
		var sub := sin(t * 55.0 * TAU) * 0.5 * envelope
		var noise := randf_range(-1.0, 1.0) * 0.4 * pow(1.0 - progress, 3.0)
		var mid := sin(t * lerpf(300.0, 80.0, progress) * TAU) * 0.3 * envelope
		var sample := sub + noise + mid
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	return stream


## Generate ambient drone music loop
static func generate_ambient_loop() -> AudioStreamWAV:
	var duration := 16.0  # 16 second loop
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / SAMPLE_RATE
		# Deep bass drone
		var bass := sin(t * 55.0 * TAU) * 0.15
		bass += sin(t * 82.5 * TAU) * 0.08  # fifth
		# Mid pad with slow modulation
		var mod := sin(t * 0.2 * TAU) * 0.5 + 0.5
		var pad := sin(t * 110.0 * TAU) * 0.06 * mod
		pad += sin(t * 165.0 * TAU) * 0.04 * (1.0 - mod)
		# High shimmer
		var shimmer := sin(t * 440.0 * TAU) * 0.02 * sin(t * 0.5 * TAU) * 0.5
		# Combine
		var sample := bass + pad + shimmer
		# Slight tremolo
		sample *= 0.8 + sin(t * 0.3 * TAU) * 0.2
		var s := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = samples
	return stream
