extends StaticBody

var _owner = null

func _ready():
	pass

func init(owner):
	_owner = owner

func takeHit(damage):
	_owner.takeHit(damage)