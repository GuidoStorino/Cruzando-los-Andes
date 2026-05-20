extends Area2D

@export var escena_destino: String = ""
@export var requiere_evento: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return
	if requiere_evento != "" and not GameManager.eventos[requiere_evento]:
		return
	if escena_destino != "":
		GameManager.avanzar_acto()
		get_tree().call_deferred("change_scene_to_file", escena_destino)
