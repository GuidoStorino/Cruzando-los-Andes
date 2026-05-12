extends CanvasLayer

var puede_continuar: bool = false

func _ready() -> void:
	# Esperar un segundo antes de permitir avanzar
	await get_tree().create_timer(1.0).timeout
	puede_continuar = true

func _process(delta: float) -> void:
	if puede_continuar and Input.is_action_just_pressed("accion"):
		get_tree().change_scene_to_file("res://scenes/world/mendoza.tscn")
