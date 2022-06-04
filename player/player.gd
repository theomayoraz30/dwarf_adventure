extends KinematicBody2D

#Speed for the player
export (float) var speed = 200;
onready var anim_player = $Weapon/AnimationPlayer

var velocity = Vector2();

func _physics_process(delta):
	var x = Input.get_axis("left", "right");
	var y = Input.get_axis("up", "down");
	velocity = Vector2(x,y).normalized();
	move_and_slide(velocity * speed);

	
func _process(delta):
	if Input.get_action_strength("attack"):
		anim_player.play("attack");
		
		
func _ready():
	pass
	
