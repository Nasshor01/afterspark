extends Node

# ⚡ AFTERSPARK - Globální konstanty a nastavení

# === HRÁČ ===
const PLAYER_MAX_ENERGY := 100.0
const PLAYER_SPEED := 200.0
const PLAYER_SHOT_COST := 5.0
const PLAYER_LOW_ENERGY_THRESHOLD := 25.0

# === STŘELBA ===
const BULLET_SPEED := 400.0
const BULLET_DAMAGE := 20.0
const BULLET_LIFETIME := 2.0
const FIRE_RATE := 0.15  # Čas mezi výstřely v sekundách

# === FRAGMENTY ===
const FRAGMENT_ENERGY_RESTORE := 2.0
const FRAGMENT_LIFETIME := 5.0
const FRAGMENT_DROP_CHANCE := 1.0  # 100% šance

# === REIGNITE SYSTÉM ===
const REIGNITE_COST := 15  # Počet fragmentů potřebných
const REIGNITE_DURATION := 5.0
const REIGNITE_RADIUS := 150.0
const REIGNITE_DAMAGE_PER_SEC := 10.0

# === NEPŘÁTELÉ ===
const WANDERER_SPEED := 80.0
const WANDERER_HP := 30.0
const WANDERER_DAMAGE := 15.0

const CHASER_SPEED := 150.0
const CHASER_HP := 20.0
const CHASER_DAMAGE := 10.0
const CHASER_ACTIVATION_RANGE := 300.0

# === SPAWN SYSTÉM ===
const INITIAL_SPAWN_INTERVAL := 3.0
const MIN_SPAWN_INTERVAL := 0.8
const SPAWN_DIFFICULTY_INCREASE := 0.05  # Každých X sekund těžší
const BASE_ENEMIES_PER_WAVE := 2
const MAX_ENEMIES_ON_SCREEN := 50

# === SVĚT ===
const ARENA_RADIUS := 600.0
const LIGHT_FADE_SPEED := 0.5  # Rychlost zmenšování světelného kruhu

# === BARVY (pro efekty) ===
const COLOR_PLAYER := Color(0.2, 0.8, 1.0)  # Cyan
const COLOR_ENEMY := Color(0.9, 0.2, 0.3)   # Červená
const COLOR_FRAGMENT := Color(1.0, 0.9, 0.3)  # Zlatá
const COLOR_REIGNITE := Color(1.0, 0.7, 0.2)  # Oranžová

# === GLOBÁLNÍ PROMĚNNÉ ===
var game_time := 0.0
var enemies_killed := 0
var fragments_collected := 0
var reignites_used := 0

func reset_stats() -> void:
	game_time = 0.0
	enemies_killed = 0
	fragments_collected = 0
	reignites_used = 0
