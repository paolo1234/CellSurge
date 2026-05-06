## AudioManager.gd
## Centralized audio: SFX pool, music control, volume settings.
extends Node

var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
const POOL_SIZE := 16


func _ready() -> void:
	# Build SFX pool
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	# Music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	# Only set bus if it exists
	if AudioServer.get_bus_index("Music") >= 0:
		music_player.bus = "Music"
	_apply_saved_volumes()


func play_sfx(stream: AudioStream, pitch_variation: float = 0.1) -> void:
	if stream == null:
		return
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
			if AudioServer.get_bus_index("SFX") >= 0:
				player.bus = "SFX"
			var sfx_vol: float = SaveManager.get_setting("sfx_volume", 1.0)
			player.volume_db = linear_to_db(sfx_vol)
			player.play()
			return
	# All busy — use first one (interrupt oldest)
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
	var tween2 := create_tween()
	tween2.tween_property(music_player, "volume_db", linear_to_db(music_vol), fade_in / 2.0)


func stop_music(fade_out: float = 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_out)
	await tween.finished
	music_player.stop()


func _apply_saved_volumes() -> void:
	var sfx_vol: float = SaveManager.get_setting("sfx_volume", 1.0)
	var music_vol: float = SaveManager.get_setting("music_volume", 1.0)
	var sfx_idx := AudioServer.get_bus_index("SFX")
	var music_idx := AudioServer.get_bus_index("Music")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_vol))
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(music_vol))
