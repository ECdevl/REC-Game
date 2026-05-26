class_name BaseState
extends State

var player: Player 

func _ready():
	player = owner as Player

func enter(_previous_state_path: String, _data := {}) -> void:
	pass