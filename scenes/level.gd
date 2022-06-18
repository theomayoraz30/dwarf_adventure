extends Node2D

signal scene_changed(levelName);
signal scene_setup(enemyHealth);
signal set_player_health_ui(damage);
signal set_enemy_health_ui(damage);

export var next_level_name = "Fight";
export var next_enemy_health = 20;

# Called when the node enters the scene tree for the first time.

func on_scene_load():
	$player.connect("died", self, "on_player_death");
	$player.connect("damageTaken", self, "on_player_damage_taken");

func cleanup(anim_player):
	if anim_player.is_playing():
		yield(anim_player, "finished");
	emit_signal("scene_setup", next_enemy_health);
	queue_free();

# PLAYER
func on_player_death():
	emit_signal("scene_changed", "GameOver");

func on_player_damage_taken(damage):
	emit_signal("set_player_health_ui", damage);
