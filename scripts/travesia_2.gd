extends Node2D

@onready var dialogo_ui = $DialogoUI

func _ready() -> void:
	# Restaurar posición del jugador si venimos de un combate
	if GameManager.posicion_guardada != Vector2.ZERO:
		var jugador = $Player
		jugador.global_position = GameManager.posicion_guardada
		GameManager.posicion_guardada = Vector2.ZERO
	
	# Ocultar patrullas ya vencidas
	for p in $Objetos/Patrullas.get_children():
		if str(p.global_position) in GameManager.patrullas_vencidas_acto2:
			p.visible = false
			p.ya_interactuado = true
