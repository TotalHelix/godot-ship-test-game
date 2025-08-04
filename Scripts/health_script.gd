extends Node2D

# health logic
@export var _max_health: int = 10
var _current_health: int = _max_health 

# colors logic
@export_category("color thresholds")
@export var high: float = 0.6
@export var med: float = 0.3

# the sprites holder. We'll set this up in _ready()
var sprites_holder: Sprite2D
var background_width: int  # we also need the size of the sprite holder

# a dictionary of the nodes that makes up the current helthbar
var active_sprites: Dictionary = {}
var current_set_name: String 
var sprite_set: Dictionary

# sprite offset so the the healthbar is above the center of the destroyable.
var sprite_offset: Vector2

# the healthbar sprites
var health_sprites = {
	"high": _get_healthbar_parts("Green"),
	"med": _get_healthbar_parts("Yellow"),
	"low": _get_healthbar_parts("Red")
}

# the width of the left/right sprites so that everything can be positioned propperly
# we just assume that the corners are the same left/right and high/med/low
var corner_width: int = health_sprites["high"]["left"].get_width()
var middle_width: int = health_sprites["high"]["middle"].get_width()

func _ready() -> void:
	print("corner_width: ", corner_width)
	# add the destroyable tag so that bullets know they're allowed to beat the shit out of us
	self.add_to_group("destroyable")
	
	# set up the sprites holder
	for child in self.get_children():
		if child.is_in_group("healthbar back"):
			sprites_holder = child
			break
			
	# the background size
	background_width = sprites_holder.texture.get_width()
			
	# est the healthbar offset
	var offset_x: float = - sprites_holder.texture.get_width()/2
	var offset_y: float = - 65  # possibly make this dynamic in the future? not sure
	sprite_offset = Vector2(offset_x, offset_y)
	sprites_holder.offset = sprite_offset

## return a dict of left middle and right healthbar parts
func _get_healthbar_parts(color: String) -> Dictionary:
	# start a dict
	var return_dict: Dictionary = {}
	
	# set the dict values
	for part:String in ["left", "middle", "right"]:
		return_dict[part] = load("res://Images/Healthbars/"+color+"/"+part+".png")
	
	# return the dict that we made
	return return_dict

## take damage, negative values heal. 
## if the new health is equal to max health, current health will be set to max health
## if new health <= 0, die. (see die() function)
func take_damage(damage: int) -> void:
	_current_health -= damage
	
	# if over max health
	if _current_health > _max_health:
		_current_health = _max_health
		
	# if no health left
	elif _current_health <= 0:
		die()
	
	print("HP: ", _current_health, "/", _max_health)
	# update the healthbar
	update_healthbar()
	
## return the health as a fractions
func get_health_frac() -> float:
	return float(_current_health) / _max_health
	
## returns the width in pixels that the middle section of the healthbar has to be so that it is 
## displayed correctly. 
func _calculate_middle_width() -> int:
	
	# the fraction of health / max-health
	var health_frac: float = get_health_frac()
	
	# the absolute width of the health part of the healthbar if there were no round corners
	var raw_pos: float = background_width * health_frac
	
	# the returned position: raw_pos after removing the left curve and half of the right curve 
	var adjusted_pos: float = raw_pos - (1.5 * corner_width)
	
	return adjusted_pos 

## update the healthbar
func update_healthbar() -> void:
	
	var health_frac: float = get_health_frac()
	var new_set_name: String
	
	# get the sprite set
	if health_frac > high:	 new_set_name = "high"
	elif health_frac > med:	 new_set_name = "med"
	else:					 new_set_name = "low"
	
	# if we need to remake the healthbar because we passed a color threshold
	if current_set_name != new_set_name:
		if not sprites_holder:
			printerr("Internal function called before _ready. Please add_child before calling other functions.")
			return
		
		# update the sprite info
		current_set_name = new_set_name
		sprite_set = health_sprites[new_set_name]
		
		# clear out the old sprites
		for key in active_sprites:
			active_sprites[key].queue_free()
			
		# make the healthbar parts
		for part in ["left", "middle", "right"]:
			var new_sprite: Sprite2D = Sprite2D.new()
			new_sprite.centered = false
			new_sprite.texture = sprite_set[part]
			active_sprites[part] = new_sprite
			sprites_holder.add_child(new_sprite)
	
	# now adjust the sprite positions
	# the left sprite is already at (0, 0), so it just needs to be offset adjusted
	active_sprites["left"].position = sprite_offset
	
	# the middle sprite will be at the end of the left sprite.
	# it also needs to be stretched
	var midsectoin = _calculate_middle_width()
	active_sprites["middle"].position = Vector2(corner_width, 0) + sprite_offset
	active_sprites["middle"].scale.x = float(midsectoin) / middle_width
	
	# the right half of the health bar
	active_sprites["right"].position = Vector2(midsectoin + corner_width, 0) + sprite_offset
	
## die
func die() -> void:
	self.get_parent().queue_free()
