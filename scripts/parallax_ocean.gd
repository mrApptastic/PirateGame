extends ParallaxBackground
## Ocean/Sky Parallax Background - Dynamic day/night sky with ocean waves

var time_of_day := 0.0
var wave_offset := 0.0

@onready var sky_layer: ParallaxLayer = $SkyLayer
@onready var clouds_layer: ParallaxLayer = $CloudsLayer
@onready var far_ocean_layer: ParallaxLayer = $FarOceanLayer
@onready var near_ocean_layer: ParallaxLayer = $NearOceanLayer


func _ready() -> void:
	# Set parallax motion scales for depth effect
	sky_layer.motion_scale = Vector2(0.0, 0.0)
	clouds_layer.motion_scale = Vector2(0.1, 0.05)
	far_ocean_layer.motion_scale = Vector2(0.3, 0.2)
	near_ocean_layer.motion_scale = Vector2(0.6, 0.4)


func _process(delta: float) -> void:
	wave_offset += delta
	# Subtle cloud movement
	clouds_layer.motion_offset.x -= delta * 5.0
