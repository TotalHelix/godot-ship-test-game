extends RigidBody2D

@export var follow_cursor: bool = false
@export var speed: int = 350
@export var reload_time_msec: int = 500
var look_at_pos: Vector2 = Vector2(0, 0)
var fire_gun: bool = false
var time_since_last_shot: int = 0
var bullet_prefab: Object = preload("res://Prefabs/bullet_base.tscn")
var bullets_folder: Node2D

func _ready() -> void:
	bullets_folder = get_node("/root/Stage/Bullet Holder")
	print("bullet folder: ", bullets_folder)
	print("bullet prefab type: ", type_string(typeof(bullet_prefab)))

## move the ship in the direction that it's facing every physics update
func _physics_process(delta: float) -> void:
	# if we're following the cursor, get the mouse pos
	if follow_cursor:
		look_at_pos = get_global_mouse_position()
	
	# first look at where we need to look at
	self.look_at(look_at_pos)
	
	# new push the ship in that direction
	var direction = Vector2(cos(self.rotation), sin(self.rotation)) * speed
	apply_central_force(direction)

func _input(event: InputEvent) -> void:
	# if we're lot listening for the mouse, we don't care
	if not follow_cursor:
		return
	
	# if the mouse is clicked
	if Input.is_action_just_pressed("fire_gun"):
		fire_gun = true
	
	# if the mouse is unclicked
	elif Input.is_action_just_released("fire_gun"):
		fire_gun = false

func _process(delta: float) -> void:
	# get the current time in ms and add it to the cooldown
	time_since_last_shot += delta * 1000
	
	if fire_gun and time_since_last_shot > reload_time_msec:
		time_since_last_shot = 0
		
		# make a new bullet
		var new_bullet = bullet_prefab.instantiate()
		new_bullet.bullet_type = 1
		new_bullet.position = self.position
		new_bullet.rotation = self.rotation
		bullets_folder.add_child(new_bullet)
		
