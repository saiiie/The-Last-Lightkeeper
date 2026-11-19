extends Node2D

const BEACON := preload("res://scenes/beacon/beacon.tscn")

@onready var beacon = $Beacon
var damage_updates: Array[int] = []
var destructions := 0
var rites := 0


func _ready() -> void:
	beacon.health_changed.connect(func(current: int, _maximum: int): damage_updates.append(current))
	beacon.destroyed.connect(func(): destructions += 1)
	beacon.witness_rite_completed.connect(func(): rites += 1)
	if "--verify-b2" in OS.get_cmdline_user_args():
		_verify()


func _process(_delta: float) -> void:
	$HUD/Status.text = "Beacon HP %d / %d   |   Rite signals %d   |   Destruction signals %d" % [
		beacon.current_health, beacon.max_health, rites, destructions,
	]


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_D: beacon.take_damage(50)
		KEY_R: beacon.repair(30)
		KEY_E: beacon.perform_witness_rite()
		KEY_X: beacon.take_damage(200)
		KEY_F5: get_tree().reload_current_scene()


func _verify() -> void:
	var passed: bool = beacon.current_health == 200 and beacon.light_color == beacon.WHITE
	beacon.repair(30)
	beacon.take_damage(-10)
	beacon.take_damage(45)
	beacon.repair(30)
	beacon.repair(30)
	passed = passed and damage_updates == [155, 185, 200]
	beacon.perform_witness_rite()
	beacon.perform_witness_rite()
	passed = passed and rites == 0 and not beacon.rite_completed
	var fresh = BEACON.instantiate()
	add_child(fresh)
	fresh.perform_witness_rite()
	fresh.take_damage(200)
	fresh.perform_witness_rite()
	await get_tree().create_timer(1.4).timeout
	passed = passed and rites == 1 and beacon.rite_completed and beacon.light_color == beacon.AMBER
	beacon.take_damage(500)
	beacon.take_damage(1)
	beacon.repair(30)
	passed = passed and destructions == 1 and damage_updates == [155, 185, 200, 0]
	passed = passed and beacon.current_health == 0 and beacon.light_color == beacon.EXTINGUISHED

	passed = passed and not fresh.rite_completed and fresh.light_color == fresh.EXTINGUISHED
	if passed:
		print("B2 beacon checks passed")
	else:
		push_error("B2 beacon health, destruction, or Witness Rite check failed")
	get_tree().quit(0 if passed else 1)
