extends Enemy

class_name EnemyRanged, "res://icons/bow-icon.png"

export(PackedScene) var arrow;
export var flee_range = 200;
export var ARROW_SPEED = 500

func idle_state(_delta):
	# Play animation or something
	set_idle_interest();
	set_danger();
	choose_direction();

func patrol_state(delta):
	.patrol_state(delta) # Calling base function
	set_patrol_interest();
	set_danger();
	choose_direction();
	
	if global_position.distance_to(patrol_position) < 20:
		state = IDLE;
	
	if distance_to_player < agro_range:
		state = ATTACK;
		
func attack_state(delta):
	.attack_state(delta) # Calling base function
	set_attack_interest(direction_to_player);
	set_danger(player.global_position)
	
	var rot = get_angle_to(player.global_position);
	weapon.rotation = rot;
	
	if distance_to_player < attack_range:
#		ROTATE AROUND PLAYER
		set_attacking_interest();

		if not anim_player_weapon.is_playing():
			anim_player_weapon.play("attack");
	
	if distance_to_player > agro_range:
		state = PATROL;
	
	choose_direction();

func set_patrol_interest():
	for i in num_rays:
		var dir = ray_directions[i].dot(global_position.direction_to(patrol_position));
		interest[i] = max(0, dir);
		
func set_attack_interest(direction):
	for i in num_rays:
		var dir = ray_directions[i].dot(direction);
		interest[i] = max(0, dir);

func timer_timeout():
	if state == IDLE:
		state = PATROL;
		get_random_patrol_point();
	elif state == PATROL:
		state = IDLE;
	
	$Timer.start(rand_range(2, 5));

func _on_anim_player_animation_finished(anim_name):
	if anim_name == "attack":
		shoot();

func shoot():
	var a: Arrow = arrow.instance();
	get_parent().add_child(a);
	a.global_position = self.global_position;
	a.rotation = get_angle_to(player.global_position)
