extends Node2D

const speed = 60

var direction = 1
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var damagezone: Area2D = $AnimatedSprite2D/Damagezone
@onready var life: Node2D = $Life
@onready var collision_shape_2d: CollisionShape2D = $Damagezone/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var die_sound: AudioStreamPlayer2D = $DieSound

func _ready() -> void:
	life.connect("health_changed", _on_health_changed)
	life.connect("died", _on_died)
	life.connect("hurted", _on_hurted)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false

	if animated_sprite_2d.animation == "move":
		position.x += direction * speed * delta
	
	if animated_sprite_2d.animation == "hitted":
		if animated_sprite_2d.frame == 4:
			animated_sprite_2d. play("move")
			collision_shape_2d.disabled = false
	if animated_sprite_2d.animation == "die":
		if animated_sprite_2d.frame == 1:
			die_sound.play()
		if animated_sprite_2d.frame == 3:
			queue_free()

func hitted(damage: float) -> void:
	life.take_damage(damage)
	collision_shape_2d.disabled = true
	
func _on_health_changed(updated_life: int) -> void:
	print("Vida actual: " + str(updated_life))

func _on_died() -> void:
	animated_sprite_2d.play("die")
	#animation_player.play("hurt_shake")	

func _on_hurted() -> void:
	animated_sprite_2d.play("hitted")
	#animation_player.play("hurt_shake")
