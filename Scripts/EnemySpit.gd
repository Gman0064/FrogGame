extends KinematicBody2D

var speed = 450

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (self.rotation_degrees == -90):
		move_and_slide(Vector2.RIGHT * speed)
	elif (self.rotation_degrees == 0) :
		move_and_slide(Vector2.DOWN * speed)
	elif (self.rotation_degrees == 90):
		move_and_slide(Vector2.LEFT * speed)
	elif (self.rotation_degrees == 180 || self.rotation == -180):
		move_and_slide(Vector2.UP * speed)
	
	for i in get_slide_count():
		var player = get_slide_collision(i).collider
		player.die()

