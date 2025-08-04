extends RigidBody2D

@export var follow_cursor: bool = false
@export var speed: int = 20
@export var reload_time_msec: int = 500
var look_at_pos: Vector2 = Vector2(0, 0)
var fire_gun: bool = false
var time_since_last_shot: int = 0
var bullet_prefab: Object = preload("res://Prefabs/bullet_base.tscn")
var bullets_folder: Node2D

func _ready() -> void:
	print("speed: ", speed)
	bullets_folder = get_node("/root/Stage/Bullet Holder")

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

func _physics_process(delta: float) -> void:
	# now push the ship in that direction
	var direction: Vector2 = Vector2(cos(self.rotation), sin(self.rotation))
	self.apply_central_force(direction * self.speed)
	
	# Look in a direction
	# for player ships this is the mouse pointer
	if self.follow_cursor:
		self.look_at(get_global_mouse_position())
	
	# now add some drag in the oposite direction as velocity


func _process(delta: float) -> void:
	
	# fire the gun
	if fire_gun and time_since_last_shot > reload_time_msec:
		time_since_last_shot = 0
		
		# make a new bullet
		var new_bullet = bullet_prefab.instantiate()
		new_bullet.bullet_type = 1
		new_bullet.position = self.position
		new_bullet.rotation = self.rotation
		new_bullet.push_bullet(self.linear_velocity)
		bullets_folder.add_child(new_bullet)
		
	# reload the gun
	time_since_last_shot += delta * 1000
