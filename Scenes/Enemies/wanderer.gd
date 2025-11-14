extends "res://Scenes/Enemies/enemy_base.gd"

# ⚡ AFTERSPARK - Wanderer Enemy
# Pomalý, ale vytrvalý nepřítel

func _ready() -> void:
	speed = Globals.WANDERER_SPEED
	max_hp = Globals.WANDERER_HP
	contact_damage = Globals.WANDERER_DAMAGE
	
	super._ready()
	
	# Specifické nastavení pro Wanderer
	sprite.scale = Vector2(1.2, 1.2)  # Trochu větší
	light.energy = 0.5  # Tlumenější světlo
