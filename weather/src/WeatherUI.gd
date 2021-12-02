extends Control
export var weatherNode: NodePath = "../Weather"
onready var weather: Node2D = get_node(weatherNode)

func _ready() -> void:
	
	# APPLY INITIAL WEATHER
	weather.change_weather()

