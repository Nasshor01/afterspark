extends Area2D

# ⚡ AFTERSPARK - Reality Fragment

var lifetime := Globals.FRAGMENT_LIFETIME
var energy_restore := Globals.FRAGMENT_ENERGY_RESTORE

@onready var sprite := $Sprite2D
@onready var light := $PointLight2D
@onready var particles := $GPUParticles2D
@onready var timer := $LifetimeTimer

func _ready() -> void:
	add_to_group("fragment")
	
	# Setup vizuálu
	sprite.modulate = Globals.COLOR_FRAGMENT
	light.color = Globals.COLOR_FRAGMENT
	
	# Timer na zmizení
	timer.wait_time = lifetime
	timer.timeout.connect(_on_lifetime_timeout)
	timer.start()
	
	# Signály
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Spawn animace
	spawn_animation()

func _physics_process(delta: float) -> void:
	# Pulzování
	var pulse := sin(Time.get_ticks_msec() * 0.005) * 0.2 + 1.0
	sprite.scale = Vector2(pulse, pulse)
	light.energy = pulse * 0.8

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		collect(area)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collect(body)

func collect(collector: Node) -> void:
	if collector.has_method("add_fragments"):
		collector.add_fragments(1)
	
	if collector.has_method("modify_energy"):
		collector.modify_energy(energy_restore)
	
	# Collect efekt
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.tween_property(light, "energy", 3.0, 0.1)
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.2)
	
	particles.emitting = false
	
	await tween.finished
	queue_free()

func _on_lifetime_timeout() -> void:
	# Fade out po vypršení času
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
	tween.tween_property(light, "energy", 0.0, 1.0)
	
	await tween.finished
	queue_free()

func spawn_animation() -> void:
	# Začíná neviditelný
	sprite.modulate.a = 0.0
	light.energy = 0.0
	sprite.scale = Vector2(0.1, 0.1)
	
	# Fade in
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.3)
	tween.tween_property(light, "energy", 0.8, 0.3)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3)
