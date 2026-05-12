extends CharacterBody2D

const SPEED = 80

var dialogo_ui: Node = null

func _ready() -> void:
	await get_tree().process_frame
	dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)

func _physics_process(delta: float) -> void:
	if dialogo_ui and dialogo_ui.activo:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_down"):
		direction.y = 1
	if Input.is_action_pressed("ui_up"):
		direction.y = -1

	velocity = direction * SPEED
	move_and_slide()
