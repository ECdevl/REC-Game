extends Node

var UINode : Control
var debug_menu : Panel
var texto : String = ""
var fps : float
var player : Player

func _ready() -> void:
	pass

func _enter_tree() -> void:
	UINode = get_parent()
	if UINode:
		player = get_parent().get_parent()
		var debug_panel = Panel.new()
		debug_panel.pivot_offset = Vector2(860/2,242/2)
		debug_panel.size = Vector2(860,242)
		debug_panel.hide()
		var debug_label = Label.new()
		debug_label.name = "debug_label"
		debug_label.text = ""
		debug_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		debug_panel.add_child.call_deferred(debug_label)
		UINode.add_child.call_deferred(debug_panel)
		debug_menu = debug_panel
		

func _process(delta: float) -> void:
	fps = Engine.get_frames_per_second()
	var values : Dictionary = {
		"FPS": fps,
		"velocidad jugador": player.current_speed,
		"Direccion Jugador": player.velocity,
		"Direccion Teclas Jugador": player.input_dir,
		"Resistencia": player.get_node("StaminaComponent").stamina,
		"Podes correr?": player.get_node("StaminaComponent").can_run,
		"Estas Corriendo?": player.get_node("StaminaComponent").is_run
	}

	if UINode:
		var debuglab = debug_menu.get_node("debug_label")
		var texto = var_to_str(values)
		var final_text = texto.replace("{"," ").replace("}","").replacen('"',"").replacen(',',"")
		debuglab.text = final_text
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debugMenu"):
		debug_menu.visible = !debug_menu.visible
