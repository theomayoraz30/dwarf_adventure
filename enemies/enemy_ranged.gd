extends Enemy

class_name EnemyRanged, "res://bow-icon.png"

export var flee_range = 200
onready var anim_player: AnimationPlayer = $AnimationPlayer;

func idle_state(_delta):
	# Play animation or something
	set_idle_interest();
	set_danger();
	choose_direction();

func patrol_state(_delta):
	set_patrol_interest();
	set_danger();
	choose_direction();
	
	if global_position.distance_to(patrol_position) < 20:
		state = IDLE;
	
	if distance_to_player < agro_range:
		state = ATTACK;
		SPEED = ATTACK_STATE_SPEED;
		
func attack_state(_delta):
	set_attack_interest(direction_to_player);
	set_danger(player);
	
	if player.global_position.x < global_position.x:
		$Sprite.scale.x = 5;
		$Weapon.scale.x = 1;
	elif player.global_position.x > global_position.x:
		$Sprite.scale.x = -5;
		$Weapon.scale.x = -1;
	
	if distance_to_player < attack_range:
		set_idle_interest()
		if not anim_player.is_playing():
			anim_player.play("attack");
			
	if distance_to_player < flee_range:
		set_attack_interest(-direction_to_player)
	
	if distance_to_player > agro_range:
		state = PATROL;
		SPEED = PATROL_STATE_SPEED;
		
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
		patrol_position = Vector2.ZERO;
		velocity = Vector2.ZERO;
		
	print("Timer timeout");
	$Timer.start(rand_range(2, 5));
