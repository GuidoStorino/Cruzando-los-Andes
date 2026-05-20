extends CanvasLayer

const PASO = 10
const CLIMAS = ["despejado", "nevada", "ventisca", "tormenta"]

var comida_a_usar: int = 0

@onready var label_segmento = $Panel/LabelSegmento
@onready var label_clima = $Panel/LabelClima
@onready var label_recursos = $Panel/LabelRecursos
@onready var label_cantidad = $Panel/ContenedorAlimentar/LabelCantidad
@onready var label_efecto = $Panel/LabelEfecto
@onready var boton_menos = $Panel/ContenedorAlimentar/BotonMenos
@onready var boton_mas = $Panel/ContenedorAlimentar/BotonMas
@onready var boton_rapida = $Panel/BotonMarchaRapida
@onready var boton_lenta = $Panel/BotonMarchaLenta

func _ready() -> void:
	# Generar clima aleatorio
	GameManager.clima_actual = CLIMAS[randi() % CLIMAS.size()]
	
	boton_menos.pressed.connect(_on_menos)
	boton_mas.pressed.connect(_on_mas)
	boton_rapida.pressed.connect(_on_marcha_rapida)
	boton_lenta.pressed.connect(_on_marcha_lenta)
	
	actualizar_ui()

func actualizar_ui() -> void:
	label_segmento.text = "Segmento %d / 3" % GameManager.segmento_actual
	
	var icono_clima = {"despejado": "☀️", "nevada": "🌨️", "ventisca": "🌬️", "tormenta": "🌧️"}
	var efecto_clima = {
		"despejado": "Sin penalidades.",
		"nevada": "Nevada: consume el doble de comida.",
		"ventisca": "Ventisca: consume el doble de soldados.",
		"tormenta": "Tormenta: todos los recursos se consumen al doble."
	}
	label_clima.text = "Clima: %s %s" % [icono_clima[GameManager.clima_actual], GameManager.clima_actual.capitalize()]
	label_efecto.text = efecto_clima[GameManager.clima_actual]
	
	label_recursos.text = "Comida: %d | Munición: %d | Soldados: %d" % [
		GameManager.recursos["comida"],
		GameManager.recursos["municion"],
		GameManager.recursos["soldados"]
	]
	label_cantidad.text = str(comida_a_usar)

func _on_mas() -> void:
	if GameManager.recursos["comida"] >= comida_a_usar + PASO:
		comida_a_usar += PASO
		actualizar_ui()

func _on_menos() -> void:
	if comida_a_usar >= PASO:
		comida_a_usar -= PASO
		actualizar_ui()

func aplicar_recursos(rapida: bool) -> void:
	var multiplicador_clima = 1
	if GameManager.clima_actual in ["nevada", "tormenta"]:
		multiplicador_clima = 2

	# Consumo de comida
	var consumo_comida = 20 * multiplicador_clima if GameManager.clima_actual in ["nevada", "tormenta"] else 10
	if rapida:
		consumo_comida = int(consumo_comida * 1.5)

	# Consumo de munición
	var consumo_municion = 15 if rapida else 5

	# Consumo de soldados
	var consumo_soldados = 20 if GameManager.clima_actual in ["ventisca", "tormenta"] else 10
	if rapida:
		consumo_soldados = int(consumo_soldados * 1.5)

	# Aplicar comida elegida por el jugador
	GameManager.recursos["comida"] -= comida_a_usar
	GameManager.recursos["comida"] -= consumo_comida
	GameManager.recursos["municion"] -= consumo_municion
	GameManager.recursos["soldados"] -= consumo_soldados

	# Clampear a 0
	GameManager.recursos["comida"] = max(GameManager.recursos["comida"], 0)
	GameManager.recursos["municion"] = max(GameManager.recursos["municion"], 0)
	GameManager.recursos["soldados"] = max(GameManager.recursos["soldados"], 0)

	# Efecto de comida en HP
	if comida_a_usar >= 30:
		GameManager.stats_jugador["hp"] = min(
			GameManager.stats_jugador["hp"] + 20,
			GameManager.stats_jugador["hp_max"]
		)
	elif GameManager.recursos["comida"] == 0:
		GameManager.stats_jugador["hp"] = max(GameManager.stats_jugador["hp"] - 25, 10)
		print("¡Sin comida! San Martín pierde HP.")

	# Efecto de munición en ataque (permanente hasta el acto 3)
	if GameManager.recursos["municion"] <= 20:
		GameManager.stats_jugador["ataque"] = 10
		print("Munición escasa. Ataque reducido.")
	elif GameManager.recursos["municion"] <= 50:
		GameManager.stats_jugador["ataque"] = 14
	else:
		GameManager.stats_jugador["ataque"] = 18

	# Efecto de soldados en defensa
	if GameManager.recursos["soldados"] <= 20:
		GameManager.stats_jugador["defensa"] = 5
		print("Pocos soldados. Defensa reducida.")
	elif GameManager.recursos["soldados"] <= 50:
		GameManager.stats_jugador["defensa"] = 8
	else:
		GameManager.stats_jugador["defensa"] = 12

	print("=== RECURSOS TRAS SEGMENTO ===")
	print("Comida: ", GameManager.recursos["comida"])
	print("Munición: ", GameManager.recursos["municion"])
	print("Soldados: ", GameManager.recursos["soldados"])
	print("HP: ", GameManager.stats_jugador["hp"])
	print("Ataque: ", GameManager.stats_jugador["ataque"])
	print("Defensa: ", GameManager.stats_jugador["defensa"])

func _on_marcha_rapida() -> void:
	aplicar_recursos(true)
	avanzar_segmento(true)

func _on_marcha_lenta() -> void:
	aplicar_recursos(false)
	avanzar_segmento(false)

func avanzar_segmento(rapida: bool) -> void:
	GameManager.segmento_actual += 1
	
	# Marcha rápida evita combate, lenta puede tener combate
	var hay_combate = not rapida and GameManager.segmento_actual <= 3
	
	if hay_combate:
		GameManager.patrullas_derrotadas  # no modificar
		get_tree().change_scene_to_file("res://scenes/combat/combate.tscn")
	elif GameManager.segmento_actual > 3:
		# Terminó la travesía
		GameManager.completar_evento("travesia_completada")
		GameManager.avanzar_acto()
		get_tree().change_scene_to_file("res://scenes/world/chacabuco.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/segmento_travesia.tscn")
