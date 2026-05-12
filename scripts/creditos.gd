extends CanvasLayer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("accion"):
		reiniciar_juego()

func reiniciar_juego() -> void:
	# Resetear el GameManager para una nueva partida
	GameManager.acto_actual = 1
	GameManager.tiene_sable_corvo = false
	GameManager.sable_corvo_equipado = false
	GameManager.patrullas_derrotadas = 0
	for evento in GameManager.eventos:
		GameManager.eventos[evento] = false
	GameManager.recursos = {
		"comida": 100,
		"municion": 100,
		"soldados": 100,
	}
	get_tree().change_scene_to_file("res://scenes/world/mendoza.tscn")
