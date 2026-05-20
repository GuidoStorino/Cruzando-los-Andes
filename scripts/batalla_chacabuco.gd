extends Node2D

var enemigo_data: Dictionary = {}
var jugador_hp: int = 100
var jugador_hp_max: int = 100
var jugador_defendiendo: bool = false

var enemigo_hp: int = 0
var enemigo_hp_max: int = 0
var enemigo_nombre: String = ""

var fase_actual: int = 1
var turno_jugador: bool = true
var combate_activo: bool = true
var jugador_desmoralizado: bool = false
var jugador_herido: bool = false


@onready var label_jugador = $UI/PanelInfo/LabelJugador
@onready var label_enemigo = $UI/PanelInfo/LabelEnemigo
@onready var label_fase = $UI/PanelFase/LabelFase
@onready var boton_atacar = $UI/PanelAcciones/BotonAtacar
@onready var boton_sable = $UI/PanelAcciones/BotonSable
@onready var boton_defender = $UI/PanelAcciones/BotonDefender
@onready var boton_huir = $UI/PanelAcciones/BotonHuir
@onready var sprite_cabral = $SpriteCabral
@onready var dialogo_ui = $UI/DialogoUI
@onready var label_mensaje = $UI/PanelMensaje/LabelMensaje

func _input(event: InputEvent) -> void:
	if not turno_jugador or not combate_activo:
		return
	if Input.is_action_just_pressed("accion"):  # Z = Atacar
		_on_atacar()
	elif Input.is_action_just_pressed("ui_up"):  # Arriba = Sable
		_on_sable()
	elif Input.is_action_just_pressed("ui_down"):  # Abajo = Defender
		_on_defender()


	
	

func _ready() -> void:
	jugador_hp = GameManager.stats_jugador["hp"]
	jugador_hp_max = GameManager.stats_jugador["hp_max"]
	
	boton_sable.visible = GameManager.tiene_sable_corvo
	boton_atacar.pressed.connect(_on_atacar)
	boton_sable.pressed.connect(_on_sable)
	boton_defender.pressed.connect(_on_defender)
	boton_huir.pressed.connect(_on_huir)
	iniciar_fase(1)

func iniciar_fase(fase: int) -> void:
	fase_actual = fase
	label_fase.text = "Fase %d / 3" % fase
	turno_jugador = true
	combate_activo = true
	set_botones_activos(true)

	match fase:
		1: enemigo_data = DatosEnemigos.get_enemigo("soldados_chacabuco")
		2: enemigo_data = DatosEnemigos.get_enemigo("capitan_chacabuco")
		3: enemigo_data = DatosEnemigos.get_enemigo("marco_del_pont")

	enemigo_hp = enemigo_data["hp"]
	enemigo_hp_max = enemigo_data["hp"]
	enemigo_nombre = enemigo_data["nombre"]

	aplicar_estrategia(fase)
	actualizar_labels()

	match fase:
		1:
			enemigo_nombre = "Soldados Realistas"
			enemigo_hp = 50
			enemigo_hp_max = 50
		2:
			enemigo_nombre = "Capitán Realista"
			enemigo_hp = 70
			enemigo_hp_max = 70
		3:
			enemigo_nombre = "Marco del Pont"
			enemigo_hp = 100
			enemigo_hp_max = 100
	actualizar_labels()

func actualizar_labels() -> void:
	label_jugador.text = "San Martín  HP: %d/%d" % [jugador_hp, jugador_hp_max]
	label_enemigo.text = "%s  HP: %d/%d" % [enemigo_nombre, enemigo_hp, enemigo_hp_max]

func _on_atacar() -> void:
	if not turno_jugador or not combate_activo:
		return
	var ataque = GameManager.stats_jugador["ataque"]
	if jugador_desmoralizado:
		ataque = int(ataque * 0.7)
		jugador_desmoralizado = false
	var danio = DatosEnemigos.calcular_danio(ataque, enemigo_data["defensa"], 1.0)
	mostrar_mensaje("¡San Martín usa Ataque!\n¡%s recibe %d de daño!" % [enemigo_nombre, danio])
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

func turno_enemigo() -> void:
	if not combate_activo:
		return

	var movimientos = enemigo_data["movimientos"]
	var mov = movimientos[randi() % movimientos.size()]

	var defensa_jugador = GameManager.stats_jugador["defensa"]
	if jugador_defendiendo:
		defensa_jugador = int(defensa_jugador * 2.0)
		jugador_defendiendo = false

	var danio = DatosEnemigos.calcular_danio(enemigo_data["ataque"], defensa_jugador, mov["danio"])

	var mensaje_efecto = ""
	if mov["efecto"] == "desmoralizado":
		jugador_desmoralizado = true
		mensaje_efecto = "\n¡San Martín está desmoralizado!"
	elif mov["efecto"] == "herido":
		jugador_herido = true
		mensaje_efecto = "\n¡San Martín está herido!"

	mostrar_mensaje("¡%s usa %s!\n¡San Martín recibe %d de daño!%s" % [
		enemigo_nombre, mov["nombre"], danio, mensaje_efecto
	])

	jugador_hp -= danio
	if jugador_herido:
		jugador_hp -= 5
		jugador_herido = false

	jugador_hp = max(jugador_hp, 0)
	actualizar_labels()

	await get_tree().create_timer(1.2).timeout

	if jugador_hp <= 0:
		terminar_combate(false)
	else:
		turno_jugador = true
		set_botones_activos(true)

func _on_defender() -> void:
	if not turno_jugador or not combate_activo:
		return
	jugador_defendiendo = true
	fin_turno_jugador()

func _on_huir() -> void:
	pass # No se puede huir de la batalla final

func aplicar_danio_enemigo(danio: int) -> void:
	enemigo_hp -= danio
	enemigo_hp = max(enemigo_hp, 0)
	actualizar_labels()
	if enemigo_hp <= 0:
		fin_fase()
	else:
		fin_turno_jugador()

func fin_turno_jugador() -> void:
	turno_jugador = false
	set_botones_activos(false)
	await get_tree().create_timer(1.0).timeout
	turno_enemigo()



func escena_cabral_salva() -> void:
	combate_activo = false
	set_botones_activos(false)
	GameManager.completar_evento("cabral_salvo_sanmartin")
	# Recuperar HP gracias a Cabral
	jugador_hp = min(jugador_hp + 40, jugador_hp_max)
	actualizar_labels()
	print("¡Cabral salva a San Martín!")
	await get_tree().create_timer(2.0).timeout
	# Continuar a fase 3
	iniciar_fase(3)

func fin_fase() -> void:
	combate_activo = false
	set_botones_activos(false)
	await get_tree().create_timer(1.0).timeout
	if fase_actual < 3:
		iniciar_fase(fase_actual + 1)
	else:
		victoria_final()

func victoria_final() -> void:
	GameManager.completar_evento("chacabuco_ganado")
	GameManager.avanzar_acto()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/world/santiago.tscn")

func game_over() -> void:
	combate_activo = false
	print("Game Over.")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/world/mendoza.tscn")

func set_botones_activos(activo: bool) -> void:
	boton_atacar.disabled = not activo
	boton_sable.disabled = not activo
	boton_defender.disabled = not activo
	boton_huir.disabled = not activo
	
func aplicar_estrategia(fase: int) -> void:
	var est = GameManager.estrategia
	
	match fase:
		1:
			if est["centro"] >= 50:
				# Ataque frontal: más daño pero más recibido
				GameManager.stats_jugador["ataque"] += 5
				print("Estrategia: Ataque frontal. +5 ataque, enemigo más agresivo.")
			if est["izquierda"] >= 40 and est["derecha"] >= 40:
				# Pinza perfecta
				GameManager.stats_jugador["ataque"] += 3
				GameManager.stats_jugador["defensa"] += 3
				print("¡Pinza perfecta! Bonus aplicado.")
		2:
			if est["izquierda"] >= 50:
				# Flanqueo izquierdo: enemigo desmoralizado
				enemigo_hp = int(enemigo_hp * 0.85)
				print("Flanqueo izquierdo: enemigo debilitado al inicio de Fase 2.")
		3:
			if est["derecha"] >= 50:
				# Flanqueo derecho: Marco del Pont debilitado
				enemigo_hp = int(enemigo_hp * 0.80)
				print("Flanqueo derecho: Marco del Pont llega debilitado.")
				
func mostrar_mensaje(texto: String) -> void:
	label_mensaje.text = texto

func terminar_combate(victoria: bool) -> void:
	combate_activo = false
	set_botones_activos(false)
	
	if victoria:
		GameManager.stats_jugador["hp"] = jugador_hp
		GameManager.completar_evento("chacabuco_ganado")
		GameManager.avanzar_acto()
		mostrar_mensaje("¡Victoria! ¡Chile es libre!")
	else:
		GameManager.resetear_acto()
		mostrar_mensaje("San Martín se retira... El ejército reagrupa fuerzas.")
	
	await get_tree().create_timer(2.0).timeout
	
	if victoria:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/world/santiago.tscn")
	else:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/world/chacabuco.tscn")				
