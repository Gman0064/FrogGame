extends KinematicBody2D

const TILE_SIZE = 64
const TONGUE_SPEED = 0.1

export var score = 0
export var idle_image : Texture
export var jump_image : Texture

onready var raycast = get_node("RayCast2D")
onready var camera = get_node("../Camera2D")
onready var tongue_sprite = get_node("TongueEnd")
onready var max_tongue_pos = get_node("MaxTonguePosition")
onready var enemy_detector = get_node("EnemyRaycast")
onready var ground_detector = get_node("GroundRaycast")
onready var tween = get_node("Tween")
onready var score_count = get_node("../CanvasLayer/HUD/Score")
onready var game_over_panel = get_node("../CanvasLayer/Panel")
onready var rng = RandomNumberGenerator.new()
onready var audio = get_node("AudioStreamPlayer")
onready var coinsfx = get_node("coinSFX")

var is_on_path = false

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
		#extend_tongue()
		pass


func _physics_process(delta):
	if(has_moved):
		check_next_chunk()
	score_count.text = str(score)
	check_if_on_path()


func die():
	print("Game Over!")
	game_over_panel.visible = true
	game_over_panel.get_node("ScoreVal").text = str(score)
	self.queue_free()


func check_if_on_path():
	var bodies = ground_detector.get_overlapping_bodies()
	if(len(bodies) > 0):
		die()


func collect_coin():
	coinsfx.play()
	score += 1


func move_direction(dir):
	if dir == "up":
		has_moved = true
		move_frog(self.position - Vector2(0, TILE_SIZE))
		camera.position.y -= TILE_SIZE
	elif dir == "left":
		has_moved = true
		move_frog(self.position - Vector2(TILE_SIZE, 0))
	elif dir == "right":
		has_moved = true
		move_frog(self.position + Vector2(TILE_SIZE, 0))


func move_frog(next_pos):
	set_frog_sprite("jump")
	rng.randomize()
	var audio_odds = rng.randi_range(0, 10)
	if (audio_odds > 5):
		audio.play()
	tween.interpolate_property(self, "position",
		self.position, next_pos, 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_callback(self, 0.12, "set_frog_sprite", "idle")
	tween.start()


func set_frog_sprite(cond):
	if (cond == "jump"):
		get_node("Sprite").texture = jump_image
	else:
		get_node("Sprite").texture = idle_image


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
		Vector2(0, 0), Vector2(0,distance[0]), TONGUE_SPEED,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
	tween.interpolate_method(self, "update_tongue_length",
		Vector2(0, 0), Vector2(0,distance[1]), TONGUE_SPEED,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.interpolate_callback(self, TONGUE_SPEED, "retract_tongue", distance)
	
	tween.start()


func retract_tongue(distance):
	print("Retracting!")
	if (enemy_detector.is_colliding()):
		var enemy = enemy_detector.get_collider()
		tween.interpolate_property(enemy, "position",
			enemy.global_position, self.global_position, TONGUE_SPEED,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
		tween.interpolate_callback(enemy, TONGUE_SPEED, "queue_free")
		score += 1
	
	tween.interpolate_property(tongue_sprite, "position",
		Vector2(0,distance[0]), Vector2(0, 0), TONGUE_SPEED,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.interpolate_method(self, "update_tongue_length",
		Vector2(0,distance[1]), Vector2(0, 0), TONGUE_SPEED,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()


func update_tongue_length(new_pos):
	get_node("TongueBody").set_point_position(1, new_pos)
