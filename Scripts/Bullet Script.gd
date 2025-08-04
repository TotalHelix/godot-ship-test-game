extends RigidBody2D

# bullet damage
var damage_to_take: int = 1  

# the physics masks for player and enemy bullet
#                    87654321
var player_mask  = 0b00000110
var enemy_mask   = 0b00000011
var player_layer = 0b00010000
var enemy_layer  = 0b00001000

# sprite rectangles
var player_rect = Rect2(228, 381, 9, 54)
var enemy_rect  = Rect2(228, 451, 9, 54)

# the direction that the bullet will go
var move_direction: Vector2

# the bullet sprite
var bullet_sprite: Sprite2D = Sprite2D.new()

# the healthbar prefab
var healthbar_prefab: PackedScene = preload("res://Prefabs/healthbar.tscn")

# the added velocity of the ship
var _bullet_push: Vector2 = Vector2(0, 0)

enum bullets {enemy = 0, player = 1}
@export var push_strength: int = 50
@export var bullet_speed: int = 1800
@export var bullet_type: bullets:
	set(new_val):
		bullet_type = new_val
		
		# if the bullet is a player bullet
		if new_val == bullets.player:
			self.collision_layer = player_layer
			self.collision_mask = player_mask
			bullet_sprite.region_rect = player_rect
		
		# if the bullet is an enemy bullet
		else: 
			self.collision_layer = enemy_layer
			self.collision_mask = enemy_mask
			bullet_sprite.region_rect = enemy_rect

@export_group("Despawn")

## the time in seconds that the bullet begins to disappear.
@export var despawn_begin: int = 20

## the time in seconds that the bullet will be completely gone after it starts to despawn.
@export var despawn_length: int = 3

# the timestamp when the script begins. Used to calculate bullet despawn.
var time_since_start: float = 0


func _enter_tree() -> void:
	
	# set the move direction
	move_direction = Vector2(cos(self.rotation), sin(self.rotation))
	
	# adjust the bullet sprite
	bullet_sprite.texture = preload("res://Images/sheet.svg")
	bullet_sprite.rotation = 90 * (PI/180)
	bullet_sprite.region_enabled = true
	bullet_sprite.z_index = -1
	self.add_child(bullet_sprite)

func _process(delta: float) -> void:
	
	# ###########################
	# despawn the bullet
	# ###########################
	
	# step up the timer
	time_since_start += delta
	
	# if we have passed the despawn begin threshold
	if time_since_start >= despawn_begin:
		bullet_sprite.modulate.a = 1 - (time_since_start - despawn_begin) / (despawn_length)
		
		if time_since_start >= despawn_begin + despawn_length:
			self.queue_free()

func _physics_process(delta: float) -> void:
	# get the collision info
	var collision_info = self.move_and_collide(move_direction * delta * bullet_speed + _bullet_push * delta)
	
	if collision_info:
		print("hit")
		var hit: Node2D = collision_info.get_collider()
		
		# knockback
		if hit is RigidBody2D:
			var impulse_vector: Vector2 = move_direction * push_strength
			print("move_direction * push_strength: ", move_direction * push_strength)
			hit.apply_impulse(impulse_vector)
		
		# damage
		
		# if the hit object can take damage
		if hit.is_in_group("destroyable"):
			var health_controller: Node2D
			
			# see if the hit thing already has a healthbar
			for child in hit.get_children():
				if child.is_in_group("healthbar"):
					health_controller = child
					break
			
			# if the hit already has a health bar
			if health_controller:
				print("there's already a healthbasr controller")
				health_controller.take_damage(damage_to_take)

			# if there isn't yet a healthbar
			else:
				var new_healthbar: Node2D = healthbar_prefab.instantiate()
				hit.add_child(new_healthbar)
				new_healthbar.take_damage(damage_to_take)
		
		self.queue_free()
		
## a little function that the ship can call when creating a bullet
## to add the ship velocity to the bullet
func push_bullet(push_direction: Vector2) -> void:
	_bullet_push = push_direction
