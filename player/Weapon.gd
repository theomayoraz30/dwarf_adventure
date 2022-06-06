extends Area2D
export var damage: float = 10

func _on_Weapon_body_entered(Enemy): 
	if(Enemy.has_method("take_dammage")): 
		Enemy.take_damage(damage);
		
func _ready():
	pass
	
