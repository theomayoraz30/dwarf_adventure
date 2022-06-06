extends KinematicBody2D

# Speed for the player
export (int) var SPEED = 200;
export (int) var MAX_HEALTH = 6; # 1 heart = 2 hps
export (int) var health = 6; # 1 heart = 2 hps

var velocity = Vector2();

# this will execute often
func _physics_process(_delta):
	var x = Input.get_axis("left", "right");
	var y = Input.get_axis("up", "down");
	velocity = Vector2(x,y).normalized();
	
	velocity = move_and_slide(velocity * SPEED);

func take_damage(damage):
	health -= damage
	if health <= 0:
		die();

func die():
	pass
