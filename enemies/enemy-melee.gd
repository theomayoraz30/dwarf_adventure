extends KinematicBody2D

export var ATTACK_STATE_SPEED = 100;
export var PATROL_STATE_SPEED = 50;
export var force: float = 0.1;
export var danger_range = 200;
export var num_rays = 8;

var SPEED: float = 150;

onready var player: KinematicBody2D = get_parent().get_node("Dwarf");
onready var spawn_location: Vector2 = global_position;

enum { PATROL, ATTACK };
var state = PATROL;

var distance_to_player = Vector2();
var direction_to_player = Vector2();

# context array
var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO;
var velocity = Vector2.ZERO;

var patrol_direction = Vector2.ZERO;

var noise = OpenSimplexNoise.new()

func _ready():
	configure_noise();
	setup_rays();
	
	$Timer.connect("timeout", self, "timer_timeout");
	$Timer.start(rand_range(2, 5));

func setup_rays():
	interest.resize(num_rays);
	danger.resize(num_rays);
	ray_directions.resize(num_rays);
	for i in num_rays:
		var angle = i * 2 * PI / num_rays;
		ray_directions[i] = Vector2.RIGHT.rotated(angle);
		print(ray_directions[i])
	
func _process(delta):
	distance_to_player = player.global_position.distance_to(global_position);
	direction_to_player = global_position.direction_to(player.global_position);
	
	# STATE HANDELING
	match state:
		PATROL: patrol_state(delta);
		ATTACK: attack_state(delta);

func _physics_process(delta):
	var desired_velocity = chosen_dir * SPEED;
	velocity = velocity.linear_interpolate(desired_velocity, force);
	move_and_slide(velocity);

func patrol_state(delta):
	set_patrol_interest();
	set_patrol_danger();
	choose_patrol_direction();
	
	if distance_to_player < 500:
		state = ATTACK;
		SPEED = ATTACK_STATE_SPEED;

func attack_state(delta):
	set_attack_interest();
	set_attack_danger();
	choose_attack_direction();
	
	if distance_to_player > 500:
		state = PATROL;
		SPEED = PATROL_STATE_SPEED;

func set_patrol_interest():
	for i in num_rays: 
			
		var dir = ray_directions[i].dot(patrol_direction);
		interest[i] = max(0, dir);
		# print(interest[i])
	
#	print("_____________")

func set_patrol_danger():
	var space_state = get_world_2d().direct_space_state;
	for i in num_rays:
		var res = space_state.intersect_ray(position, position + ray_directions[i] * danger_range, [self]);
		danger[i] = 1.0 if res else 0.0;

func choose_patrol_direction():
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0

	chosen_dir = Vector2.ZERO;
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i];
		chosen_dir.normalized();


func set_attack_interest():
	for i in num_rays:
		var dir = ray_directions[i].dot(direction_to_player);
		interest[i] = max(0, dir);

func set_attack_danger():
	var space_state = get_world_2d().direct_space_state;
	for i in num_rays:
		var res = space_state.intersect_ray(position, position + ray_directions[i] * danger_range, [self]);
		danger[i] = 1.0 if res else 0.0;

func choose_attack_direction():
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	
	chosen_dir = Vector2.ZERO;
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i];
		chosen_dir.normalized();

func timer_timeout():
	pass
	if patrol_direction == Vector2.ZERO:
		patrol_direction = ray_directions[rand_range(0, ray_directions.size())];
	else:
		patrol_direction = Vector2.ZERO;
	print("Timer timeout");
	$Timer.start(rand_range(2, 5));

func configure_noise():
	# Configure
	randomize();
	noise.seed = randi();
	noise.octaves = 4
#	noise.period = 20.0
	noise.persistence = 0.8
