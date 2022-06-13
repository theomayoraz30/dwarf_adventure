extends Area2D

class_name Arrow

var t: float = 0.0;
onready var player_pos: Vector2 = get_parent().get_node("player").global_position;

func _ready():
	$Timer.connect("timeout", self, "destroy");
	$Timer.start(1.5);

func _physics_process(delta):
	t += delta * 0.2;
	
	global_position = global_position.linear_interpolate(player_pos, t);
	update();

func _on_arrow_body_entered(body: Node):
	if body.is_in_group("enemy"):
		return;
		
	if body.has_method("take_damage"):
		body.take_damage(1);
		
	destroy()

func destroy():
	queue_free()
