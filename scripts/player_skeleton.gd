extends CharacterBody2D

# Video Tutorial https://youtu.be/LOhfqjmasi0?si=qqhZ1rtY-4ThNPG7

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

@onready var life: Node2D = $Life
@onready var hitted_sound: AudioStreamPlayer2D = $HittedSound
@onready var die_sound: AudioStreamPlayer2D = $DieSound
var points = 0
@onready var lbl_score: Label = $LblScore

@onready var projectile_spawn: Marker2D = $ProjectileSpawn
var spawn_offset: Vector2
var animated_sprite_offset: Vector2
var attack_sprite_offset_x: float
var attack_sprite_offset_y: float
var hitted_sprite_offset_x: float
var hitted_sprite_offset_y: float
var died_sprite_offset_x: float
var died_sprite_offset_y: float

var previous_direction: float = 0.0

@onready var projectile = load("res://scenes/projectile.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var cast_meele: AnimatedSprite2D = $CastMeele
@onready var cast_melee_collision: CollisionShape2D = $CastMeele/Damagezone/CastMelee_Collision
var cast_melee_offset: Vector2

var action_blocked: bool = false
var attack_underway: bool = false
var cast_projectile: bool = true
var projectile_spawned: bool = false

func _ready():
	# Guardamos la posición inicial del Marker2D (por ejemplo, +20 en X)
	spawn_offset = projectile_spawn.position
	animated_sprite_offset = animated_sprite_2d.position
	cast_melee_offset = cast_meele.position
	
	life.connect("health_changed", _on_health_changed)
	life.connect("died", _on_died)
	life.connect("hurted", _on_hurted)
	
	points = 0
	
	cast_meele.visible = false

func add_point(amount: int) -> void:
	points += amount
	lbl_score.text = "Coins: " + str(points)
	
func attack():
	attack_underway = true
	
	if animated_sprite_2d.flip_h:
		cast_meele.flip_h = true
		cast_meele.position = Vector2(-cast_melee_offset.x, cast_melee_offset.y)
	else:
		cast_meele.flip_h = false
		cast_meele.position = cast_melee_offset
		
	cast_meele.visible = true
	cast_meele.play("cast_melee")
	cast_meele.frame = 0
	
#func enemy_hitted():
	#cast_projectile = false

func _on_cast_meele_animation_finished() -> void:
	cast_meele.visible = false
	projectile_spawned = false
	#cast_projectile = true

func spawn_projectile(spawn_projectile: bool = true) -> void:
	projectile_spawned = true
	
	if spawn_projectile:
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
	action_blocked = true
	life.take_damage(damage)

func _on_health_changed(updated_life: int) -> void:
	print("Vida actual: " + str(updated_life))

func _on_died() -> void:
	die_sound.play()
	print("Muerto")
	animated_sprite_2d.position = Vector2 (died_sprite_offset_x, died_sprite_offset_y)
	animated_sprite_2d.play("die")
	Engine.time_scale = 0.5

func _on_hurted() -> void:
	hitted_sound.play()
	animated_sprite_2d.position = Vector2 (hitted_sprite_offset_x, hitted_sprite_offset_y)
	animated_sprite_2d.play("hitted")
	
func _on_direction_changed(old: float, new: float) -> void:
	if new == 0:
		print("El jugador dejó de moverse.")
	elif new > 0:
		print("El jugador se giró a la derecha.")
		animated_sprite_2d.flip_h = false
		collision_shape_2d.position = Vector2(-1.5, -12.5)
		
		attack_sprite_offset_x = 10
		attack_sprite_offset_y = -19
		
		hitted_sprite_offset_x = 0
		hitted_sprite_offset_y = -16
		
		died_sprite_offset_x = -3.3
		died_sprite_offset_y = -16
	elif new < 0:
		print("El jugador se giró a la izquierda.")
		animated_sprite_2d.flip_h = true
		collision_shape_2d.position = Vector2(8, -12.5)
		
		attack_sprite_offset_x = -5
		attack_sprite_offset_y = -19
		
		hitted_sprite_offset_x = 5
		hitted_sprite_offset_y = -16
		
		died_sprite_offset_x = 0.7
		died_sprite_offset_y = -16

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

	if animated_sprite_2d.animation == "hitted":
		match animated_sprite_2d.frame:
			7:
				action_blocked = false
				animated_sprite_2d.position = animated_sprite_offset
	
	if animated_sprite_2d.animation == "die":
		match animated_sprite_2d.frame:
			14:
				animated_sprite_2d.position = animated_sprite_offset
				Engine.time_scale = 1
				get_tree().reload_current_scene()
				
	if cast_meele.animation == "cast_melee":
		match cast_meele.frame:
			3:
				cast_melee_collision.disabled = false
				cast_meele.modulate = "ff0000"
			7:
				cast_melee_collision.disabled = true
				cast_meele.modulate = "ffffff"
			8:
				if !projectile_spawned:
					spawn_projectile()

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
		if direction != previous_direction:
			_on_direction_changed(previous_direction, direction)
			previous_direction = direction
		
		
		#Play animations
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("run")
		#else:
			#animated_sprite_2d.play("jumping")
		
		
		
		#Apply movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif  action_blocked == true:
		velocity.x = 0

	move_and_slide()
