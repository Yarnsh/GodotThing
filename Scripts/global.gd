extends Node

var id_lock = Mutex.new()
var next_id = 0

var particles
var bulletScene
var currentNav

var WEAPONS = [
	load("res://Scripts/weapon.gd").new("NONE", "NONE", 99999.0),
	load("res://Scripts/weapon.gd").new("Gattling Gun", "res://Things/Weapons/STANDARD_gattlinggun.dae", 0.083),
	load("res://Scripts/weapon.gd").new("Howitzer", "res://Things/Weapons/STANDARD_howitzer.dae", 1.2)
]

var bodyPart = "res://Things/Mechs/AdamMk2/ADAMmk2_body.dae"
var legPart = "res://Things/Mechs/AdamMk2/ADAMmk2_legs.dae"
var lWepPart = [WEAPONS[0]]
var rWepPart = [WEAPONS[0]]

var color1 = Color(0,0,0)
var pattern1 = "res://Things/Patterns/plain.png"
var color2 = Color(0,0,0)
var pattern2 = "res://Things/Patterns/plain.png"

func getId():
	id_lock.lock()
	var ret_id = next_id
	next_id += 1
	id_lock.unlock()
	return ret_id

func _ready():
	particles = preload("res://Particles.tscn")
	bulletScene = preload("res://Bullet.tscn")

func closerDirVector(start, end, amount): #takes unit vectors only
	var axis = start.cross(end)
	if (!(axis.length_squared() > 0.0)):
		axis = Vector3(0.0,1.0,0.0)
	axis = axis.normalized()
	var endQ = Quat(axis, min(amount, abs(start.angle_to(end))))
	return endQ.xform(start)