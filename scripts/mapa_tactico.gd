extends Node2D

# Posiciones posibles para cada columna
const POSICIONES = ["izquierda", "centro", "derecha"]
const POS_X = {"izquierda": 60, "centro": 220, "derecha": 380}

# Estado de las columnas
var columnas = [
	{"posicion": "izquierda", "fuerzas": 0},
	{"posicion": "centro", "fuerzas": 0},
	{"posicion": "derecha", "fuerzas": 0},
]

var columna_seleccionada: int = 0
var fuerzas_restantes: int = 100
const PASO = 10

@onready var label_columna = $LabelColumnaSeleccionada
@onready var label_puntos = $LabelPuntosRestantes
@onready var label_efectos = $LabelEfectos
@onready var label_izq = $LabelValorIzq
@onready var label_centro = $LabelValorCentro
@onready var label_der = $LabelValorDer
@onready var col1 = $Columna1
@onready var col2 = $Columna2
@onready var col3 = $Columna3
@onready var boton_confirmar = $BotonConfirmar

func _ready() -> void:
	boton_confirmar.pressed.connect(_on_confirmar)
	actualizar_ui()

func _input(event: InputEvent) -> void:
	# Seleccionar columna con Z
	if event.is_action_pressed("accion"):
		columna_seleccionada = (columna_seleccionada + 1) % 3
		actualizar_ui()
	
	# Mover columna con flechas izq/der
	if event.is_action_pressed("ui_left"):
		mover_columna(-1)
	if event.is_action_pressed("ui_right"):
		mover_columna(1)
	
	# Asignar fuerzas con flechas arriba/abajo
	if event.is_action_pressed("ui_up"):
		asignar_fuerzas(PASO)
	if event.is_action_pressed("ui_down"):
		asignar_fuerzas(-PASO)

func mover_columna(direccion: int) -> void:
	var col = columnas[columna_seleccionada]
	var idx_actual = POSICIONES.find(col["posicion"])
	var idx_nuevo = clamp(idx_actual + direccion, 0, 2)
	
	# Verificar que la posición no esté ocupada por otra columna
	var posicion_nueva = POSICIONES[idx_nuevo]
	for i in range(3):
		if i != columna_seleccionada and columnas[i]["posicion"] == posicion_nueva:
			return
	
	col["posicion"] = posicion_nueva
	actualizar_ui()

func asignar_fuerzas(cantidad: int) -> void:
	var col = columnas[columna_seleccionada]
	if cantidad > 0 and fuerzas_restantes >= PASO:
		col["fuerzas"] += PASO
		fuerzas_restantes -= PASO
	elif cantidad < 0 and col["fuerzas"] >= PASO:
		col["fuerzas"] -= PASO
		fuerzas_restantes += PASO
	actualizar_ui()

func actualizar_ui() -> void:
	# Actualizar posición visual de columnas
	var cols_nodos = [col1, col2, col3]
	for i in range(3):
		var col = columnas[i]
		var nodo = cols_nodos[i]
		nodo.position.x = POS_X[col["posicion"]]
		# Resaltar columna seleccionada
		if i == columna_seleccionada:
			nodo.color = Color("#ffff00")
		elif col["fuerzas"] > 0:
			nodo.color = Color("#4444ff")
		else:
			nodo.color = Color("#888888")
	
	# Actualizar labels de zonas
	var totales = {"izquierda": 0, "centro": 0, "derecha": 0}
	for col in columnas:
		totales[col["posicion"]] += col["fuerzas"]
	
	label_izq.text = str(totales["izquierda"])
	label_centro.text = str(totales["centro"])
	label_der.text = str(totales["derecha"])
	
	# Guardar en GameManager
	GameManager.estrategia = totales
	
	label_columna.text = "Columna seleccionada: %d" % (columna_seleccionada + 1)
	label_puntos.text = "Fuerzas sin asignar: %d" % fuerzas_restantes
	
	# Mostrar efectos según distribución
	label_efectos.text = calcular_efectos()
	
	# Habilitar confirmar solo cuando no quedan fuerzas sin asignar
	boton_confirmar.disabled = fuerzas_restantes > 0

func calcular_efectos() -> String:
	var totales = GameManager.estrategia
	var efectos = []
	
	if totales["izquierda"] >= 50:
		efectos.append("Flanqueo izq: enemigo desmoralizado en Fase 2")
	if totales["centro"] >= 50:
		efectos.append("Ataque frontal: +daño en Fase 1, +daño recibido")
	if totales["derecha"] >= 50:
		efectos.append("Flanqueo der: stats reducidos en Marco del Pont")
	if totales["izquierda"] >= 40 and totales["derecha"] >= 40:
		efectos.append("¡Pinza perfecta! Bonus en todas las fases")
	
	if efectos.is_empty():
		return "Distribuí más fuerzas para ver efectos."
	return "\n".join(efectos)

func _on_confirmar() -> void:
	GameManager.mapa_tactico_completado = true
	get_tree().change_scene_to_file("res://scenes/world/chacabuco.tscn")
