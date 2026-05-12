extends StaticBody2D

@export var nombre: String = "NPC"
@export var id_dialogo: String = ""
@export var es_espia: bool = false
@export var da_sable_corvo: bool = false
@export var es_reclutable: bool = false
@export var da_pista: bool = false
@export var es_cabildo: bool = false
@export var repetible: bool = false

@onready var label = $Label

var dialogo_ui: Node = null
var ya_interactuado: bool = false

func _ready() -> void:
	label.text = nombre
	# Buscar DialogoUI en el árbol de la escena actual
	await get_tree().process_frame
	dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("accion") and not ya_interactuado:
		print("Z presionado. Distancia al jugador: ", _get_distancia())
		if esta_cerca_del_jugador():
			print("Cerca del jugador. DialogoUI: ", dialogo_ui)
			interactuar()

func _get_distancia() -> float:
	var jugador = get_tree().get_root().find_child("Player", true, false)
	if jugador == null:
		print("Jugador no encontrado!")
		return 9999
	return global_position.distance_to(jugador.global_position)

func esta_cerca_del_jugador() -> bool:
	var jugador = get_tree().get_root().find_child("Player", true, false)
	if jugador == null:
		return false
	return global_position.distance_to(jugador.global_position) < 40

func _process1(delta: float) -> void:
	if Input.is_action_just_pressed("accion") and not ya_interactuado:
		print("Z presionado en NPC: ", nombre)
		print("dialogo_ui: ", dialogo_ui)
		print("id_dialogo: ", id_dialogo)
		if esta_cerca_del_jugador():
			print("Cerca del jugador, iniciando diálogo")
			interactuar()
		else:
			print("Lejos del jugador")

func interactuar() -> void:
	if dialogo_ui == null:
		dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)
	if id_dialogo == "" or dialogo_ui == null:
		return
	if dialogo_ui.dialogo_terminado.is_connected(_on_dialogo_terminado):
		dialogo_ui.dialogo_terminado.disconnect(_on_dialogo_terminado)
	
	if es_cabildo:
		_interaccion_cabildo()
		return
	
	print("Conectando signal para NPC: ", nombre)
	dialogo_ui.iniciar_dialogo(id_dialogo)
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _interaccion_cabildo() -> void:
	print("=== CABILDO ===")
	print("espia_descubierto: ", GameManager.eventos["espia_descubierto"])
	print("tiene_sable_corvo: ", GameManager.tiene_sable_corvo)
	print("pistas_recolectadas: ", GameManager.pistas_recolectadas)
	
	if GameManager.eventos["espia_descubierto"] and not GameManager.tiene_sable_corvo:
		dialogo_ui.iniciar_dialogo("cabildo_sable_post_espia")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)
	elif GameManager.pistas_recolectadas >= 3:
		dialogo_ui.iniciar_dialogo("cabildo_alerta")
		dialogo_ui.dialogo_terminado.connect(_on_cabildo_alerta_terminado, CONNECT_ONE_SHOT)
	else:
		dialogo_ui.iniciar_dialogo("cabildo_neutral")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _on_cabildo_alerta_terminado() -> void:
	var mendoza = get_tree().current_scene
	if mendoza.has_method("mostrar_menu_acusacion"):
		mendoza.mostrar_menu_acusacion()

func _on_dialogo_terminado() -> void:
	if da_sable_corvo and not GameManager.tiene_sable_corvo:
		if GameManager.eventos["espia_descubierto"]:
			GameManager.obtener_sable_corvo()

	if es_reclutable and not GameManager.eventos["cabral_reclutado"]:
		GameManager.completar_evento("cabral_reclutado")

	if da_pista and not ya_interactuado:
		GameManager.pistas_recolectadas += 1
		print("Pista sumada. Total: ", GameManager.pistas_recolectadas)

	if es_espia:
		_iniciar_combate_espia()
	elif repetible:
		ya_interactuado = false
	else:
		ya_interactuado = true

func _iniciar_combate_espia() -> void:
	if GameManager.acto_actual == 3:
		GameManager.completar_evento("destacamento_derrotado")
	else:
		GameManager.completar_evento("espia_descubierto")
	GameManager.patrullas_derrotadas += 1
	ya_interactuado = true
	get_tree().call_deferred("change_scene_to_file", "res://scenes/combat/combate.tscn")
	
	
