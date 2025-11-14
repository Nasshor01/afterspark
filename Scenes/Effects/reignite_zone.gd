extends Area2D

# ⚡ AFTERSPARK - Reignite Zone

var duration := Globals.REIGNITE_DURATION
var damage_per_sec := Globals.REIGNITE_DAMAGE_PER_SEC
var radius := Globals.REIGNITE_RADIUS

@onready var light := $PointLight2D
@onready var collision := $CollisionShape2D
@onready var particles := $GPUParticles2D
@onready var timer := $DurationTimer
@onready var damage_timer := $DamageTimer

var enemies_in_zone := []

func _ready() -> void:
	# Setup vizuálu
	light.color = Globals.COLOR_REIGNITE
	
	# Nastavení velikosti
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	
	light.texture_scale = radius / 50.0 # Větší světlo
	
	# Timery
	timer.wait_time = duration
	timer.timeout.connect(_on_duration_timeout)
	timer.start()
	
	damage_timer.wait_time = 0.5  # Damage každých 0.5s
	damage_timer.timeout.connect(_on_damage_tick)
	damage_timer.start()
	
	# Signály
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	# Spawn animace
	spawn_animation()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area not in enemies_in_zone:
		enemies_in_zone.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area in enemies_in_zone:
		enemies_in_zone.erase(area)

func _on_damage_tick() -> void:
	# Způsob damage všem nepřátelům v zóně
	for enemy in enemies_in_zone:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.take_damage(damage_per_sec * damage_timer.wait_time)

func _on_duration_timeout() -> void:
	# Fade out
	var tween := create_tween()
	tween.tween_property(light, "energy", 0.0, 1.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	await tween.finished
	queue_free()

func spawn_animation() -> void:
	# Efekt rázové vlny světla
	light.energy = 4.0 # Počáteční záblesk
	particles.emitting = true
	
	var tween := create_tween()
	tween.tween_property(light, "energy", 1.5, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
