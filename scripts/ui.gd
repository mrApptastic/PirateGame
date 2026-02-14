extends CanvasLayer

@onready var score_label = $ScoreLabel


func update_score(score: int) -> void:
	score_label.text = "Coins: " + str(score)
