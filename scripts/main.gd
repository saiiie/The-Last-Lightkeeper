extends Node2D

const INTERACTION_RANGE := 90.0
const REPAIR_COST := 3
const REPAIR_AMOUNT := 30

@onready var player = $World/Player
@onready var beacon = $World/Beacon
@onready var arena = $World/Arena
@onready var waves = $WaveManager
@onready var hud = $HUD

var _run_active := false


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
	_run_active = true
	$World.show()
	hud.set_player_health(player.current_health, player.max_health)
	hud.set_beacon_health(beacon.current_health, beacon.max_health)
	hud.set_shards(player.shards)
	hud.set_pulse_cooldown(player.pulse_cooldown_remaining, player.pulse_cooldown_total)
	_update_interaction_prompt()
	hud.show()
	player.set_controls_enabled(true)
	waves.start_run(player, beacon, $World)


func _physics_process(_delta: float) -> void:
	if _run_active:
		_update_interaction_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or not _can_interact():
		return
	if beacon.current_health < beacon.max_health and player.spend_shards(REPAIR_COST):
		beacon.repair(REPAIR_AMOUNT)
		_update_interaction_prompt()


func _can_interact() -> bool:
	return (
		_run_active
		and player.current_health > 0
		and beacon.current_health > 0
		and player.global_position.distance_squared_to(beacon.global_position) <= INTERACTION_RANGE * INTERACTION_RANGE
	)


func _update_interaction_prompt() -> void:
	var message := ""
	if _can_interact():
		if beacon.current_health == beacon.max_health:
			message = "Beacon at full health"
		elif player.shards < REPAIR_COST:
			message = "Need %d shards to repair the beacon" % REPAIR_COST
		else:
			message = "E  Repair beacon (%d shards)" % REPAIR_COST
	hud.set_prompt(message)
