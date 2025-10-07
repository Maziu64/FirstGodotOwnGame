extends CharacterBody2D

# Video Tutorial https://youtu.be/LOhfqjmasi0?si=qqhZ1rtY-4ThNPG7

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

@onready var life: Node2D = $Life

@onready var projectile_spawn: Marker2D = $ProjectileSpawn
var spawn_offset: Vector2
var animated_sprite_offset: Vector2
var attack_sprite_offset_x: float
var attack_sprite_offset_y: float

@onready var projectile = load("res://scenes/projectile.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var action_blocked: bool = false
var attack_underway: bool = false

func _ready():
	# Guardamos la posición inicial del Marker2D (por ejemplo, +20 en X)
	spawn_offset = projectile_spawn.position
	animated_sprite_offset = animated_sprite_2d.position
	
	life.connect("health_changed", _on_health_changed)
	life.connect("died", _on_died)

func die():
	

func attack():
	attack_underway = true
	
	var inst_projectile = projectile.instantiate()
	get_parent().add_child(inst_projectile)
	
	if animated_sprite_2d.flip_h:
		inst_projectile.dir = Vector2.LEFT
		projectile_spawn.position = Vector2(-spawn_offset.x, spawn_offset.y)
		inst_projectile.global_position = projectile_spawn.global_position
		inst_projectile.scale.y = inst_projectile.scale.y * -1 # Invertir sprite del proyectil si hace falta
	else:
		inst_projectile.dir = Vector2.RIGHT
		projectile_spawn.position = spawn_offset
		inst_projectile.global_position = projectile_spawn.global_position
	
	inst_projectile.rotation = inst_projectile.dir.angle()
	

func hitted(damage: float) -> void:
	life.take_damage(damage)
	
func _on_health_changed(updated_life: int) -> void:
	print("Vida actual: " + str(updated_life))

func _on_died() -> void:
	print("Muerto")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Attack"):
		
		animated_sprite_2d.position = Vector2 (attack_sprite_offset_x, attack_sprite_offset_y)
		animated_sprite_2d.play("attack")
		action_blocked = true
	
	if animated_sprite_2d.animation == "attack":
		match animated_sprite_2d.frame:
			7:
				if !attack_underway:
					attack()
			17:
				action_blocked = false
				attack_underway = false
				animated_sprite_2d.position = animated_sprite_offset

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if action_blocked == false:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		#Get the input directio: -1, 0, 1
		var direction := Input.get_axis("move_left", "move_right")
		
		#Flip the sprite
		if direction > 0:
			animated_sprite_2d.flip_h = false
			collision_shape_2d.position = Vector2(-1.5, collision_shape_2d.position.y)
			
			attack_sprite_offset_x = 10
			attack_sprite_offset_y = -19
		elif direction < 0:
			animated_sprite_2d.flip_h = true
			collision_shape_2d.position = Vector2(6, collision_shape_2d.position.y)
			
			attack_sprite_offset_x = -5
			attack_sprite_offset_y = -19
			
		
		#Play animations
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("jumping")
		
		
		
		#Apply movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif  action_blocked == true:
		velocity.x = 0

	move_and_slide()
