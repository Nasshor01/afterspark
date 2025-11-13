extends Area2D

# ⚡ AFTERSPARK - Bullet

var direction := Vector2.ZERO
var speed := Globals.BULLET_SPEED
var damage := Globals.BULLET_DAMAGE
var lifetime := Globals.BULLET_LIFETIME

@onready var sprite := $Sprite2D
@onready var light := $PointLight2D
@onready var particles := $GPUParticles2D
@onready var timer := $LifetimeTimer

func _ready() -> void:
	# Setup vizuálu
	sprite.modulate = Globals.COLOR_PLAYER
	light.color = Globals.COLOR_PLAYER
	
	# Nastavení timeru
	timer.wait_time = lifetime
	timer.timeout.connect(_on_lifetime_timeout)
	timer.start()
	
	# Rotace podle směru
	rotation = direction.angle()
	
	# Připojení signálů
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		# Hit nepřítele
		if area.has_method("take_damage"):
			area.take_damage(damage)
		destroy()

func _on_lifetime_timeout() -> void:
	destroy()

func destroy() -> void:
	# Particle efekt při zničení
	particles.emitting = false
	
	# Fade out
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.tween_property(light, "energy", 0.0, 0.2)
	
	await tween.finished
	queue_free()
