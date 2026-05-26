extends Node2D

# Stats
var jugador_hp: int
var jugador_hp_max: int
var jugador_defendiendo: bool = false
var jugador_desmoralizado: bool = false
var jugador_herido: bool = false

var enemigo_data: Dictionary = {}
var enemigo_hp: int
var enemigo_hp_max: int

var turno_jugador: bool = true
var combate_activo: bool = true

# UI
@onready var label_jugador = $UI/PanelInfo/LabelJugador
@onready var label_enemigo = $UI/PanelInfo/LabelEnemigo
@onready var label_mensaje = $UI/PanelMensaje/LabelMensaje
@onready var barra_hp_jugador = $UI/PanelInfo/BarraHPJugador
@onready var barra_hp_enemigo = $UI/PanelInfo/BarraHPEnemigo
@onready var boton_atacar = $UI/PanelAcciones/BotonAtacar
@onready var boton_sable = $UI/PanelAcciones/BotonSable
@onready var boton_defender = $UI/PanelAcciones/BotonDefender
@onready var boton_huir = $UI/PanelAcciones/BotonHuir

func _ready() -> void:
	# Cargar stats del jugador
	jugador_hp = GameManager.stats_jugador["hp"]
	jugador_hp_max = GameManager.stats_jugador["hp_max"]

	# Cargar enemigo según acto
	match GameManager.acto_actual:
		1: enemigo_data = DatosEnemigos.get_enemigo("espia")
		2: enemigo_data = DatosEnemigos.get_enemigo("patrulla")
		3: enemigo_data = DatosEnemigos.get_enemigo("destacamento")
		_: enemigo_data = DatosEnemigos.get_enemigo("espia")

	enemigo_hp = enemigo_data["hp"]
	enemigo_hp_max = enemigo_data["hp"]

	actualizar_ui()
	actualizar_botones()
	mostrar_mensaje("¡%s apareció!" % enemigo_data["nombre"])

	boton_atacar.pressed.connect(_on_atacar)
	boton_sable.pressed.connect(_on_sable)
	boton_defender.pressed.connect(_on_defender)
	boton_huir.pressed.connect(_on_huir)

func actualizar_ui() -> void:
	label_jugador.text = "San Martín  %d/%d" % [jugador_hp, jugador_hp_max]
	label_enemigo.text = "%s  %d/%d" % [enemigo_data["nombre"], enemigo_hp, enemigo_hp_max]
	barra_hp_jugador.value = float(jugador_hp) / jugador_hp_max * 100
	barra_hp_enemigo.value = float(enemigo_hp) / enemigo_hp_max * 100

func actualizar_botones() -> void:
	var es_turno = turno_jugador and combate_activo
	boton_atacar.disabled = not es_turno
	boton_defender.disabled = not es_turno
	boton_huir.disabled = not es_turno
	
	if GameManager.tiene_sable_corvo:
		boton_sable.visible = true
		if GameManager.sable_cooldown > 0:
			boton_sable.text = "Sable Corvo (%d)" % GameManager.sable_cooldown
			boton_sable.disabled = true
		else:
			boton_sable.text = "Sable Corvo"
			boton_sable.disabled = not es_turno
	else:
		boton_sable.visible = false

func mostrar_mensaje(texto: String) -> void:
	label_mensaje.text = texto

func _on_atacar() -> void:
	if not turno_jugador or not combate_activo:
		return
	var ataque = GameManager.stats_jugador["ataque"]
	if jugador_desmoralizado:
		ataque = int(ataque * 0.7)
		jugador_desmoralizado = false
	var danio = DatosEnemigos.calcular_danio(ataque, enemigo_data["defensa"], 1.0)
	mostrar_mensaje("¡San Martín usa Ataque!\n¡%s recibe %d de daño!" % [enemigo_data["nombre"], danio])
	aplicar_danio_enemigo(danio)

func _on_sable() -> void:
	if not turno_jugador or not combate_activo:
		return
	if not GameManager.usar_sable():
		return
	var ataque = GameManager.stats_jugador["ataque"]
	var danio = DatosEnemigos.calcular_danio(ataque, enemigo_data["defensa"], 1.8)
	mostrar_mensaje("¡San Martín desenvaina el Sable Corvo!\n¡Golpe poderoso! %d de daño!" % danio)
	aplicar_danio_enemigo(danio)

func _on_defender() -> void:
	if not turno_jugador or not combate_activo:
		return
	jugador_defendiendo = true
	mostrar_mensaje("San Martín adopta posición defensiva.")
	fin_turno_jugador()

func _on_huir() -> void:
	if not turno_jugador or not combate_activo:
		return
	mostrar_mensaje("San Martín se retira del combate.")
	await get_tree().create_timer(1.5).timeout
	terminar_combate(false)

func aplicar_danio_enemigo(danio: int) -> void:
	enemigo_hp -= danio
	enemigo_hp = max(enemigo_hp, 0)
	actualizar_ui()
	await get_tree().create_timer(1.2).timeout
	if enemigo_hp <= 0:
		terminar_combate(true)
	else:
		fin_turno_jugador()

func fin_turno_jugador() -> void:
	turno_jugador = false
	GameManager.reducir_cooldown()
	actualizar_botones()
	await get_tree().create_timer(1.0).timeout
	turno_enemigo()

func turno_enemigo() -> void:
	if not combate_activo:
		return

	# Elegir movimiento aleatorio
	var movimientos = enemigo_data["movimientos"]
	var mov = movimientos[randi() % movimientos.size()]
	
	# Calcular daño
	var defensa_jugador = GameManager.stats_jugador["defensa"]
	if jugador_defendiendo:
		defensa_jugador = int(defensa_jugador * 2.0)
		jugador_defendiendo = false

	var danio = DatosEnemigos.calcular_danio(enemigo_data["ataque"], defensa_jugador, mov["danio"])
	
	# Aplicar efecto de estado
	var mensaje_efecto = ""
	if mov["efecto"] == "desmoralizado":
		jugador_desmoralizado = true
		mensaje_efecto = "\n¡San Martín está desmoralizado! (Ataque reducido)"
	elif mov["efecto"] == "herido":
		jugador_herido = true
		mensaje_efecto = "\n¡San Martín está herido! (Pierde HP cada turno)"

	mostrar_mensaje("¡%s usa %s!\n¡San Martín recibe %d de daño!%s" % [
		enemigo_data["nombre"], mov["nombre"], danio, mensaje_efecto
	])

	jugador_hp -= danio
	
	# Efecto herido: pierde HP adicional
	if jugador_herido:
		jugador_hp -= 5
		jugador_herido = false

	jugador_hp = max(jugador_hp, 0)
	actualizar_ui()
	
	await get_tree().create_timer(1.2).timeout
	
	if jugador_hp <= 0:
		terminar_combate(false)
	else:
		turno_jugador = true
		actualizar_botones()
		
func terminar_combate(victoria: bool) -> void:
	combate_activo = false
	actualizar_botones()
	
	if victoria:
		GameManager.stats_jugador["hp"] = jugador_hp
		mostrar_mensaje("¡Victoria!")
		if GameManager.acto_actual == 2:
			GameManager.patrullas_vencidas_acto2.append(GameManager.ultima_patrulla_enfrentada)
		elif GameManager.acto_actual == 3:
			GameManager.eventos["patrulla_acto3_" + GameManager.ultima_patrulla_enfrentada] = true
		await get_tree().create_timer(2.0).timeout
		print("DEBUG acto_actual en combate: ", GameManager.acto_actual)
		match GameManager.acto_actual:
			1: get_tree().call_deferred("change_scene_to_file", "res://scenes/world/mendoza.tscn")
			2: get_tree().call_deferred("change_scene_to_file", "res://scenes/world/travesia2.tscn")
			3: get_tree().call_deferred("change_scene_to_file", "res://scenes/world/travesia_3.tscn")
			_: get_tree().call_deferred("change_scene_to_file", "res://scenes/world/mendoza.tscn")
	else:
		mostrar_mensaje("San Martín se retira... El ejército reagrupa fuerzas.")
		GameManager.resetear_acto()
		await get_tree().create_timer(2.0).timeout
		match GameManager.acto_actual:
			1: get_tree().call_deferred("change_scene_to_file", "res://scenes/world/mendoza.tscn")
			2: get_tree().call_deferred("change_scene_to_file", "res://scenes/world/travesia2.tscn")
			3: get_tree().call_deferred("change_scene_to_file", "res://scenes/world/travesia_3.tscn")
			_: get_tree().call_deferred("change_scene_to_file", "res://scenes/world/mendoza.tscn")
