extends CanvasLayer

@onready var panel = $Panel
@onready var punto_jugador = $Panel/MapaContenedor/PuntoJugador

# Posiciones del punto en el mapa según zona
const POSICIONES_MAPA = {
	"sur": Vector2(185, 265),
	"oeste": Vector2(65, 175),
	"este": Vector2(305, 175),
	"norte": Vector2(185, 60),
	"campamento": Vector2(185, 175),
}

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mapa"):
		panel.visible = not panel.visible
	
	if panel.visible:
		actualizar_punto_jugador()

func actualizar_punto_jugador() -> void:
	var jugador = get_tree().current_scene.find_child("Player", true, false)
	if jugador == null:
		return
	
	# Determinar zona según posición del jugador en el mapa real
	var pos = jugador.global_position
	var zona = determinar_zona(pos)
	punto_jugador.position = POSICIONES_MAPA[zona]

func determinar_zona(pos: Vector2) -> String:
	# Ajustá estos valores según el tamaño real de tu mapa
	if pos.y < 160:
		return "norte"
	elif pos.y > 320:
		return "sur"
	elif pos.x < 200:
		return "oeste"
	elif pos.x > 400:
		return "este"
	else:
		return "campamento"
