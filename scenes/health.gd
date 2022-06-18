extends HBoxContainer


var heart_full = preload("res://UI/full.png")
var heart_empty = preload("res://UI/empty.png")
var heart_half = preload("res://UI/half.png")

func update_health(hp):
	for i in get_child_count():
		if hp > i * 2 + 1:
			get_child(i).texture = heart_full
		elif hp > i * 2:
			get_child(i).texture = heart_half
		else:
			get_child(i).texture = heart_empty
