extends Area2D

@onready var dialogo_ui: Node = null

func _ready() -> void:
	await get_tree().process_frame
	dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)

func _process(delta: float) -> void:
	if not Input.is_action_just_pressed("accion"):
		return
	if not esta_cerca_del_jugador():
		return
	if GameManager.pistas_recolectadas >= 3:
		mostrar_menu_acusacion()
	else:
		print("Necesitás hablar con todos los soldados primero.")

func esta_cerca_del_jugador() -> bool:
	var jugador = get_tree().current_scene.find_child("Player", true, false)
	if jugador == null:
		return false
	return global_position.distance_to(jugador.global_position) < 40

func mostrar_menu_acusacion() -> void:
	var mendoza = get_tree().current_scene
	if mendoza.has_method("mostrar_menu_acusacion"):
		mendoza.mostrar_menu_acusacion()
