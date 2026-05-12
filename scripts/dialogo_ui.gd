extends CanvasLayer

signal dialogo_terminado

@onready var texto = $Panel/RichTextLabel
@onready var indicador = $Panel/Label

var lineas: Array = []
var linea_actual: int = 0
var activo: bool = false

func iniciar_dialogo(id_dialogo: String) -> void:
	lineas = DialogoManager.get_dialogo(id_dialogo)
	linea_actual = 0
	activo = true
	visible = true
	mostrar_linea()

func mostrar_linea() -> void:
	print("mostrar_linea: linea_actual=", linea_actual, " total=", lineas.size())
	if linea_actual < lineas.size():
		texto.text = lineas[linea_actual]
	else:
		terminar_dialogo()

func terminar_dialogo() -> void:
	activo = false
	visible = false
	lineas = []
	linea_actual = 0
	print("Signal dialogo_terminado emitido")
	emit_signal("dialogo_terminado")

func _process(delta: float) -> void:
	if activo and Input.is_action_just_pressed("dialogo_avanzar"):
		linea_actual += 1
		mostrar_linea()
