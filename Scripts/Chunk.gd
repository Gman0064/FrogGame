extends StaticBody2D

export var height = 0

onready var player = get_node("../Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if (position):
		if (self.position.y > (player.position.y + 400)):
			self.queue_free()
