extends KinematicBody2D

# Speed for the player
export (int) var SPEED = 200;
export (int) var MAX_HEALTH = 6; # 1 heart = 2 hps
export (int) var health = 6; # 1 heart = 2 hps
export (int) var damage = 1;
onready var anim_player = $AnimationPlayer

onready var weapon = $Weapon
onready var anim_player_weapon = $Weapon/AnimationPlayer

var velocity = Vector2.ZERO;
var knockback = Vector2.ZERO;
var knockback_vector = Vector2.ZERO;

func _physics_process(delta):
	var x = Input.get_axis("left", "right");
	var y = Input.get_axis("up", "down");
	velocity = Vector2(x,y).normalized();
	
	if velocity != Vector2.ZERO:
		anim_player.play("move");
	else:
		anim_player.stop(true);
	
	velocity = move_and_slide(velocity * SPEED);
	
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta);
	knockback = move_and_slide(knockback)

func take_damage(damage, enemy):
	health -= damage;
	knockback = enemy.knockback_vector * 100;
	if health <= 0:
		die();

func die():
	pass;

func _process(_delta):
	sword_to_mouse();
	flip();
	if Input.get_action_strength("attack"):
		anim_player_weapon.play("attack");

func sword_to_mouse():
	var mouse_pos = get_global_mouse_position();
	var rot = get_angle_to(mouse_pos);
		
	weapon.rotation = rot;

func flip():
	var mouse_pos := get_global_mouse_position();
	if mouse_pos.x > global_position.x:
		$AnimatedSprite.scale.x = 1;
		weapon.scale.y = 1;
	elif mouse_pos.x < global_position.x:
		$AnimatedSprite.scale.x = -1;
		weapon.scale.y = -1;

func _on_weapon_body_entered(body):
	if body.is_in_group("enemy") && body.has_method("take_damage"):
		body.knockback_vector = body.global_position.direction_to(global_position)
		body.take_damage(damage);
