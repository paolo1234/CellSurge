## AudioManager.gd
## Centralized audio: SFX pool, music control, volume settings.
## All sounds are generated procedurally — no external files needed.
extends Node

const SfxGen := preload("res://autoloads/SfxGenerator.gd")

var sfx_players: Array = []
var music_player: AudioStreamPlayer
const POOL_SIZE := 16

# AudioStream references — generated procedurally
var sfx_hit: AudioStream
var sfx_pickup: AudioStream
var sfx_levelup: AudioStream
var sfx_shoot: AudioStream
var sfx_explosion: AudioStream
var sfx_damage: AudioStream
var sfx_death: AudioStream
var music_battle: AudioStream
var music_menu: AudioStream


func _ready() -> void:
	# Build SFX pool
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	
	# Music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Generate all audio procedurally
	_generate_audio()
	_apply_saved_volumes()


func _generate_audio() -> void:
	sfx_hit = SfxGen.generate_hit()
	sfx_pickup = SfxGen.generate_pickup_beep()
	sfx_levelup = SfxGen.generate_levelup_arpeggio()
	sfx_shoot = SfxGen.generate_shoot()
	sfx_explosion = SfxGen.generate_explosion()
	sfx_damage = SfxGen.generate_damage()
	sfx_death = SfxGen.generate_explosion()
	music_battle = preload("res://audio/Cellular_Siege.mp3")
	music_menu = preload("res://audio/Cellular_Siege.mp3")


func play_sfx(stream: AudioStream, pitch_variation: float = 0.1) -> void:
	if stream == null:
		return
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
			var sfx_vol: float = SaveManager.get_setting("sfx_volume", 1.0)
			player.volume_db = linear_to_db(sfx_vol)
			player.play()
			return
	# All busy — use first one
	sfx_players[0].stream = stream
	sfx_players[0].play()


func play_music(stream: AudioStream, fade_in: float = 1.0) -> void:
	if stream == null:
		return
	if music_player.playing:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_in / 2.0)
		await tween.finished
	music_player.stream = stream
	music_player.volume_db = -80.0
	music_player.play()
	var music_vol: float = SaveManager.get_setting("music_volume", 1.0)
	var target_db := linear_to_db(music_vol) - 6.0  # Music a bit quieter than SFX
	var tween2 := create_tween()
	tween2.tween_property(music_player, "volume_db", target_db, fade_in)


func stop_music(fade_out: float = 1.0) -> void:
	if not music_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_out)
	await tween.finished
	music_player.stop()


func _apply_saved_volumes() -> void:
	pass  # Volumes applied per-play in play_sfx/play_music


# Convenience methods for common sounds
func play_hit() -> void:
	play_sfx(sfx_hit, 0.15)


func play_pickup() -> void:
	play_sfx(sfx_pickup, 0.05)


func play_levelup() -> void:
	play_sfx(sfx_levelup, 0.1)


func play_shoot() -> void:
	play_sfx(sfx_shoot, 0.2)


func play_damage() -> void:
	play_sfx(sfx_damage, 0.2)


func play_death() -> void:
	play_sfx(sfx_death, 0.3)