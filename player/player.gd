extends KinematicBody2D

#Speed for the player
export (int) var speed = 200;

var velocity = Vector2();

func _physics_process(delta):
	var x = Input.get_axis("left", "right");
	var y = Input.get_axis("up", "down");
	var velocity = Vector2(x,y).normalized();
	
	move_and_slide(velocity * speed);

func _ready():
	pass
