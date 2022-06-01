extends KinematicBody2D

export var SPEED: float = 200;

onready var player: KinematicBody2D = get_parent().get_node("Dwarf");

func _physics_process(delta):
	var distanceToPlayer = player.global_position.distance_to(global_position);
	var directionToPlayer = global_position.direction_to(player.global_position);
	var directionAwayFromPlayer = player.global_position.direction_to(global_position);
	
	if distanceToPlayer < 500 && distanceToPlayer > 150:
		move_and_slide(directionToPlayer * SPEED);
	
	elif distanceToPlayer <= 150 && distanceToPlayer > 100:
		pass # ATTACK
		
	elif distanceToPlayer <= 100:
		move_and_slide(directionAwayFromPlayer * SPEED);
