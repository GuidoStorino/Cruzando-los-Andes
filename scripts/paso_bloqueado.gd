extends StaticBody2D

var dialogo_ui: Node = null
var desbloqueado: bool = false
var jugador_cerca: bool = false

func _ready() -> void:
	await get_tree().process_frame
	dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)

func _process(delta: float) -> void:
	if desbloqueado:
		return
	if jugador_cerca and Input.is_action_just_pressed("accion"):
		intentar_desbloquear()
	
	# Detectar cercanía manualmente
	var jugador = get_tree().current_scene.find_child("Player", true, false)
	if jugador == null:
		return
	jugador_cerca = global_position.distance_to(jugador.global_position) < 40

func intentar_desbloquear() -> void:
	if GameManager.inventario["pala"]:
		dialogo_ui.iniciar_dialogo("paso_bloqueado_con_pala")
		dialogo_ui.dialogo_terminado.connect(_on_desbloqueado, CONNECT_ONE_SHOT)
	else:
		dialogo_ui.iniciar_dialogo("paso_bloqueado_sin_pala")

func _on_desbloqueado() -> void:
	desbloqueado = true
	$CollisionShape2D.disabled = true
	visible = false
	GameManager.completar_evento("paso_desbloqueado")
