extends Node2D

# ⚡ AFTERSPARK - Enemy Spawner

signal wave_spawned(wave_number: int)

@export var spawn_radius := Globals.ARENA_RADIUS
@export var initial_interval := Globals.INITIAL_SPAWN_INTERVAL
@export var min_interval := Globals.MIN_SPAWN_INTERVAL

var spawn_interval: float
var wave_number := 0
var enemies_spawned := 0
var game_time := 0.0
var is_active := false

@onready var spawn_timer := $SpawnTimer

# Enemy scenes
var wanderer_scene := preload("res://Scenes/Enemies/wanderer.tscn")
var chaser_scene := preload("res://Scenes/Enemies/chaser.tscn")

func _ready() -> void:
	spawn_interval = initial_interval
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start_spawning() -> void:
	is_active = true
	spawn_timer.start()

func stop_spawning() -> void:
	is_active = false
	spawn_timer.stop()

func _process(delta: float) -> void:
	if is_active:
		game_time += delta
		update_difficulty()

func update_difficulty() -> void:
	# Postupně zvyšuj obtížnost
	var difficulty_factor := game_time * Globals.SPAWN_DIFFICULTY_INCREASE
	spawn_interval = max(min_interval, initial_interval - difficulty_factor)
	spawn_timer.wait_time = spawn_interval

func _on_spawn_timer_timeout() -> void:
	if not is_active:
		return
	
	# Kontrola max nepřátel
	var current_enemies := get_tree().get_nodes_in_group("enemy").size()
	if current_enemies >= Globals.MAX_ENEMIES_ON_SCREEN:
		return
	
	spawn_wave()

func spawn_wave() -> void:
	wave_number += 1
	wave_spawned.emit(wave_number)
	
	# Počet nepřátel se zvyšuje s časem
	var enemies_per_wave := Globals.BASE_ENEMIES_PER_WAVE + int(wave_number / 5.0)
	enemies_per_wave = min(enemies_per_wave, 8)  # Max 8 nepřátel na vlnu
	
	for i in range(enemies_per_wave):
		spawn_enemy()

func spawn_enemy() -> void:
	# Vyber typ nepřítele
	var enemy: Node2D
	var rand := randf()
	
	# 70% Wanderer, 30% Chaser (později více typů)
	if rand < 0.7:
		enemy = wanderer_scene.instantiate()
	else:
		enemy = chaser_scene.instantiate()
	
	# Náhodná pozice na okraji arény
	var angle := randf() * TAU
	var spawn_pos := Vector2(cos(angle), sin(angle)) * spawn_radius
	enemy.global_position = spawn_pos
	
	# Připoj k rodičovské scéně (Game node)
	get_parent().add_child(enemy)
	enemies_spawned += 1
	
	# Spawn efekt
	if enemy.has_node("GPUParticles2D"):
		var particles := enemy.get_node("GPUParticles2D")
		particles.restart()

func reset() -> void:
	wave_number = 0
	enemies_spawned = 0
	game_time = 0.0
	spawn_interval = initial_interval
	stop_spawning()
