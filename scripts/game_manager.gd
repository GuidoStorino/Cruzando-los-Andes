extends Node

# Acto actual (1 al 5)
var acto_actual: int = 1

# Inventario
var tiene_sable_corvo: bool = false
var sable_corvo_equipado: bool = false
var pistas_recolectadas: int = 0
var acusacion_incorrecta: bool = false

# Flags de eventos completados
var eventos = {
	"espia_descubierto": false,
	"cabral_reclutado": false,
	"travesia_completada": false,
	"destacamento_derrotado": false,
	"chacabuco_ganado": false,
	"cabral_salvo_sanmartin": false,
}

# Recursos para la travesía (Acto 2)
var recursos = {
	"puntos_totales": 300,
	"comida": 0,
	"municion": 0,
	"soldados": 0,
}

var segmento_actual: int = 1
var clima_actual: String = "despejado"

# Stats de San Martín
var stats_jugador = {
	"ataque": 18,
	"defensa": 12,
	"hp": 100,
	"hp_max": 100,
}

# Cooldown del Sable Corvo
var sable_cooldown: int = 0

var patrullas_derrotadas: int = 0

func completar_evento(evento: String) -> void:
	if eventos.has(evento):
		eventos[evento] = true
		print("Evento completado: ", evento)

func avanzar_acto() -> void:
	acto_actual += 1
	print("Avanzando al acto: ", acto_actual)

func obtener_sable_corvo() -> void:
	tiene_sable_corvo = true
	print("Sable Corvo obtenido!")

func equipar_sable_corvo() -> void:
	if tiene_sable_corvo:
		sable_corvo_equipado = true

func get_danio_base() -> int:
	if sable_corvo_equipado:
		return stats_jugador["ataque"] + 20
	return stats_jugador["ataque"]

func usar_sable() -> bool:
	if sable_cooldown > 0:
		return false
	sable_corvo_equipado = true
	sable_cooldown = 2
	return true

func reducir_cooldown() -> void:
	if sable_cooldown > 0:
		sable_cooldown -= 1
	sable_corvo_equipado = false
	
func resetear_acto() -> void:
	stats_jugador["hp"] = stats_jugador["hp_max"]
	sable_cooldown = 0
	sable_corvo_equipado = false
	
	if acto_actual == 1:
		eventos["espia_descubierto"] = false
		eventos["cabral_reclutado"] = false
		tiene_sable_corvo = false
		pistas_recolectadas = 0
		acusacion_incorrecta = false
	elif acto_actual == 2:
		eventos["travesia_completada"] = false
		patrullas_derrotadas = 1
		segmento_actual = 1
		recursos = {"puntos_totales": 300, "comida": 0, "municion": 0, "soldados": 0}
	elif acto_actual == 3:
		eventos["destacamento_derrotado"] = false
		patrullas_derrotadas = 2
