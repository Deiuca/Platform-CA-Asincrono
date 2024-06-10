extends Node2D

var generator = preload("res://generatore_livello.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("ui_accept"):
		for c in self.get_children():
			self.remove_child(c)
			c.queue_free()
		add_child(generator.instantiate())
		
	if Input.is_key_pressed(KEY_I):
		var gl = self.get_child(0)
		gl.cellular_automata()
