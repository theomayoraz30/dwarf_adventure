extends Area2D

class_name Arrow

onready var player_pos: Vector2 = get_parent().get_node("player").global_position;

var t: float = 0.0;
var knockback_vector = Vector2.ZERO;

func _ready():
	$Timer.connect("timeout", self, "destroy");
	$Timer.start(1);

func _physics_process(delta):
	t += delta * 0.5;
	
	global_position = global_position.linear_interpolate(player_pos, t);
	update();

func _on_arrow_body_entered(body: Node):
#	knockback_vector = 
	if body.is_in_group("enemy"):
		return;
		
	if body.has_method("take_damage"):
		body.take_damage(1, self);
		
	destroy()

func destroy():
	queue_free()
