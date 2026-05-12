extends Node2D

@onready var dialogo_ui = $DialogoUI

var fase_actual: int = 1

func _ready() -> void:
	dialogo_ui.iniciar_dialogo("ohiggins_encuentro")
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_inicial_terminado, CONNECT_ONE_SHOT)

func _on_dialogo_inicial_terminado() -> void:
	pass

func _process(delta: float) -> void:
	if GameManager.acto_actual == 3:
		verificar_fin_acto3()

func verificar_fin_acto3() -> void:
	if GameManager.eventos["destacamento_derrotado"] and \
	   GameManager.acto_actual == 3:
		GameManager.avanzar_acto()
		iniciar_batalla_chacabuco()

func iniciar_batalla_chacabuco() -> void:
	dialogo_ui.iniciar_dialogo("cabral_antes_chacabuco")
	dialogo_ui.dialogo_terminado.connect(_on_intro_batalla_terminada, CONNECT_ONE_SHOT)

func _on_intro_batalla_terminada() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/combat/batalla_chacabuco.tscn")
