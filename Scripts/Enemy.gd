extends KinematicBody2D

var spit = preload("res://Assets/EnemySpit.tscn")
onready var player = get_node("../../Player")
onready var audio = get_node("AudioStreamPlayer")
var deltaLimit = 3.5
var deltaElapsed = 0
var rng = RandomNumberGenerator.new()


func _process(delta):
	if (deltaElapsed >= deltaLimit):
		rng.randomize()
		var projectile = spit.instance()
		self.add_child(projectile)
		projectile.rotation_degrees = int(self.rotation_degrees)
		audio.pitch_scale = rng.randf_range(0.75, 1.25)
		audio.play()
		
		deltaElapsed = 0
	else:
		deltaElapsed += delta
