extends KinematicBody2D

class_name Enemy, "res://icons/goblin-icon.png"

export var ATTACK_STATE_SPEED = 100;
export var PATROL_STATE_SPEED = 50;
export var force: float = 0.1;
export var danger_range = 200;
export var num_rays = 8;
export var attack_range = 100;
export var agro_range = 500;
export var patrol_range = 32;
export var damage = 1;
export var health = 3;


var SPEED: float = 150;

onready var player: KinematicBody2D = get_parent().get_node("player");
onready var spawn_location: Vector2 = global_position;
onready var weapon = $Weapon;
#onready var anim_player := $AnimationPlayer;
onready var anim_player_weapon := $Weapon/AnimationPlayer;

enum { IDLE, PATROL, ATTACK };
var state = IDLE;

var distance_to_player := 0.0;
var direction_to_player := Vector2();

# context array
var ray_directions = []
var interest = []
var danger = []

var chosen_dir := Vector2.ZERO;
var velocity := Vector2.ZERO;
var knockback := Vector2.ZERO;
var knockback_vector = Vector2.LEFT;

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

func _draw():
	for i in num_rays:
		draw_line(Vector2.ZERO, ray_directions[i]*8, Color.white);
		
		if interest[i] && interest[i] > 0:
			draw_line(Vector2.ZERO, ray_directions[i]*10, Color.green);
		
		if danger[i] && danger[i] > 0:
			draw_line(Vector2.ZERO, ray_directions[i]*10, Color.red);

func _physics_process(delta):
	var desired_velocity = chosen_dir * SPEED;
	velocity = velocity.linear_interpolate(desired_velocity, force);
	velocity = move_and_slide(velocity);
	
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta);
	knockback = move_and_slide(knockback)
	knockback_vector = direction_to_player;
	update()

func _process(delta):
	distance_to_player = player.global_position.distance_to(global_position);
	direction_to_player = global_position.direction_to(player.global_position);
	
	# STATE HANDELING
	match state:
		IDLE:
			SPEED = 0;
			idle_state(delta);
		PATROL:
			SPEED = PATROL_STATE_SPEED;
			patrol_state(delta);
		ATTACK:
			SPEED = ATTACK_STATE_SPEED;
			attack_state(delta);

func idle_state(_delta):
	pass

func patrol_state(_delta):
	if not anim_player_weapon.is_playing():
		anim_player_weapon.play("patrol");
	
	if velocity.x > 0:
		$Sprite.scale.x = 1;
		weapon.scale.x = 1
	else:
		$Sprite.scale.x = -1;
		weapon.scale.x = -1

func attack_state(_delta):
	weapon.scale.x = 1
	if player.global_position.x < global_position.x:
		$Sprite.scale.x = -1;
		weapon.scale.y = -1;
	elif player.global_position.x > global_position.x:
		$Sprite.scale.x = 1;
		weapon.scale.y = 1;

func set_attacking_interest():
	for i in num_rays:
		var dir = direction_to_player.cross(ray_directions[i]);
		interest[i] = max(0, dir);

func set_idle_interest():
	for i in num_rays:
		interest[i] = 1.0;

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
	randomize()
	patrol_position = Vector2(
		rand_range(spawn_location.x - patrol_range, spawn_location.y + patrol_range),
		rand_range(spawn_location.x - patrol_range, spawn_location.y + patrol_range)
	)
	
func take_damage(damage):
	health -= damage;
	player.knockback_vector = player.global_position.direction_to(global_position);
	knockback = player.knockback_vector * 100;
	if health <= 0:
		die();

func die():
	pass;
