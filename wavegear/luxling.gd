extends Node2D

var spritesheets = {
	Aqua=preload("res://AquaV1Sheet.png"),
	Fulgur=preload("res://FulgurV1Sheet.png"),
	Ignis=preload("res://IgnisV1Sheet.png"),
	Petra=preload("res://PetraV1Sheet.png"),
	Ventus=preload("res://VentusV1Sheet.png")
}

@export_enum("Aqua", "Fulgur", "Ignis", "Petra", "Ventus") var element:String


# Called when the node enters the scene tree for the first time.
func _ready():
	$Luxling.texture = spritesheets[element]
	$Luxling/AnimationPlayer.play("move")
