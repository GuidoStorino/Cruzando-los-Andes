extends Area2D

@export var nombre_item: String = "Item"
@export var tipo: String = "comida"
@export var cantidad: int = 1
@export var color: Color = Color("#d4820a")

@onready var label = $Label
@onready var rect = $ColorRect

var recogido: bool = false

func _ready() -> void:
	label.text = nombre_item
	rect.color = color

func _process(delta: float) -> void:
	if recogido:
		return
	if not Input.is_action_just_pressed("accion"):
		return
	var jugador = get_tree().current_scene.find_child("Player", true, false)
	if jugador == null:
		return
	if global_position.distance_to(jugador.global_position) < 30:
		recoger()

func recoger() -> void:
	recogido = true
	match tipo:
		"comida":
			GameManager.inventario["comida"] += cantidad
			print("Comida recogida. Total: ", GameManager.inventario["comida"])
		"pala":
			GameManager.inventario["pala"] = true
			print("Pala recogida!")
		"ungüento":
			GameManager.inventario["ungüento"] = true
			print("Ungüento recogido!")
		"piedra_afilar":                                          # ← agregar
			GameManager.inventario["piedra_afilar"] = true
			print("Piedra de afilar recogida!")
		"fusil":                                                  # ← agregar
			GameManager.inventario["fusil"] = true
			GameManager.eventos["fusil_encontrado"] = true
			print("Fusil recogido!")
	visible = false
