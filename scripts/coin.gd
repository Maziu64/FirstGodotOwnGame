extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if "player" in body.get_groups():
		body.add_point(1)
		animation_player.play("pickUp")
