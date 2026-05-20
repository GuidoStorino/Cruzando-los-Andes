extends Node2D

@onready var dialogo_ui = $DialogoUI

func _ready() -> void:
	dialogo_ui.iniciar_dialogo("cabral_acto2_inicio")
	
	# Ocultar patrullas ya vencidas
	for p in $Objetos/Patrullas.get_children():
		if p.nombre in GameManager.patrullas_vencidas_acto2:
			p.visible = false
			p.ya_interactuado = true
