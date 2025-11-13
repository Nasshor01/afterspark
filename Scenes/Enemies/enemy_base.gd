extends Area2D

# ⚡ AFTERSPARK - Enemy Base Class

signal enemy_died(enemy: Area2D)

@export var speed := 100.0
@export var max_hp := 30.0
@export var contact_damage := 15.0

var hp: float
var target: Node2D = null
var is_alive := true

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D
@onready var light := $PointLight2D
@onready var particles := $GPUParticles2D

# Fragment scene
var fragment_scene := preload("res://Scenes/Pickups/fragment.tscn")

func _ready() -> void:
	hp = max_hp
	add_to_group("enemy")
	
	# Setup vizuálu
	sprite.modulate = Globals.COLOR_ENEMY
	light.color = Globals.COLOR_ENEMY
	
	# Najdi hráče
	call_deferred("find_player")

func find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	if not is_alive or target == null:
		return
	
	move_towards_target(delta)

func move_towards_target(delta: float) -> void:
	# Základní AI - pohyb k hráči
	var direction := (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Rotace sprite směrem k hráči
	rotation = direction.angle()

func take_damage(amount: float) -> void:
	if not is_alive:
		return
	
	hp -= amount
	
	# Damage flash
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
	tween.tween_property(sprite, "modulate", Globals.COLOR_ENEMY, 0.1)
	
	if hp <= 0:
		die()

func die() -> void:
	is_alive = false
	Globals.enemies_killed += 1
	
	# Drop fragment
	if randf() <= Globals.FRAGMENT_DROP_CHANCE:
		spawn_fragment()
	
	# Death animation
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(light, "energy", 0.0, 0.3)
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3)
	
	particles.emitting = false
	collision.set_deferred("disabled", true)
	
	enemy_died.emit(self)
	
	await tween.finished
	queue_free()

func spawn_fragment() -> void:
	var fragment := fragment_scene.instantiate()
	fragment.global_position = global_position
	get_parent().call_deferred("add_child", fragment)
