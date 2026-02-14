extends Node2D

@onready var dwarf = $Dwarf
@onready var ui = $UI
@onready var exit = $Exit


func _ready() -> void:
	# Connect exit signal
	exit.level_completed.connect(_on_level_completed)


func _process(_delta: float) -> void:
	# Update UI with player score
	if dwarf and ui:
		ui.update_score(dwarf.score)


func _on_level_completed() -> void:
	print("Congratulations! You completed the level!")
	print("Final Score: ", dwarf.score, " coins")
	# You can add level transition or restart here
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
