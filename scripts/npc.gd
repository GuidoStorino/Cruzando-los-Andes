extends StaticBody2D

@export var nombre: String = "NPC"
@export var id_dialogo: String = ""
@export var es_espia: bool = false
@export var da_sable_corvo: bool = false
@export var es_reclutable: bool = false
@export var da_pista: bool = false
@export var es_cabildo: bool = false
@export var repetible: bool = false
@export var es_curandero: bool = false
@export var reacciona_al_acercamiento: bool = false
@export var distancia_reaccion: float = 30.0

# ── Acto 3 ──────────────────────────────────────────────────
@export var es_explorador: int = 0       # 0 = no explorador, 1 = falso (NO), 2 = correcto (SE)
@export var es_oficial_mapa: bool = false
@export var es_armero: bool = false
@export var es_ohiggins: bool = false
@export var es_soldado_cadena: int = 0   # 0 = ninguno, 1 = Acosta, 2 = Benítez, 3 = Carrizo
@export var es_mula_acto3: bool = false

@onready var label = $Label

var dialogo_ui: Node = null
var ya_interactuado: bool = false

func _ready() -> void:
	label.text = nombre
	await get_tree().process_frame
	dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)

func _process(_delta: float) -> void:
	if reacciona_al_acercamiento and not ya_interactuado:
		var jugador = get_tree().current_scene.find_child("Player", true, false)
		if jugador and global_position.distance_to(jugador.global_position) < distancia_reaccion:
			ya_interactuado = true
			_iniciar_combate_espia()
			return

	if Input.is_action_just_pressed("accion") and not ya_interactuado:
		if esta_cerca_del_jugador():
			interactuar()

func _get_distancia() -> float:
	var jugador = get_tree().get_root().find_child("Player", true, false)
	if jugador == null:
		return 9999
	return global_position.distance_to(jugador.global_position)

func esta_cerca_del_jugador() -> bool:
	var jugador = get_tree().get_root().find_child("Player", true, false)
	if jugador == null:
		return false
	return global_position.distance_to(jugador.global_position) < 40

func _interaccion_mula() -> void:
	if GameManager.eventos.get("mula_montada", false):
		dialogo_ui.iniciar_dialogo("mula_ya_montada")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)
		return

	dialogo_ui.iniciar_dialogo("mula_ofrecida")
	dialogo_ui.dialogo_terminado.connect(_on_mula_aceptada, CONNECT_ONE_SHOT)

func _on_mula_aceptada() -> void:
	GameManager.eventos["mula_montada"] = true
	print("=== MULA ACEPTADA ===")
	print("mula_montada: ", GameManager.eventos.get("mula_montada", false))
	visible = false

func interactuar() -> void:
	if es_mula_acto3:
		_interaccion_mula()
	
	if dialogo_ui == null:
		dialogo_ui = get_tree().current_scene.find_child("DialogoUI", true, false)
	if dialogo_ui == null:
		return
	if dialogo_ui.dialogo_terminado.is_connected(_on_dialogo_terminado):
		dialogo_ui.dialogo_terminado.disconnect(_on_dialogo_terminado)

	# Prioridad de roles especiales
	if es_curandero:
		_interaccion_curandero()
		return
	if es_cabildo:
		_interaccion_cabildo()
		return
	if es_explorador > 0:
		_interaccion_explorador()
		return
	if es_oficial_mapa:
		_interaccion_oficial_mapa()
		return
	if es_armero:
		_interaccion_armero()
		return
	if es_ohiggins:
		_interaccion_ohiggins()
		return
	if es_soldado_cadena > 0:
		_interaccion_cadena()
		return

	if id_dialogo == "":
		return

	dialogo_ui.iniciar_dialogo(id_dialogo)
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

# ────────────────────────────────────────────────────────────
#  ACTO 1 — Curandero y Cabildo (sin cambios)
# ────────────────────────────────────────────────────────────
func _interaccion_curandero() -> void:
	if GameManager.inventario["ungüento"]:
		dialogo_ui.iniciar_dialogo("curandero_ya_entregado")
	elif GameManager.inventario["comida"] >= 3:
		GameManager.inventario["comida"] -= 3
		GameManager.inventario["ungüento"] = true
		dialogo_ui.iniciar_dialogo("curandero_con_comida")
	else:
		dialogo_ui.iniciar_dialogo("curandero_sin_comida")
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _interaccion_cabildo() -> void:
	if GameManager.eventos["espia_descubierto"] and not GameManager.tiene_sable_corvo:
		dialogo_ui.iniciar_dialogo("cabildo_sable_post_espia")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)
	elif GameManager.pistas_recolectadas >= 3:
		dialogo_ui.iniciar_dialogo("cabildo_alerta")
		dialogo_ui.dialogo_terminado.connect(_on_cabildo_alerta_terminado, CONNECT_ONE_SHOT)
	else:
		dialogo_ui.iniciar_dialogo("cabildo_neutral")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _on_cabildo_alerta_terminado() -> void:
	var mendoza = get_tree().current_scene
	if mendoza.has_method("mostrar_menu_acusacion"):
		mendoza.mostrar_menu_acusacion()

# ────────────────────────────────────────────────────────────
#  ACTO 3 — Exploradores
# ────────────────────────────────────────────────────────────
func _interaccion_explorador() -> void:
	if es_explorador == 1:
		dialogo_ui.iniciar_dialogo("explorador_1_falso")
		GameManager.eventos["explorador1_consultado"] = true
	elif es_explorador == 2:
		dialogo_ui.iniciar_dialogo("explorador_2_correcto")
		GameManager.eventos["explorador2_consultado"] = true

	if GameManager.eventos.get("explorador1_consultado", false) \
	and GameManager.eventos.get("explorador2_consultado", false):
		GameManager.eventos["exploradores_consultados"] = true

	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

# ────────────────────────────────────────────────────────────
#  ACTO 3 — Oficial con mapa (mini juego de flanco)
# ────────────────────────────────────────────────────────────
func _interaccion_oficial_mapa() -> void:
	if not GameManager.eventos.get("exploradores_consultados", false):
		dialogo_ui.iniciar_dialogo("oficial_espera_exploradores")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)
		return

	if GameManager.eventos.get("flanco_correcto", false) \
	or GameManager.estrategia["izquierda"] >= 50 \
	or GameManager.estrategia["centro"] >= 50:
		dialogo_ui.iniciar_dialogo("oficial_ya_decidido")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)
		return

	dialogo_ui.iniciar_dialogo("oficial_presenta_mapa")
	dialogo_ui.dialogo_terminado.connect(_on_oficial_mapa_terminado, CONNECT_ONE_SHOT)

func _on_oficial_mapa_terminado() -> void:
	var escena = get_tree().current_scene
	if escena.has_method("abrir_menu_flanco"):
		escena.abrir_menu_flanco()

# ────────────────────────────────────────────────────────────
#  ACTO 3 — Armero
# ────────────────────────────────────────────────────────────
func _interaccion_armero() -> void:
	print("=== ARMERO ===")
	print("piedra_afilar en inventario: ", GameManager.inventario.get("piedra_afilar", false))
	print("sable_afilado: ", GameManager.eventos.get("sable_afilado", false))
	if GameManager.eventos.get("sable_afilado", false):
		dialogo_ui.iniciar_dialogo("armero_ya_afilado")
		dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)
		return
	

	if GameManager.inventario.get("piedra_afilar", false):
		GameManager.inventario["piedra_afilar"] = false
		GameManager.eventos["sable_afilado"] = true
		dialogo_ui.iniciar_dialogo("armero_afila_sable")
		# Bonus de daño permanente — se aplica en combate leyendo eventos["sable_afilado"]
	else:
		dialogo_ui.iniciar_dialogo("armero_sin_piedra")

	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

# ────────────────────────────────────────────────────────────
#  ACTO 3 — Cadena de favores
#  es_soldado_cadena: 1 = Acosta, 2 = Benítez, 3 = Carrizo
# ────────────────────────────────────────────────────────────
func _interaccion_cadena() -> void:
	match es_soldado_cadena:
		1: _interaccion_acosta()
		2: _interaccion_benitez()
		3: _interaccion_carrizo()

func _interaccion_acosta() -> void:
	if GameManager.eventos.get("cadena_completada", false):
		dialogo_ui.iniciar_dialogo("soldado_a_agradecido")
	else:
		dialogo_ui.iniciar_dialogo("soldado_a_necesita_vendas")
		GameManager.eventos["soldado_a_hablado"] = true
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _interaccion_benitez() -> void:
	print("=== BENÍTEZ ===")
	print("fusil en inventario: ", GameManager.inventario.get("fusil", false))
	print("soldado_a_hablado: ", GameManager.eventos.get("soldado_a_hablado", false))
	if not GameManager.eventos.get("soldado_a_hablado", false):
		dialogo_ui.iniciar_dialogo("soldado_b_antes_de_a")
	elif GameManager.eventos.get("fusil_entregado", false):
		dialogo_ui.iniciar_dialogo("soldado_b_agradecido")
	elif GameManager.inventario.get("fusil", false):
		# Tiene el fusil → entregarlo
		GameManager.inventario["fusil"] = false
		GameManager.eventos["fusil_entregado"] = true
		dialogo_ui.iniciar_dialogo("soldado_b_recibe_fusil")
		dialogo_ui.dialogo_terminado.connect(_on_fusil_entregado, CONNECT_ONE_SHOT)
		return
	else:
		dialogo_ui.iniciar_dialogo("soldado_b_perdio_fusil")
		GameManager.eventos["soldado_b_hablado"] = true
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _on_fusil_entregado() -> void:
	# Después de entregar el fusil, Carrizo da las vendas automáticamente
	dialogo_ui.iniciar_dialogo("soldado_c_da_vendas")
	dialogo_ui.dialogo_terminado.connect(_on_cadena_completada, CONNECT_ONE_SHOT)

func _interaccion_carrizo() -> void:
	if not GameManager.eventos.get("fusil_entregado", false):
		dialogo_ui.iniciar_dialogo("soldado_c_espera")
	elif GameManager.eventos.get("cadena_completada", false):
		dialogo_ui.iniciar_dialogo("soldado_c_contento")
	else:
		dialogo_ui.iniciar_dialogo("soldado_c_da_vendas")
		dialogo_ui.dialogo_terminado.connect(_on_cadena_completada, CONNECT_ONE_SHOT)
		return
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _on_cadena_completada() -> void:
	GameManager.eventos["cadena_completada"] = true
	GameManager.stats_jugador["hp_max"] += 15
	GameManager.stats_jugador["hp"] = min(
		GameManager.stats_jugador["hp"] + 15,
		GameManager.stats_jugador["hp_max"]
	)
	dialogo_ui.iniciar_dialogo("cadena_completada_bonus")
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

# ────────────────────────────────────────────────────────────
#  ACTO 3 — O'Higgins
# ────────────────────────────────────────────────────────────
func _interaccion_ohiggins() -> void:
	var conflictos = 0
	if GameManager.eventos.get("sable_afilado", false):
		conflictos += 1
	if GameManager.eventos.get("flanco_correcto", false):
		conflictos += 1
	if GameManager.eventos.get("cadena_completada", false):
		conflictos += 1

	if conflictos >= 3:
		dialogo_ui.iniciar_dialogo("ohiggins_llama_batalla")
		dialogo_ui.dialogo_terminado.connect(_on_ohiggins_listo, CONNECT_ONE_SHOT)
		return

	# Pista específica sobre qué falta
	var id: String
	if not GameManager.eventos.get("sable_afilado", false):
		id = "ohiggins_falta_sable"
	elif not GameManager.eventos.get("flanco_correcto", false):
		id = "ohiggins_falta_flanco"
	else:
		id = "ohiggins_falta_cadena"

	dialogo_ui.iniciar_dialogo(id)
	dialogo_ui.dialogo_terminado.connect(_on_dialogo_terminado, CONNECT_ONE_SHOT)

func _on_ohiggins_listo() -> void:
	GameManager.mapa_tactico_completado = true
	get_tree().change_scene_to_file("res://scenes/ui/mapa_tactico.tscn")

# ────────────────────────────────────────────────────────────
#  ON DIALOGO TERMINADO (genérico)
# ────────────────────────────────────────────────────────────
func _on_dialogo_terminado() -> void:
	if nombre == "Campamento":
		GameManager.stats_jugador["hp"] = GameManager.stats_jugador["hp_max"]

	if da_sable_corvo and not GameManager.tiene_sable_corvo:
		if GameManager.eventos["espia_descubierto"]:
			GameManager.obtener_sable_corvo()

	if es_reclutable and not GameManager.eventos["cabral_reclutado"]:
		GameManager.completar_evento("cabral_reclutado")

	if da_pista and not ya_interactuado:
		GameManager.pistas_recolectadas += 1

	if es_espia:
		_iniciar_combate_espia()
	elif repetible:
		ya_interactuado = false
	else:
		ya_interactuado = true

# ────────────────────────────────────────────────────────────
#  COMBATE
# ────────────────────────────────────────────────────────────
func _iniciar_combate_espia() -> void:
	var escena_path = get_tree().current_scene.scene_file_path
	if "travesia3" in escena_path:
		GameManager.acto_actual = 3

	if GameManager.acto_actual == 3:
		GameManager.completar_evento("destacamento_derrotado")
	else:
		GameManager.completar_evento("espia_descubierto")

	GameManager.patrullas_derrotadas += 1
	GameManager.ultima_patrulla_enfrentada = name
	GameManager.posicion_guardada = get_tree().current_scene.find_child("Player", true, false).global_position
	print("posicion guardada antes de combate: ", GameManager.posicion_guardada)
	ya_interactuado = true
	get_tree().call_deferred("change_scene_to_file", "res://scenes/combat/combate.tscn")
