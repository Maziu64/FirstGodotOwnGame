extends Node2D
@onready var projectile: Node2D = $"."

@export var SPEED = 100
@onready var collision_shape_2d: CollisionShape2D = $Damagezone/CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var dir : Vector2 = Vector2.RIGHT


func _process(delta: float) -> void:
	
	if animated_sprite_2d.animation == "cast":
		match animated_sprite_2d.frame:
			10:
				projectile.scale = Vector2 (0.5, 0.5)
				animated_sprite_2d.play("flying")
				collision_shape_2d.disabled = false
	
	if animated_sprite_2d.animation == "flying":
		position += dir * SPEED * delta
	
	#if animated_sprite_2d.animation == "hit":
		#if animated_sprite_2d.frame == 4:
			##queue_free()
			#pass

func hitted() -> void:
	collision_shape_2d.disabled = true
	animated_sprite_2d.play("hit")
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "hit":
		print("projectile disabled")
		collision_shape_2d.disabled = true
		visible = false
	
