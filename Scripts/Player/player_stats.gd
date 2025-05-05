extends Node

class_name Health
var hp = 100

func take_damage(amount):
	hp -= amount
	
	
func _ready():
	print($".".name ," hp = ", hp)
