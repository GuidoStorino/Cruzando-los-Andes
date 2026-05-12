extends CanvasLayer

const PUNTOS_TOTALES = 300
const PASO = 10

var puntos_restantes: int = PUNTOS_TOTALES

@onready var label_puntos = $Panel/LabelPuntosRestantes
@onready var label_comida_valor = $Panel/ContenedorComida/LabelComidaValor
@onready var label_municion_valor = $Panel/ContenedorMunicion/LabelMunicionValor
@onready var label_soldados_valor = $Panel/ContenedorSoldados/LabelSoldadosValor
@onready var boton_confirmar = $Panel/BotonConfirmar

func _ready() -> void:
	# Resetear recursos
	GameManager.recursos["comida"] = 0
	GameManager.recursos["municion"] = 0
	GameManager.recursos["soldados"] = 0
	
	$Panel/ContenedorComida/BotonComidaMenos.pressed.connect(_on_menos.bind("comida"))
	$Panel/ContenedorComida/BotonComidaMas.pressed.connect(_on_mas.bind("comida"))
	$Panel/ContenedorMunicion/BotonMunicionMenos.pressed.connect(_on_menos.bind("municion"))
	$Panel/ContenedorMunicion/BotonMunicionMas.pressed.connect(_on_mas.bind("municion"))
	$Panel/ContenedorSoldados/BotonSoldadosMenos.pressed.connect(_on_menos.bind("soldados"))
	$Panel/ContenedorSoldados/BotonSoldadosMas.pressed.connect(_on_mas.bind("soldados"))
	boton_confirmar.pressed.connect(_on_confirmar)
	
	actualizar_ui()

func _on_mas(recurso: String) -> void:
	if puntos_restantes >= PASO:
		GameManager.recursos[recurso] += PASO
		puntos_restantes -= PASO
		actualizar_ui()

func _on_menos(recurso: String) -> void:
	if GameManager.recursos[recurso] >= PASO:
		GameManager.recursos[recurso] -= PASO
		puntos_restantes += PASO
		actualizar_ui()

func actualizar_ui() -> void:
	label_puntos.text = "Puntos restantes: %d" % puntos_restantes
	label_comida_valor.text = str(GameManager.recursos["comida"])
	label_municion_valor.text = str(GameManager.recursos["municion"])
	label_soldados_valor.text = str(GameManager.recursos["soldados"])
	boton_confirmar.disabled = puntos_restantes > 0

func _on_confirmar() -> void:
	get_tree().change_scene_to_file("res://scenes/world/travesia.tscn")
