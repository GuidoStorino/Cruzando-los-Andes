extends Area2D

@export var nombre_item: String = "Item"
@export var tipo: String = "comida" # "comida", "pala", "ungüento"
@export var cantidad: int = 1
@export var color: Color = Color("#d4820a")

@onready var label = $Label
@onready var rect = $ColorRect

var recogido: bool = false
var jugador_cerca: bool = false
var dialogo_ui: Node = null

func _ready() -> void:
	label.text = nombre_item
	rect.color = color
	await get_tree().process_frame
	dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		jugador_cerca = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		jugador_cerca = false

func _process(delta: float) -> void:
	if recogido:
		return
	if jugador_cerca and Input.is_action_just_pressed("accion"):
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
	visible = false
