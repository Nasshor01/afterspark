extends CharacterBody2D

# ⚡ AFTERSPARK - Hráč

signal energy_changed(new_value: float)
signal fragments_changed(new_value: int)
signal player_died
signal reignite_activated

@export var speed := Globals.PLAYER_SPEED

var energy := Globals.PLAYER_MAX_ENERGY
var fragments := 0
var can_shoot := true
var is_alive := true

@onready var shoot_timer := $ShootTimer
@onready var collision := $CollisionShape2D
@onready var orb_particles := $OrbParticles
@onready var trail_particles := $TrailParticles
@onready var light := $PointLight2D

# Bullet scene
var bullet_scene := preload("res://Scenes/Effects/bullet.tscn")

func _ready() -> void:
	shoot_timer.wait_time = Globals.FIRE_RATE
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	# Setup visual
	light.color = Globals.COLOR_PLAYER
	update_visuals()

func _physics_process(_delta: float) -> void:
	if not is_alive:
		return
	
	# Pohyb
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

	# Zapnutí/vypnutí ocasu částic podle pohybu
	if input_dir.length_squared() > 0:
		trail_particles.emitting = true
	else:
		trail_particles.emitting = false
	
	# Střelba
	if Input.is_action_pressed("shoot") and can_shoot and energy > 0:
		shoot()
	
	# Reignite
	if Input.is_action_just_pressed("reignite"):
		try_reignite()
	
	# Update vizuálů
	update_visuals()

func shoot() -> void:
	if energy < Globals.PLAYER_SHOT_COST:
		return
	
	can_shoot = false
	shoot_timer.start()
	
	# Snížení energie
	modify_energy(-Globals.PLAYER_SHOT_COST)
	
	# Vytvoření projektilu
	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position
	
	# Směr ke kurzoru
	var target := get_global_mouse_position()
	var direction := (target - global_position).normalized()
	bullet.direction = direction
	
	get_parent().add_child(bullet)
	
	# Efekt výstřelu
	flash_effect()

func try_reignite() -> void:
	if fragments >= Globals.REIGNITE_COST:
		fragments -= Globals.REIGNITE_COST
		fragments_changed.emit(fragments)
		reignite_activated.emit()
		
		# Vizuální feedback
		var tween := create_tween()
		tween.tween_property(light, "energy", 3.0, 0.2)
		tween.tween_property(light, "energy", 1.0, 0.3)

func modify_energy(amount: float) -> void:
	energy = clampf(energy + amount, 0, Globals.PLAYER_MAX_ENERGY)
	energy_changed.emit(energy)
	
	if energy <= 0 and is_alive:
		die()

func add_fragments(amount: int) -> void:
	fragments += amount
	Globals.fragments_collected += amount
	fragments_changed.emit(fragments)

func take_damage(amount: float) -> void:
	modify_energy(-amount)

func die() -> void:
	is_alive = false
	player_died.emit()
	
	# Death animation
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(light, "energy", 0.0, 1.0)
	tween.tween_property(orb_particles, "emitting", false, 0.5)
	tween.tween_property(trail_particles, "emitting", false, 0.2)
	
	await tween.finished
	queue_free()

func update_visuals() -> void:
	# Měnící se světlo podle energie
	var energy_percent := energy / Globals.PLAYER_MAX_ENERGY
	light.energy = 1.2 + (energy_percent * 0.8)
	
	# Blikání při nízké energii
	if energy < Globals.PLAYER_LOW_ENERGY_THRESHOLD:
		var blink := sin(Time.get_ticks_msec() * 0.01) * 0.4 + 0.6
		light.energy *= blink
	
	# Velikost světelného kruhu
	light.texture_scale = 1.5 + (energy_percent * 1.5)

func flash_effect() -> void:
	# Efekt výstřelu - pulz světla
	var tween := create_tween()
	tween.tween_property(light, "energy", light.energy + 0.5, 0.05)
	tween.tween_property(light, "energy", light.energy, 0.1)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

# Kolize s nepřáteli
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		take_damage(15.0)  # Základní kontaktní damage
