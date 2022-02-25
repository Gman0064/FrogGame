extends KinematicBody2D

const TILE_SIZE = 64

onready var raycast = get_node("RayCast2D")
onready var camera = get_node("../Camera2D")
onready var tongue_sprite = get_node("TongueEnd")
onready var max_tongue_pos = get_node("MaxTonguePosition")
onready var enemy_detector = get_node("EnemyRaycast")
onready var tween = get_node("Tween")
onready var rng = RandomNumberGenerator.new()

var chunks = []

var last_chunk = null
var has_moved = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_chunks()


func _input(event):
	if event.is_action_pressed("jump_forward"):
		move_direction("up")
	if event.is_action_pressed("jump_left"):
		move_direction("left")
	if event.is_action_pressed("jump_right"):
		move_direction("right")
	if event.is_action_pressed("attack"):
		extend_tongue()


func _physics_process(delta):
	if(has_moved):
		check_next_chunk()


func move_direction(dir):
	if dir == "up":
		has_moved = true
		self.position.y -= TILE_SIZE
		camera.position.y -= TILE_SIZE
	elif dir == "left":
		has_moved = true
		self.position.x -= TILE_SIZE
	elif dir == "right":
		has_moved = true
		self.position.x += TILE_SIZE


func move_frog(next_pos):
	tween.interpolate_property(self, "position",
		self.position, next_pos, 0.05,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func check_next_chunk():
	if (!raycast.is_colliding()):
		#print("Map chunk not found, spawning...")
		rng.randomize()
		var rand_index = rng.randi_range(0, len(chunks) - 1)
		var new_chunk = load(chunks[rand_index]).instance()
		get_tree().get_current_scene().add_child(new_chunk)
		new_chunk.position.x = last_chunk.position.x
		new_chunk.position.y = (last_chunk.position.y -
								last_chunk.height - 
								new_chunk.height)
	else:
		if (last_chunk == raycast.get_collider()):
			pass
		else:
			#print("Setting last known chunk")
			last_chunk = raycast.get_collider()
	pass


func load_chunks():
	var dir = Directory.new()
	dir.open("res://Assets/Chunks/")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			chunks.append("res://Assets/Chunks/" + file)
	dir.list_dir_end()


func calculate_enemy_distance():
	if(enemy_detector.is_colliding()):
		var enemy = enemy_detector.get_collider()
		var distance = (enemy.position.y - self.position.y)
		print(distance)
		return [distance, (distance * (0.318))]
	else:
		return [-220, -70]


func extend_tongue():
	print("Extending!")
	var distance = calculate_enemy_distance()
	tween.interpolate_property(tongue_sprite, "position",
		Vector2(0, 0), Vector2(0,distance[0]), 0.05,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	print(distance[1])
	tween.interpolate_method(self, "update_tongue_length",
		Vector2(0, 0), Vector2(0,distance[1]), 0.05,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_callback(self, 0.05, "retract_tongue", distance)
	tween.start()


func retract_tongue(distance):
	print("Retracting!")
	tween.interpolate_property(tongue_sprite, "position",
		Vector2(0,distance[0]), Vector2(0, 0), 0.05,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_method(self, "update_tongue_length",
		Vector2(0,distance[1]), Vector2(0, 0), 0.05,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func update_tongue_length(new_pos):
	get_node("TongueBody").set_point_position(1, new_pos)
