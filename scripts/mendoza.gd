extends Node2D

@onready var dialogo_ui = $DialogoUI
@onready var menu_acusacion = $MenuAcusacion
@onready var boton_quiroga = $MenuAcusacion/Panel/BotonQuiroga
@onready var boton_ramos = $MenuAcusacion/Panel/BotonRamos
@onready var boton_lopez = $MenuAcusacion/Panel/BotonLopez
@onready var boton_perez = $MenuAcusacion/Panel/BotonPerez
@onready var boton_cabral = $MenuAcusacion/Panel/BotonCabral
@onready var boton_salir = $MenuAcusacion/Panel/BotonSalir

func _ready() -> void:
	dialogo_ui.iniciar_dialogo("intro_sanmartin")
	boton_quiroga.pressed.connect(_on_acusar.bind("quiroga"))
	boton_ramos.pressed.connect(_on_acusar.bind("ramos"))
	boton_lopez.pressed.connect(_on_acusar.bind("lopez"))
	boton_perez.pressed.connect(_on_acusar.bind("perez"))
	boton_cabral.pressed.connect(_on_acusar.bind("cabral"))
	boton_salir.pressed.connect(_on_salir_menu)
	
	# Ocultar Quiroga si ya fue derrotado
	if GameManager.eventos["espia_descubierto"]:
		var quiroga = get_tree().current_scene.find_child("Quiroga", true, false)
		if quiroga:
			quiroga.visible = false

func _process(delta: float) -> void:
	if GameManager.acto_actual == 1:
		verificar_fin_acto1()

func verificar_fin_acto1() -> void:
	if GameManager.eventos["cabral_reclutado"] and \
	   GameManager.tiene_sable_corvo and \
	   GameManager.eventos["espia_descubierto"]:
		GameManager.avanzar_acto()
		dialogo_ui.iniciar_dialogo("cabral_travesia")
		dialogo_ui.dialogo_terminado.connect(_on_intro_acto2_terminada, CONNECT_ONE_SHOT)

func _on_intro_acto2_terminada() -> void:
	get_tree().change_scene_to_file("res://scenes/world/travesia2.tscn")

func mostrar_menu_acusacion() -> void:
	menu_acusacion.visible = true

func _on_salir_menu() -> void:
	menu_acusacion.visible = false

func _on_acusar(sospechoso: String) -> void:
	menu_acusacion.visible = false
	if sospechoso == "quiroga":
		dialogo_ui.iniciar_dialogo("acusacion_correcta")
		dialogo_ui.dialogo_terminado.connect(_on_acusacion_correcta, CONNECT_ONE_SHOT)
	else:
		dialogo_ui.iniciar_dialogo("acusacion_incorrecta")
		dialogo_ui.dialogo_terminado.connect(_on_acusacion_fallida, CONNECT_ONE_SHOT)

func _on_acusacion_fallida() -> void:
	await get_tree().create_timer(0.5).timeout
	menu_acusacion.visible = true

func _on_acusacion_correcta() -> void:
	var quiroga = get_tree().current_scene.find_child("Quiroga", true, false)
	if quiroga:
		quiroga.es_espia = true
		quiroga.ya_interactuado = false
		quiroga.interactuar()
