extends Node

# Cada enemigo tiene: nombre, hp, ataque, defensa, movimientos
var enemigos = {
	"espia": {
		"nombre": "Quiroga (Espía Realista)",
		"hp": 60,
		"ataque": 14,
		"defensa": 8,
		"movimientos": [
			{"nombre": "Emboscada", "danio": 1.2, "efecto": ""},
			{"nombre": "Información Robada", "danio": 0.8, "efecto": "desmoralizado"},
			{"nombre": "Ataque Furtivo", "danio": 1.0, "efecto": ""},
		]
	},
	"patrulla": {
		"nombre": "Patrulla Realista",
		"hp": 75,
		"ataque": 16,
		"defensa": 10,
		"movimientos": [
			{"nombre": "Tiro de Mosquete", "danio": 1.0, "efecto": ""},
			{"nombre": "Carga de Bayoneta", "danio": 1.3, "efecto": "herido"},
			{"nombre": "Formación Defensiva", "danio": 0.5, "efecto": ""},
		]
	},
	"destacamento": {
		"nombre": "Destacamento Realista",
		"hp": 90,
		"ataque": 18,
		"defensa": 14,
		"movimientos": [
			{"nombre": "Fuego Cruzado", "danio": 1.2, "efecto": ""},
			{"nombre": "Carga de Caballería", "danio": 1.5, "efecto": "herido"},
			{"nombre": "Trinchera", "danio": 0.4, "efecto": ""},
		]
	},
	"soldados_chacabuco": {
		"nombre": "Soldados Realistas",
		"hp": 80,
		"ataque": 16,
		"defensa": 12,
		"movimientos": [
			{"nombre": "Descarga Cerrada", "danio": 1.1, "efecto": ""},
			{"nombre": "Avance Coordinado", "danio": 1.0, "efecto": "desmoralizado"},
		]
	},
	"capitan_chacabuco": {
		"nombre": "Capitán Realista",
		"hp": 100,
		"ataque": 20,
		"defensa": 15,
		"movimientos": [
			{"nombre": "Sablazoo", "danio": 1.3, "efecto": "herido"},
			{"nombre": "Orden de Ataque", "danio": 1.1, "efecto": ""},
			{"nombre": "Posición Defensiva", "danio": 0.3, "efecto": ""},
		]
	},
	"marco_del_pont": {
		"nombre": "Marco del Pont",
		"hp": 130,
		"ataque": 24,
		"defensa": 18,
		"movimientos": [
			{"nombre": "Autoridad Real", "danio": 1.4, "efecto": "desmoralizado"},
			{"nombre": "Guardia Personal", "danio": 1.2, "efecto": ""},
			{"nombre": "Contraataque", "danio": 1.6, "efecto": "herido"},
			{"nombre": "Resistencia Final", "danio": 0.8, "efecto": ""},
		]
	},
}

func get_enemigo(id: String) -> Dictionary:
	if enemigos.has(id):
		return enemigos[id].duplicate(true)
	return enemigos["espia"].duplicate(true)

func calcular_danio(ataque: int, defensa: int, multiplicador: float) -> int:
	var danio_base = ataque * multiplicador
	var reduccion = defensa * 0.4
	var danio_final = int(max(danio_base - reduccion, 3))
	return danio_final
