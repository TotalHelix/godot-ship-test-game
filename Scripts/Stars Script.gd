extends Node2D

@export var repeat_scale = 2

# now the ugly variables
@export_group("Star Layers")
@export_subgroup("Big Stars")
@export var _parallax_layer_big: Node
@export var _star_count_big = 10
@export var _min_scale_big = 0.5
@export var _max_scale_big = 1.5
@export var _min_transparency_big = 0.2
@export var _max_transparency_big = 1.0
@export_subgroup("Medium Stars")
@export var _parallax_layer_med: Parallax2D
@export var _star_count_med = 10
@export var _min_scale_med = 0.5
@export var _max_scale_med = 1.5
@export var _min_transparency_med = 0.2
@export var _max_transparency_med = 1.0
@export_subgroup("Small Stars")
@export var _parallax_layer_small: Parallax2D
@export var _star_count_small = 10
@export var _min_scale_small = 0.5
@export var _max_scale_small = 1.5
@export var _min_transparency_small = 0.2
@export var _max_transparency_small = 1.0
@export_subgroup("Tiny Stars")
@export var _parallax_layer_tiny: Parallax2D
@export var _star_count_tiny = 10
@export var _min_scale_tiny = 0.5
@export var _max_scale_tiny = 1.5
@export var _min_transparency_tiny = 0.2
@export var _max_transparency_tiny = 1.0

# first we clean up all these together into a nice dictionary
var star_config
var star_prefabs = {
	"big": "res://Prefabs/Stars/star_big.tscn",
	"med": "res://Prefabs/Stars/star_med.tscn",
	"small": "res://Prefabs/Stars/star_small.tscn",
	"tiny": "res://Prefabs/Stars/star_tiny.tscn"
}
var rng = RandomNumberGenerator.new()


## function to help clean up these exports
## takes a string suffix and returns a dict of input variables
func _build_dict(suffix: String) -> Dictionary:
	return {
		"parallax_layer": get("_parallax_layer_" + suffix),
		"count": get("_star_count_" + suffix), 
		"min_scale": get("_min_scale_" + suffix), 
		"max_scale": get("_max_scale_" + suffix), 
		"min_transparency": get("_min_transparency_" + suffix), 
		"max_transparency": get("_max_transparency_" + suffix)
	}

func _ready() -> void:
	# set some variables
	var spawnable_area = get_viewport_rect().size * repeat_scale * rng.randf_range(0.8, 1.2)
	star_config = {
		"big": _build_dict("big"), 
		"med": _build_dict("med"), 
		"small": _build_dict("small"),
		"tiny": _build_dict("tiny")
	}
	
	# go through each layer and prepare it
	for layer_key in star_config:
		# set the repeat size to the viewport size
		var layer_dict = star_config[layer_key]
		var parallax_layer = layer_dict["parallax_layer"]
		
		# make sure there's a parallax layer set
		if parallax_layer == null:
			printerr("Parallax node for star layer ", layer_key ," not set!")
			continue
		
		parallax_layer.repeat_size = spawnable_area
		# parallax_layer.repeat_size = camera_size * repeat_scale
		
		# random stars!
		for i in range(layer_dict["count"]):
			# make the new star
			var new_star = load(star_prefabs[layer_key]).instantiate()
			
			# change the new star properties
			# position
			new_star.position = Vector2(
				rng.randf_range(0, spawnable_area.x),
				rng.randf_range(0, spawnable_area.y)
			)
			
			# scale
			var scaler = rng.randf_range(layer_dict["min_scale"], layer_dict["max_scale"])
			new_star.scale = Vector2(scaler, scaler)
			
			# transparency
			new_star.modulate.a = rng.randf_range(layer_dict["min_transparency"], layer_dict["max_transparency"])
			
			# and finally add the star to the scene
			parallax_layer.add_child(new_star)
			
