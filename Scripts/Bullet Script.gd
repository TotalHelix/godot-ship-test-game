extends RigidBody2D

# the physics masks for player and enemy bullet
#                    87654321
var player_mask  = 0b00000110
var enemy_mask   = 0b00000011
var player_layer = 0b00010000
var enemy_layer  = 0b00001000

# sprite rectangles
var player_rect = Rect2(228, 381, 9, 54)
var enemy_rect  = Rect2(228, 451, 9, 54)

## the direction that the bullet will go
var move_direction: Vector2

## the bullet sprite
var bullet_sprite: Sprite2D = Sprite2D.new()

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
			

func _enter_tree() -> void:
	move_direction = Vector2(cos(self.rotation), sin(self.rotation))
	
	# adjust the bullet sprite
	bullet_sprite.texture = preload("res://Images/sheet.svg")
	bullet_sprite.rotation = 90 * (PI/180)
	bullet_sprite.region_enabled = true
	self.add_child(bullet_sprite)

func _physics_process(delta: float) -> void:
	# get the collision info
	var collision_info = self.move_and_collide(move_direction * delta * bullet_speed)
	
	if collision_info:
		var hit: Node2D = collision_info.get_collider()
		
		# knockback
		if hit is RigidBody2D:
			var impulse_vector: Vector2 = move_direction * push_strength
			hit.apply_impulse(impulse_vector)
		
		# damage
		if hit.is_in_group("destroyable"):
			hit.take_damage(1)
		
		self.queue_free()
