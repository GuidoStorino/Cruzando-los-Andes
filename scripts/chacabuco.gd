extends Node2D

@onready var dialogo_ui = $DialogoUI

func _ready() -> void:
	if not GameManager.mapa_tactico_completado:
		dialogo_ui.iniciar_dialogo("ohiggins_encuentro")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_ohiggins, CONNECT_ONE_SHOT)

func _on_dialogo_ohiggins() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/mapa_tactico.tscn")

func _process(delta: float) -> void:
	if GameManager.acto_actual == 3:
		verificar_fin_acto3()

func verificar_fin_acto3() -> void:
	if GameManager.eventos["destacamento_derrotado"]:
		GameManager.avanzar_acto()
		iniciar_batalla_chacabuco()

func iniciar_batalla_chacabuco() -> void:
	dialogo_ui.iniciar_dialogo("cabral_antes_chacabuco")
	dialogo_ui.dialogo_terminado.connect(_on_intro_batalla_terminada, CONNECT_ONE_SHOT)

func _on_intro_batalla_terminada() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/combat/batalla_chacabuco.tscn")
