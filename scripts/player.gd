extends CharacterBody2D

const SPEED = 80

var dialogo_ui: Node = null
var montado: bool = false  

func _ready() -> void:
	await get_tree().process_frame
	dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)

func _physics_process(delta: float) -> void:
	if dialogo_ui and dialogo_ui.activo:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if GameManager.eventos.get("mula_montada", false) and Input.is_action_just_pressed("montar_mula"):
		montado = not montado
		print("montado: ", montado)

	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_down"):
		direction.y = 1
	if Input.is_action_pressed("ui_up"):
		direction.y = -1

	var velocidad = SPEED * 3 if montado else SPEED
	velocity = direction * velocidad
	move_and_slide()
