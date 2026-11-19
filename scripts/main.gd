extends Node2D

@onready var player = $World/Player
@onready var beacon = $World/Beacon
@onready var arena = $World/Arena
@onready var waves = $WaveManager
@onready var hud = $HUD


func _ready() -> void:
	player.set_controls_enabled(false)
	beacon.global_position = arena.get_node("BeaconMarker").global_position
	waves.spawn_markers = arena.get_spawn_markers()
	player.health_changed.connect(hud.set_player_health)
	player.shards_changed.connect(hud.set_shards)
	player.pulse_cooldown_changed.connect(hud.set_pulse_cooldown)
	beacon.health_changed.connect(hud.set_beacon_health)
	waves.wave_started.connect(hud.set_wave)
	$Overlays/MainMenu.start_requested.connect(_start_run)
	$Overlays/MainMenu.quit_requested.connect(func(): get_tree().quit())


func _start_run() -> void:
	$World.show()
	hud.set_player_health(player.current_health, player.max_health)
	hud.set_beacon_health(beacon.current_health, beacon.max_health)
	hud.set_shards(player.shards)
	hud.set_pulse_cooldown(player.pulse_cooldown_remaining, player.pulse_cooldown_total)
	hud.set_prompt("")
	hud.show()
	player.set_controls_enabled(true)
	waves.start_run(player, beacon, $World)
