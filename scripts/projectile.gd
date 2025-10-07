extends Area2D
@onready var character_body_2d: Area2D = $"."

@export var SPEED = 100
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var dir : Vector2 = Vector2.RIGHT


func _process(delta: float) -> void:
	
	if animated_sprite_2d.animation == "cast":
		match animated_sprite_2d.frame:
			10:
				character_body_2d.scale = Vector2 (0.5, 0.5)
				animated_sprite_2d.play("flying")
				collision_shape_2d.disabled = false
	
	if animated_sprite_2d.animation == "flying":
		position += dir * SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
