extends StaticBody2D

const ORIGIN_HEIGHT = 64

var chunks = []

# Called when the node enters the scene tree for the first time.
func _ready():
	load_chunks()
	
	var previous_chunk
	
	for i in range(0,3):
		var chunk = load(chunks[0])
		var new_chunk = chunk.instance()
		print(new_chunk)
		new_chunk.position.x = self.position.x
		
		if (i == 0):
			new_chunk.position.y = (self.position.y - 
									ORIGIN_HEIGHT - 
									new_chunk.height)
		else:
			new_chunk.position.y = (previous_chunk.position.y -
									previous_chunk.height - 
									new_chunk.height)
		
		previous_chunk = new_chunk
		
		get_tree().get_root().get_node("Debug").add_child(new_chunk)


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
