extends Node

# ⚡ AFTERSPARK - Game Controller

signal game_started
signal game_ended
signal game_paused
signal game_resumed

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

var current_state := GameState.MENU
var game_time := 0.0
var is_running := false

@onready var player: CharacterBody2D = null
@onready var spawner: Node2D = null
@onready var hud: Control = null
@onready var camera: Camera2D = null

# Reignite zone scene
var reignite_zone_scene := preload("res://Scenes/Effects/reignite_zone.tscn")

func _ready() -> void:
	# Najdi klíčové nody
	call_deferred("setup_game")

func setup_game() -> void:
	# Najdi hráče
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		setup_player_signals()
	
	# Najdi spawner
	spawner = get_node_or_null("../EnemySpawner")
	
	# Najdi HUD
	hud = get_node_or_null("../CanvasLayer/HUD")
	
	# Najdi kameru
	if player:
		camera = player.get_node("Camera2D")

	start_game()

func setup_player_signals() -> void:
	if player:
		player.player_died.connect(_on_player_died)
		player.reignite_activated.connect(_on_reignite_activated)
		player.energy_changed.connect(_on_player_energy_changed)
		player.fragments_changed.connect(_on_player_fragments_changed)

func start_game() -> void:
	current_state = GameState.PLAYING
	is_running = true
	game_time = 0.0
	
	Globals.reset_stats()
	
	if spawner:
		spawner.start_spawning()
	
	game_started.emit()

func end_game() -> void:
	current_state = GameState.GAME_OVER
	is_running = false
	
	if spawner:
		spawner.stop_spawning()
	
	Globals.game_time = game_time
	game_ended.emit()
	
	# Počkej chvíli před zobrazením end screen
	await get_tree().create_timer(2.0).timeout
	#show_end_screen()

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		game_paused.emit()

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		game_resumed.emit()

func _process(delta: float) -> void:
	if is_running:
		game_time += delta
		Globals.game_time = game_time

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if current_state == GameState.PLAYING:
			pause_game()
		elif current_state == GameState.PAUSED:
			resume_game()
	
	if event.is_action_pressed("restart"):
		restart_game()

func restart_game() -> void:
	get_tree().reload_current_scene()

#func show_end_screen() -> void:
	# Přepni na end screen scénu
#	get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")

func _on_player_died() -> void:
	end_game()

func _on_reignite_activated() -> void:
	if player:
		var zone := reignite_zone_scene.instantiate()
		zone.global_position = player.global_position
		add_child(zone)
		
		Globals.reignites_used += 1

func _on_player_energy_changed(new_value: float) -> void:
	if hud and hud.has_method("update_energy"):
		hud.update_energy(new_value)

func _on_player_fragments_changed(new_value: int) -> void:
	if hud and hud.has_method("update_fragments"):
		hud.update_fragments(new_value)
