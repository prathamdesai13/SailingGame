extends Node2D

export (String, 'rain') var weatherType = 'sun'
export (float, -1, 1) var wind = 0
export (float, 0, 1) var size = 0.3
export (int, 100, 3000) var amount = 1000
export (float, 1, 300) var weatherChangeTime = 2

var nightColor: Color = Color.white # color SUBTRACTED to scene

# You can set this to the Player or another node you want the weather system to "follow".
# This way the weather effect will always be visible
export var followNode: NodePath # = "../Player"

onready var rain = $Rain
onready var tween = $Tween

# Emiter folows position of this node.
onready var follow: Node2D = get_node_or_null(followNode) # Thanks KamiGrave for this tip!!

# Set from WeatherControl to ignores last weather change
var last_control: Control
var last_amount: int


func _ready() -> void:
	change_weather()
	set_source()
	
func set_source() -> void:
	position = get_viewport_transform().get_origin() + Vector2(get_viewport_rect().size.x / 2, 0) # Initially positions the emiter in the top center of the screen
	rain.process_material.emission_box_extents.x = get_viewport_rect().size.x * 2 # Sets emiter width to N times the screen size

func _physics_process(_delta: float) -> void:
	if follow:
		position = follow.position + Vector2(0, -get_viewport_rect().size.y) # Weather follows the position of node in "follow"
	
func change_weather():

	if weatherType == 'rain':
		change_amount(rain, amount)
		apply_rain_settings()
		rain.emitting = true
	else: 
		rain.emitting = false
	last_amount = amount
	
func apply_rain_settings():
	
	# RAIN SETTINGS
	change_size(rain, size) # rain.process_material.anim_offset = size
	
	# RAIN WIND SETTINGS
	# 0.5 + abs(wind) / 2
	change_wind_speed(rain, 0.5 + abs(wind) / 2) # rain.speed_scale = 0.5 + abs(wind) / 2 + size / 2
	change_wind_direction(rain, wind) # rain.process_material.direction.x = wind
	rain.process_material.gravity.x = 10 * wind

func change_size(weather, new_size):
	
	tween.interpolate_property(weather, "process_material:anim_offset",
	weather.process_material.anim_offset, new_size, weatherChangeTime,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func change_amount(weather, new_amount):
	
	if last_amount != amount: # PROBLEM!! Changing amount resets particle emiter!!!
		if weather.emitting == true: weather.preprocess = weather.lifetime * 2
		weather.amount = amount
	else: weather.preprocess = 0

func change_wind_direction(weather, new_wind):
	
	tween.interpolate_property(weather, "process_material:direction:x",
	weather.process_material.direction.x, new_wind, weatherChangeTime,
	Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func change_wind_speed(weather, new_speed):
	
	tween.interpolate_property(weather, "speed_scale",
	weather.speed_scale, new_speed, weatherChangeTime,
	Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.start()
