extends Node

var id_lock = Mutex.new()
var next_id = 0

var particles

func getId():
	id_lock.lock()
	var ret_id = next_id
	next_id += 1
	id_lock.unlock()
	return ret_id

func _ready():
	particles = preload("res://Particles.tscn")