extends Node2D

@export var maxHP: int
var current_health: int

signal health_changed(new_value)
signal died
signal hurted


func _ready() -> void:
	current_health = maxHP

func take_damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, maxHP)
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		emit_signal("died")
	elif current_health > 0:
		emit_signal("hurted")
