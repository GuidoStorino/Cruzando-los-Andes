extends Node2D

@onready var dialogo_ui = $DialogoUI

func _ready() -> void:
	dialogo_ui.iniciar_dialogo("cabral_travesia")
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _on_dialogo_terminado() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/segmento_travesia.tscn")
