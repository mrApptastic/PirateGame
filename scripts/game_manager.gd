extends Node

## Global game manager - handles score, health, lives, and game state

signal gold_changed(new_amount: int)
signal health_changed(new_health: int)
signal lives_changed(new_lives: int)
signal score_changed(new_score: int)
signal game_over
signal level_completed
signal treasure_map_piece_collected(total_pieces: int)

# Player stats
var gold: int = 0:
	set(value):
		gold = value
		gold_changed.emit(gold)

var health: int = 5:
	set(value):
		health = clamp(value, 0, max_health)
		health_changed.emit(health)
		if health <= 0:
			_on_player_died()

var max_health: int = 5
var lives: int = 3:
	set(value):
		lives = value
		lives_changed.emit(lives)

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

var treasure_map_pieces: int = 0
var total_map_pieces: int = 3
var enemies_defeated: int = 0
var current_level: int = 1
var is_game_over: bool = false
var is_paused: bool = false

# Combo system
var combo_count: int = 0
var combo_timer: float = 0.0
const COMBO_TIMEOUT: float = 2.0

# Achievements
var achievements: Dictionary = {
	"first_blood": false,
	"treasure_hunter": false,
	"combo_master": false,
	"gold_hoarder": false,
	"pirate_king": false,
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_count = 0


func add_gold(amount: int) -> void:
	gold += amount
	score += amount * 10
	if gold >= 100 and not achievements["gold_hoarder"]:
		achievements["gold_hoarder"] = true


func add_score(amount: int) -> void:
	score += amount


func collect_treasure_map_piece() -> void:
	treasure_map_pieces += 1
	treasure_map_piece_collected.emit(treasure_map_pieces)
	if treasure_map_pieces >= total_map_pieces:
		if not achievements["treasure_hunter"]:
			achievements["treasure_hunter"] = true


func register_enemy_kill() -> void:
	enemies_defeated += 1
	combo_count += 1
	combo_timer = COMBO_TIMEOUT
	var combo_bonus := combo_count * 50
	score += 100 + combo_bonus
	if not achievements["first_blood"]:
		achievements["first_blood"] = true
	if combo_count >= 5 and not achievements["combo_master"]:
		achievements["combo_master"] = true


func take_damage(amount: int = 1) -> void:
	health -= amount
	combo_count = 0


func heal(amount: int = 1) -> void:
	health = min(health + amount, max_health)


func _on_player_died() -> void:
	lives -= 1
	if lives <= 0:
		is_game_over = true
		game_over.emit()
	else:
		health = max_health
		_respawn_player()


func _respawn_player() -> void:
	# Handled by level - just reset health
	health = max_health


func complete_level() -> void:
	var time_bonus := 1000
	score += time_bonus + (gold * 5)
	level_completed.emit()


func reset_game() -> void:
	gold = 0
	health = max_health
	lives = 3
	score = 0
	treasure_map_pieces = 0
	enemies_defeated = 0
	combo_count = 0
	is_game_over = false
	current_level = 1


func pause_game() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
