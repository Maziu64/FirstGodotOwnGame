extends Node2D

var TIMEOUT: float = 0.6

@export var damage: int
@export var damage_player: bool
@export var damage_enemies: bool
@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	#body.get_node("CollisionShape2D").queue_free()
	#timer.start()
	if damage_player:
		if "player" in body.get_parent().get_groups():
			body.get_parent().hitted(damage)
			#Baja la veocidad a la que corre el engine, para dar un efecto de muerte
			Engine.time_scale = 0.5 
			timer.start()
	#if "projectiles" in get_parent().get_groups():
	#	get_parent().hitted()
	
	

func _on_area_entered(area: Area2D) -> void:
	if damage_enemies:
		if "enemies" in area.get_parent().get_groups():
			area.get_parent().hitted(damage)
			if "projectiles" in get_parent().get_groups():
				get_parent().hitted()
			Engine.time_scale = 0.5
			#await get_tree().create_timer(TIMEOUT).timeout
			timer.start()
			

	
	
	

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	print("Restablecer tiempo")
	timer.stop()
	if "projectiles" in get_parent().get_groups():
		get_parent().queue_free()
#	get_tree().reload_current_scene()
