extends Control

# ⚡ AFTERSPARK - HUD

@onready var energy_bar := $MarginContainer/VBoxContainer/EnergyBar
@onready var energy_label := $MarginContainer/VBoxContainer/EnergyBar/EnergyLabel
@onready var fragments_label := $MarginContainer/VBoxContainer/FragmentsLabel
@onready var time_label := $MarginContainer/VBoxContainer/TimeLabel
@onready var kills_label := $MarginContainer/VBoxContainer/KillsLabel
@onready var message_label := $MessageLabel

var current_energy := 100.0
var max_energy := 100.0

func _ready() -> void:
	# Nastav výchozí hodnoty
	update_energy(Globals.PLAYER_MAX_ENERGY)
	update_fragments(0)
	
	# Skryj zprávu
	message_label.modulate.a = 0.0

func _process(_delta: float) -> void:
	# Update času
	if time_label:
		var time := Globals.game_time
		var minutes := int(time) / 60
		var seconds := int(time) % 60
		time_label.text = "TIME: %02d:%02d" % [minutes, seconds]
	
	# Update killů
	if kills_label:
		kills_label.text = "KILLS: %d" % Globals.enemies_killed

func update_energy(value: float) -> void:
	current_energy = value
	max_energy = Globals.PLAYER_MAX_ENERGY
	
	if energy_bar:
		var percent := value / max_energy
		energy_bar.value = percent * 100
		
		# Změna barvy podle stavu
		if percent > 0.5:
			energy_bar.modulate = Color(0.2, 0.8, 1.0)  # Cyan
		elif percent > 0.25:
			energy_bar.modulate = Color(1.0, 0.9, 0.3)  # Žlutá
		else:
			energy_bar.modulate = Color(0.9, 0.2, 0.3)  # Červená
	
	if energy_label:
		energy_label.text = "%d" % int(value)

func update_fragments(value: int) -> void:
	if fragments_label:
		fragments_label.text = "FRAGMENTS: %d / %d" % [value, Globals.REIGNITE_COST]
		
		# Zvýrazni když máš dost na Reignite
		if value >= Globals.REIGNITE_COST:
			fragments_label.modulate = Globals.COLOR_REIGNITE
		else:
			fragments_label.modulate = Color.WHITE

func show_message(text: String, duration := 2.0) -> void:
	if message_label:
		message_label.text = text
		
		# Fade in
		var tween := create_tween()
		tween.tween_property(message_label, "modulate:a", 1.0, 0.3)
		
		# Počkej
		await get_tree().create_timer(duration).timeout
		
		# Fade out
		tween = create_tween()
		tween.tween_property(message_label, "modulate:a", 0.0, 0.5)

func _on_game_started() -> void:
	show_message("THE LIGHT FADES...", 2.0)

func _on_low_energy_warning() -> void:
	show_message("ENERGY CRITICAL", 1.5)
