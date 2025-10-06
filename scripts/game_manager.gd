extends Node

var score = 0
@onready var lbl_score: Label = $LblScore

func add_point():
	score += 1
	lbl_score.text = "You collected " + str(score) + " coins"
