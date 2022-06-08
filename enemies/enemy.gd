extends KinematicBody2D

class_name Enemy, "res://goblin-icon.png"

export var ATTACK_STATE_SPEED = 100;
export var PATROL_STATE_SPEED = 50;
export var force: float = 0.1;
export var danger_range = 200;
export var num_rays = 8;
export var attack_range = 100;
export var agro_range = 500;
export var patrol_range = 32;
export var damage = 5;

var SPEED: float = 150;

onready var player: KinematicBody2D = get_parent().get_node("player");
onready var spawn_location: Vector2 = global_position;

enum { IDLE, PATROL, ATTACK };
var state = IDLE;

var distance_to_player = Vector2();
var direction_to_player = Vector2();

# context array
var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO;
var velocity = Vector2.ZERO;

var patrol_position = Vector2.ZERO;

func _ready():
	setup_rays();
	get_random_patrol_point()

	var err = $Timer.connect("timeout", self, "timer_timeout");
	if err: print_debug(err)
	else:
		$Timer.start(rand_range(2, 5));

func setup_rays():
	interest.resize(num_rays);
	danger.resize(num_rays);
	ray_directions.resize(num_rays);
	for i in num_rays:
		var angle = i * 2 * PI / num_rays;
		ray_directions[i] = Vector2.RIGHT.rotated(angle);

func _physics_process(_delta):
	var desired_velocity = chosen_dir * SPEED;
	velocity = velocity.linear_interpolate(desired_velocity, force);
	velocity = move_and_slide(velocity);
	
func _process(delta):
	distance_to_player = player.global_position.distance_to(global_position);
	direction_to_player = global_position.direction_to(player.global_position);
	
	# STATE HANDELING
	match state:
		IDLE: idle_state(delta);
		PATROL: patrol_state(delta);
		ATTACK: attack_state(delta);

func idle_state(_delta):
	pass

func patrol_state(_delta):
	pass

func attack_state(_delta):
	pass


func set_idle_interest():
	for i in num_rays:
		interest[i] = 0;
		
func set_danger(danger_body = null):
	var space_state = get_world_2d().direct_space_state;
	for i in num_rays:
		var res = space_state.intersect_ray(position, position + ray_directions[i] * danger_range, [self, danger_body]);
		danger[i] = 1.0 if res else 0.0;

func choose_direction():
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	
	chosen_dir = Vector2.ZERO;
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i];
		chosen_dir.normalized();

func get_random_patrol_point():
	patrol_position = Vector2(
		rand_range(spawn_location.x - patrol_range, spawn_location.y + patrol_range),
		rand_range(spawn_location.x - patrol_range, spawn_location.y + patrol_range)
	)
