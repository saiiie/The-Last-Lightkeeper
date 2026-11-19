extends Node2D

const INTERACTION_RANGE := 90.0
const REPAIR_COST := 3
const REPAIR_AMOUNT := 30
const GAME_WORLD := preload("res://scenes/arena/game_world.tscn")

@onready var world: Node2D = $World
@onready var waves = $WaveManager
@onready var hud = $HUD
@onready var menu = $Overlays/MainMenu
@onready var defeat = $Overlays/Defeat
@onready var victory = $Overlays/Victory

var player
var beacon
var arena
var _run_active := false
var _all_waves_cleared := false
var _rite_in_progress := false


func _ready() -> void:
	_bind_world()
	waves.wave_started.connect(hud.set_wave)
	waves.boss_spawned.connect(_on_boss_spawned)
	waves.all_waves_cleared.connect(_on_all_waves_cleared)
	menu.start_requested.connect(_start_run)
	menu.quit_requested.connect(func(): get_tree().quit())
	defeat.restart_requested.connect(_reset_run.bind(true), CONNECT_DEFERRED)
	defeat.menu_requested.connect(_reset_run.bind(false), CONNECT_DEFERRED)
	victory.replay_requested.connect(_reset_run.bind(true), CONNECT_DEFERRED)
	victory.menu_requested.connect(_reset_run.bind(false), CONNECT_DEFERRED)


func _bind_world() -> void:
	player = world.get_node("Player")
	beacon = world.get_node("Beacon")
	arena = world.get_node("Arena")
	player.set_controls_enabled(false)
	beacon.global_position = arena.get_node("BeaconMarker").global_position
	waves.spawn_markers = arena.get_spawn_markers()
	player.health_changed.connect(hud.set_player_health)
	player.shards_changed.connect(hud.set_shards)
	player.pulse_cooldown_changed.connect(hud.set_pulse_cooldown)
	beacon.health_changed.connect(hud.set_beacon_health)
	player.died.connect(_on_defeat.bind("The Lightkeeper has fallen."))
	beacon.destroyed.connect(_on_defeat.bind("The beacon has gone dark."))
	beacon.witness_rite_completed.connect(_on_rite_completed)


func _start_run() -> void:
	_all_waves_cleared = false
	_rite_in_progress = false
	_run_active = true
	world.show()
	hud.set_player_health(player.current_health, player.max_health)
	hud.set_beacon_health(beacon.current_health, beacon.max_health)
	hud.set_shards(player.shards)
	hud.set_pulse_cooldown(player.pulse_cooldown_remaining, player.pulse_cooldown_total)
	_update_interaction_prompt()
	hud.show()
	player.set_controls_enabled(true)
	waves.start_run(player, beacon, world)


func _on_defeat(reason: String) -> void:
	if not _run_active:
		return
	_stop_run()
	defeat.show_defeat(reason)


func _on_all_waves_cleared() -> void:
	if _run_active:
		_all_waves_cleared = true
		_update_interaction_prompt()


func _on_rite_completed() -> void:
	if not _run_active or not _rite_in_progress:
		return
	_stop_run()
	victory.show_victory()


func _stop_run() -> void:
	_run_active = false
	player.set_controls_enabled(false)
	waves.stop_run()
	world.process_mode = Node.PROCESS_MODE_DISABLED
	hud.set_prompt("")
	hud.hide_boss_health()


func _on_boss_spawned(boss: Node2D) -> void:
	hud.set_boss_health(boss.current_health, boss.max_health)
	boss.health_changed.connect(hud.set_boss_health)


func _reset_run(restart: bool) -> void:
	if not defeat.visible and not victory.visible:
		return
	defeat.hide()
	victory.hide()
	remove_child(world)
	world.queue_free()
	world = GAME_WORLD.instantiate()
	add_child(world)
	_bind_world()
	if restart:
		_start_run()
	else:
		hud.hide()
		menu.show_menu()


func _physics_process(_delta: float) -> void:
	if _run_active:
		_update_interaction_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or _rite_in_progress or not _can_interact():
		return
	if _all_waves_cleared:
		_rite_in_progress = true
		player.set_controls_enabled(false)
		waves.stop_run()
		hud.set_prompt("")
		beacon.perform_witness_rite()
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
	if _rite_in_progress:
		return
	var message := ""
	if _can_interact():
		if _all_waves_cleared:
			message = "E  Perform the Witness Rite"
		elif beacon.current_health == beacon.max_health:
			message = "Beacon at full health"
		elif player.shards < REPAIR_COST:
			message = "Need %d shards to repair the beacon" % REPAIR_COST
		else:
			message = "E  Repair beacon (%d shards)" % REPAIR_COST
	elif _all_waves_cleared and _run_active:
		message = "Return to the beacon"
	hud.set_prompt(message)
