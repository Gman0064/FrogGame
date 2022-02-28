extends Area2D

onready var collider = get_node("CollisionShape2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var bodies = self.get_overlapping_bodies()
	if(len(bodies) > 0):
		var player = bodies[0]
		player.collect_coin()
		self.queue_free()
