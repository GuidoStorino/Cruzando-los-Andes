extends StaticBody2D

var dialogo_ui: Node = null
var curada: bool = false
var jugador_cerca: bool = false

func _ready() -> void:
	await get_tree().process_frame
	dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)

func _process(delta: float) -> void:
	if curada:
		return
	
	var jugador = get_tree().current_scene.find_child("Player", true, false)
	if jugador == null:
		return
	jugador_cerca = global_position.distance_to(jugador.global_position) < 40
	
	if jugador_cerca and Input.is_action_just_pressed("accion"):
		intentar_curar()

func intentar_curar() -> void:
	if GameManager.inventario["ungüento"]:
		dialogo_ui.iniciar_dialogo("mula_con_ungüento")
		dialogo_ui.dialogo_terminado.connect(_on_mula_curada, CONNECT_ONE_SHOT)
	else:
		dialogo_ui.iniciar_dialogo("mula_sin_ungüento")

func _on_mula_curada() -> void:
	curada = true
	GameManager.completar_evento("mula_curada")
	dialogo_ui.iniciar_dialogo("soldado_perdido_encontrado")
	dialogo_ui.dialogo_terminado.connect(_on_soldado_encontrado, CONNECT_ONE_SHOT)

func _on_soldado_encontrado() -> void:
	GameManager.completar_evento("soldado_encontrado")
