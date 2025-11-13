extends "res://Scenes/Enemies/enemy_base.gd"

# ⚡ AFTERSPARK - Chaser Enemy
# Rychlý nepřítel, aktivuje se blízko světla

var is_activated := false
var activation_range := Globals.CHASER_ACTIVATION_RANGE

func _ready() -> void:
	speed = Globals.CHASER_SPEED * 0.3  # Začíná pomalu
	max_hp = Globals.CHASER_HP
	contact_damage = Globals.CHASER_DAMAGE
	
	super._ready()
	
	# Specifické nastavení pro Chaser
	sprite.scale = Vector2(0.8, 0.8)  # Menší
	light.energy = 0.3  # Ještě slabší světlo

func _physics_process(delta: float) -> void:
	if not is_alive or target == null:
		return
	
	# Aktivace při přiblížení
	var dist := global_position.distance_to(target.global_position)
	if dist < activation_range and not is_activated:
		activate()
	
	super._physics_process(delta)

func activate() -> void:
	is_activated = true
	speed = Globals.CHASER_SPEED
	
	# Vizuální feedback aktivace
	var tween := create_tween()
	tween.tween_property(light, "energy", 0.8, 0.3)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
