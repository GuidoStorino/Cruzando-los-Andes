extends Node2D

var jugador_hp: int = 100
var jugador_hp_max: int = 100
var jugador_defendiendo: bool = false

var enemigo_hp: int = 0
var enemigo_hp_max: int = 0
var enemigo_nombre: String = ""

var fase_actual: int = 1
var turno_jugador: bool = true
var combate_activo: bool = true

@onready var label_jugador = $UI/PanelInfo/LabelJugador
@onready var label_enemigo = $UI/PanelInfo/LabelEnemigo
@onready var label_fase = $UI/PanelFase/LabelFase
@onready var boton_atacar = $UI/PanelAcciones/BotonAtacar
@onready var boton_sable = $UI/PanelAcciones/BotonSable
@onready var boton_defender = $UI/PanelAcciones/BotonDefender
@onready var boton_huir = $UI/PanelAcciones/BotonHuir
@onready var sprite_cabral = $SpriteCabral
@onready var dialogo_ui = $UI/DialogoUI

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
	boton_sable.visible = GameManager.tiene_sable_corvo
	boton_atacar.pressed.connect(_on_atacar)
	boton_sable.pressed.connect(_on_sable)
	boton_defender.pressed.connect(_on_defender)
	boton_huir.pressed.connect(_on_huir)
	iniciar_fase(1)
	
	# Diagnóstico
	print("BotonAtacar posición: ", boton_atacar.global_position)
	print("BotonAtacar size: ", boton_atacar.size)
	print("BotonAtacar visible: ", boton_atacar.visible)
	print("BotonAtacar disabled: ", boton_atacar.disabled)

func iniciar_fase(fase: int) -> void:
	fase_actual = fase
	label_fase.text = "Fase %d / 3" % fase
	turno_jugador = true
	combate_activo = true
	set_botones_activos(true)

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
	var danio = GameManager.get_danio_base()
	aplicar_danio_enemigo(danio)

func _on_sable() -> void:
	if not turno_jugador or not combate_activo:
		return
	GameManager.equipar_sable_corvo()
	var danio = GameManager.get_danio_base()
	aplicar_danio_enemigo(danio)

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

func turno_enemigo() -> void:
	if not combate_activo:
		return
	
	# Fase 2: Cabral salva a San Martín
	if fase_actual == 2 and jugador_hp < 40 and not GameManager.eventos["cabral_salvo_sanmartin"]:
		escena_cabral_salva()
		return

	var danio_enemigo = randi_range(10, 22)
	if jugador_defendiendo:
		danio_enemigo = danio_enemigo / 2
		jugador_defendiendo = false
	jugador_hp -= danio_enemigo
	jugador_hp = max(jugador_hp, 0)
	actualizar_labels()

	if jugador_hp <= 0:
		game_over()
	else:
		turno_jugador = true
		set_botones_activos(true)

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
