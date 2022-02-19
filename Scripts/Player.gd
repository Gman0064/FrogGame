extends KinematicBody2D

const TILE_SIZE = 64
const CHUNK_LENGTH = 384

onready var raycast = get_node("RayCast2D")
onready var camera = get_node("../Camera2D")

var chunk = preload("res://Assets/DebugChunk.tscn")
var last_chunk = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("jump_forward"):
		move_direction("up")
	if event.is_action_pressed("jump_left"):
		move_direction("left")
	if event.is_action_pressed("jump_right"):
		move_direction("right")


func _process(delta):
	check_next_chunk()


func move_direction(dir):
	if dir == "up":
		self.position.y -= TILE_SIZE
		camera.position.y -= TILE_SIZE
	elif dir == "left":
		self.position.x -= TILE_SIZE
	elif dir == "right":
		self.position.x += TILE_SIZE


func check_next_chunk():
	if (!raycast.is_colliding()):
		print("Map chunk not found, spawning...")
		var new_chunk = chunk.instance()
		get_tree().get_current_scene().add_child(new_chunk)
		new_chunk.position.y = (last_chunk.position.y - CHUNK_LENGTH)
		
	else:
		if (last_chunk == raycast.get_collider()):
			pass
		else:
			print("Setting last known chunk")
			last_chunk = raycast.get_collider()
			
		
	pass
