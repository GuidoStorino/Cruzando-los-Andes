extends Node2D

@onready var dialogo_ui = $DialogoUI

func _ready() -> void:
	# Secuencia de diálogos final
	dialogo_ui.iniciar_dialogo("fin_batalla")
	dialogo_ui.dialogo_terminado.connect(_on_fin_batalla, CONNECT_ONE_SHOT)

func _on_fin_batalla() -> void:
	dialogo_ui.iniciar_dialogo("rechazo_gobierno")
	dialogo_ui.dialogo_terminado.connect(_on_rechazo_gobierno, CONNECT_ONE_SHOT)

func _on_rechazo_gobierno() -> void:
	dialogo_ui.iniciar_dialogo("cabral_final")
	dialogo_ui.dialogo_terminado.connect(_on_cabral_final, CONNECT_ONE_SHOT)

func _on_cabral_final() -> void:
	mostrar_creditos()

func mostrar_creditos() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/creditos.tscn")
