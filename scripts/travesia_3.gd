extends Node2D

# ─────────────────────────────────────────────
#  REFERENCIAS
# ─────────────────────────────────────────────
@onready var dialogo_ui   = $DialogoUI
@onready var player       = $Player
@onready var patrullas    = $Objetos/Patrullas
@onready var npcs         = $Objetos/NPCs
@onready var items_node   = $Objetos/Items
@onready var mula_node    = $Objetos/Mula

# NPCs por rol (asignar en el Inspector con nombre o buscamos por posición)
# Los nombres asumidos coinciden con la jerarquía: NPC, NPC2 ... NPC7
@onready var explorador_1  = $Objetos/NPCs/NPC       # Noroeste - info falsa
@onready var explorador_2  = $Objetos/NPCs/NPC2      # Noreste  - info correcta
@onready var ohiggins      = $Objetos/NPCs/NPC3      # Campamento
@onready var oficial_mapa  = $Objetos/NPCs/NPC4      # Campamento - mini juego
@onready var soldado_a     = $Objetos/NPCs/NPC5      # Cadena: necesita vendas
@onready var soldado_b     = $Objetos/NPCs/NPC6      # Cadena: perdió fusil
@onready var soldado_c     = $Objetos/NPCs/NPC7      # Cadena: tiene vendas
@onready var armero        = $Objetos/NPCs/NPC8      # Campamento - afila sable

@onready var item_piedra   = $Objetos/Items/item     # piedra_afilar (Noroeste)
@onready var item_fusil    = $Objetos/Items/item2    # fusil (Noreste)

@onready var salida_norte  = $SalidaMapa             # hacia batalla_chacabuco

# ─────────────────────────────────────────────
#  ESTADO LOCAL
# ─────────────────────────────────────────────
var dialogo_activo: bool = false

# Seguimiento de conflictos completados
var conflictos_completos: int = 0  # necesitamos 3 para desbloquear O'Higgins

# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	GameManager.acto_actual = 3  # temporal
	if GameManager.posicion_guardada != Vector2.ZERO:
		player.global_position = GameManager.posicion_guardada
		GameManager.posicion_guardada = Vector2.ZERO

	for p in patrullas.get_children():
		var key = "patrulla_acto3_" + p.name
		if GameManager.eventos.get(key, false):
			p.visible = false
			p.ya_interactuado = true
			p.ya_interactuado = true

	# Ocultar ítems ya recogidos
	if GameManager.inventario.get("piedra_afilar", false):
		item_piedra.visible = false
	if GameManager.inventario.get("fusil", false):
		item_fusil.visible = false

	# Ocultar Mula si ya está montada (o conectar señal)
	_setup_mula()

	# Conectar señales de NPCs
	_conectar_npcs()

	# Conectar señal de salida
	if salida_norte:
		salida_norte.connect("body_entered", _on_salida_norte)

	# Actualizar contador de conflictos al entrar (por si venimos de combate)
	_recalcular_conflictos()


# ─────────────────────────────────────────────
#  CONEXIÓN DE SEÑALES
# ─────────────────────────────────────────────
func _conectar_npcs() -> void:
	# Patrullas
	for p in patrullas.get_children():
		if p.has_signal("npc_interactuado"):
			p.connect("npc_interactuado", _on_patrulla_interactuada.bind(p))

	# NPCs con roles específicos
	_conectar_npc(explorador_1,  "_on_explorador_1")
	_conectar_npc(explorador_2,  "_on_explorador_2")
	_conectar_npc(ohiggins,      "_on_ohiggins")
	_conectar_npc(oficial_mapa,  "_on_oficial_mapa")
	_conectar_npc(soldado_a,     "_on_soldado_a")
	_conectar_npc(soldado_b,     "_on_soldado_b")
	_conectar_npc(soldado_c,     "_on_soldado_c")
	_conectar_npc(armero,        "_on_armero")

	# Ítems
	if item_piedra and item_piedra.has_signal("item_recogido"):
		item_piedra.connect("item_recogido", _on_piedra_recogida)
	if item_fusil and item_fusil.has_signal("item_recogido"):
		item_fusil.connect("item_recogido", _on_fusil_recogido)

	# Mula
	if mula_node and mula_node.has_signal("npc_interactuado"):
		mula_node.connect("npc_interactuado", _on_mula_interactuada)


func _conectar_npc(npc: Node, metodo: String) -> void:
	if npc and npc.has_signal("npc_interactuado"):
		npc.connect("npc_interactuado", Callable(self, metodo))


# ─────────────────────────────────────────────
#  CONFLICTO 1 — LA PIEDRA DE AFILAR
# ─────────────────────────────────────────────
func _on_piedra_recogida() -> void:
	GameManager.inventario["piedra_afilar"] = true
	GameManager.eventos["piedra_encontrada"] = true
	item_piedra.visible = false
	_mostrar_dialogo("piedra_encontrada")


func _on_armero(_npc) -> void:
	if dialogo_activo:
		return

	if GameManager.eventos.get("sable_afilado", false):
		_mostrar_dialogo("armero_ya_afilado")
		return

	if GameManager.inventario.get("piedra_afilar", false):
		# Afila el sable
		GameManager.eventos["sable_afilado"] = true
		GameManager.inventario["piedra_afilar"] = false
		# Bonus de daño permanente (se aplica en combate leyendo el evento)
		_mostrar_dialogo("armero_afila_sable")
		_recalcular_conflictos()
	else:
		_mostrar_dialogo("armero_sin_piedra")


# ─────────────────────────────────────────────
#  CONFLICTO 2 — MINI JUEGO DE LÓGICA
# ─────────────────────────────────────────────
func _on_explorador_1(_npc) -> void:
	if dialogo_activo:
		return
	_mostrar_dialogo("explorador_1_falso")
	# Marcar que habló con explorador 1
	GameManager.eventos["explorador1_consultado"] = true
	_verificar_exploradores()


func _on_explorador_2(_npc) -> void:
	if dialogo_activo:
		return
	_mostrar_dialogo("explorador_2_correcto")
	GameManager.eventos["explorador2_consultado"] = true
	_verificar_exploradores()


func _on_oficial_mapa(_npc) -> void:
	if dialogo_activo:
		return

	if not GameManager.eventos.get("exploradores_consultados", false):
		_mostrar_dialogo("oficial_espera_exploradores")
		return

	if GameManager.eventos.get("flanco_correcto", false):
		_mostrar_dialogo("oficial_ya_decidido")
		return

	# Activar mini juego de flanqueo
	_mostrar_dialogo("oficial_presenta_mapa")
	await DialogoManager.dialogo_terminado
	_abrir_menu_flanco()


func _verificar_exploradores() -> void:
	if GameManager.eventos.get("explorador1_consultado", false) \
	and GameManager.eventos.get("explorador2_consultado", false):
		GameManager.eventos["exploradores_consultados"] = true


func _abrir_menu_flanco() -> void:
	# Usamos el mismo sistema de menú de acusación del Acto 1
	# El MenuFlanco debe existir en la escena o se muestra con un popup
	# Por ahora emitimos una señal que la UI puede capturar
	# Alternativa simple: diálogo con opciones
	dialogo_activo = true

	var opciones = ["Por la izquierda", "Por el centro", "Por la derecha"]
	# Si tu sistema de diálogo soporta opciones, usarlo acá.
	# Si no, implementar con un Control temporal:
	_mostrar_menu_flanco(opciones)


func _mostrar_menu_flanco(opciones: Array) -> void:
	# Crear botones temporales en pantalla
	var panel = _crear_panel_opciones("¿Por dónde atacamos?", opciones, "_on_flanco_elegido")
	add_child(panel)


func _on_flanco_elegido(opcion: int) -> void:
	dialogo_activo = false
	match opcion:
		0:  # Izquierda
			GameManager.estrategia["izquierda"] += 50
			_mostrar_dialogo("flanco_izquierda")
		1:  # Centro
			GameManager.estrategia["centro"] += 50
			_mostrar_dialogo("flanco_centro")
		2:  # Derecha — CORRECTO
			GameManager.estrategia["derecha"] += 50
			GameManager.eventos["flanco_correcto"] = true
			_mostrar_dialogo("flanco_derecha_correcto")
			_recalcular_conflictos()


# ─────────────────────────────────────────────
#  CONFLICTO 3 — CADENA DE FAVORES
# ─────────────────────────────────────────────
func _on_soldado_a(_npc) -> void:
	if dialogo_activo:
		return

	if GameManager.eventos.get("cadena_completada", false):
		_mostrar_dialogo("soldado_a_agradecido")
		return

	_mostrar_dialogo("soldado_a_necesita_vendas")
	GameManager.eventos["soldado_a_hablado"] = true


func _on_soldado_b(_npc) -> void:
	if dialogo_activo:
		return

	if not GameManager.eventos.get("soldado_a_hablado", false):
		_mostrar_dialogo("soldado_b_antes_de_a")
		return

	if GameManager.eventos.get("fusil_encontrado", false) \
	and not GameManager.eventos.get("fusil_entregado", false):
		# Entregar fusil
		GameManager.inventario["fusil"] = false
		GameManager.eventos["fusil_entregado"] = true
		_mostrar_dialogo("soldado_b_recibe_fusil")
		await DialogoManager.dialogo_terminado
		_on_fusil_entregado()
	elif GameManager.eventos.get("fusil_entregado", false):
		_mostrar_dialogo("soldado_b_agradecido")
	else:
		_mostrar_dialogo("soldado_b_perdio_fusil")
		GameManager.eventos["soldado_b_hablado"] = true


func _on_fusil_recogido() -> void:
	GameManager.inventario["fusil"] = true
	GameManager.eventos["fusil_encontrado"] = true
	item_fusil.visible = false
	_mostrar_dialogo("fusil_encontrado")


func _on_fusil_entregado() -> void:
	# Soldado C ahora da las vendas a Soldado A
	_mostrar_dialogo("soldado_c_da_vendas")
	await DialogoManager.dialogo_terminado
	_completar_cadena()


func _on_soldado_c(_npc) -> void:
	if dialogo_activo:
		return

	if not GameManager.eventos.get("fusil_entregado", false):
		_mostrar_dialogo("soldado_c_espera")
		return

	if GameManager.eventos.get("cadena_completada", false):
		_mostrar_dialogo("soldado_c_contento")
		return

	_mostrar_dialogo("soldado_c_da_vendas")
	await DialogoManager.dialogo_terminado
	_completar_cadena()


func _completar_cadena() -> void:
	GameManager.eventos["cadena_completada"] = true
	# Bonus: +15 HP máximo en batalla
	GameManager.stats_jugador["hp_max"] += 15
	GameManager.stats_jugador["hp"] = min(
		GameManager.stats_jugador["hp"] + 15,
		GameManager.stats_jugador["hp_max"]
	)
	_mostrar_dialogo("cadena_completada_bonus")
	_recalcular_conflictos()


# ─────────────────────────────────────────────
#  CONFLICTO 4 — LA MULA
# ─────────────────────────────────────────────
func _setup_mula() -> void:
	# Si la mula ya está montada al volver de combate, restaurar estado
	pass  # El player.gd maneja velocidad; aquí solo conectamos


func _on_mula_interactuada(_npc) -> void:
	if dialogo_activo:
		return
	_mostrar_dialogo("mula_ofrecida")
	await DialogoManager.dialogo_terminado
	_montar_mula()


func _montar_mula() -> void:
	if player.has_method("set_velocidad"):
		player.set_velocidad(player.SPEED * 2)
	mula_node.visible = false
	# El jugador presiona Z para desmontarse (manejado en player.gd)
	# Guardamos el estado
	GameManager.eventos["mula_montada"] = true


# ─────────────────────────────────────────────
#  O'HIGGINS — DESBLOQUEO FINAL
# ─────────────────────────────────────────────
func _on_ohiggins(_npc) -> void:
	if dialogo_activo:
		return

	var completos = _recalcular_conflictos()

	if completos < 3:
		# Diálogo de espera con pista sobre qué falta
		var falta = _dialogo_ohiggins_parcial()
		_mostrar_dialogo(falta)
		return

	# Los 3 conflictos completos → mapa táctico
	_mostrar_dialogo("ohiggins_llama_batalla")
	await DialogoManager.dialogo_terminado
	_abrir_mapa_tactico()


func _dialogo_ohiggins_parcial() -> String:
	if not GameManager.eventos.get("sable_afilado", false) \
	and not GameManager.eventos.get("flanco_correcto", false) \
	and not GameManager.eventos.get("cadena_completada", false):
		return "ohiggins_espera_todo"

	if not GameManager.eventos.get("sable_afilado", false):
		return "ohiggins_falta_sable"

	if not GameManager.eventos.get("flanco_correcto", false):
		return "ohiggins_falta_flanco"

	if not GameManager.eventos.get("cadena_completada", false):
		return "ohiggins_falta_cadena"

	return "ohiggins_espera_todo"


func _abrir_mapa_tactico() -> void:
	GameManager.mapa_tactico_completado = true
	get_tree().change_scene_to_file("res://scenes/ui/mapa_tactico.tscn")


# ─────────────────────────────────────────────
#  PATRULLAS
# ─────────────────────────────────────────────
func _on_patrulla_interactuada(patrulla: Node) -> void:
	# Las patrullas del acto 3 son enemigas → combate directo
	GameManager.posicion_guardada = player.global_position
	GameManager.ultima_patrulla_enfrentada = patrulla.name
	GameManager.acto_actual = 3
	print("DEBUG acto_actual antes de combate: ", GameManager.acto_actual)
	get_tree().change_scene_to_file("res://scenes/combat/combate.tscn")


func _marcar_patrulla_vencida(nombre: String) -> void:
	var key = "patrulla_acto3_" + nombre
	GameManager.eventos[key] = true


# Llamar desde combate.gd al volver victorioso al acto 3
func ocultar_patrulla_vencida() -> void:
	var nombre = GameManager.ultima_patrulla_enfrentada
	if nombre == "":
		return
	for p in patrullas.get_children():
		if p.name == nombre:
			p.visible = false
			p.ya_interactuado = true
	_marcar_patrulla_vencida(nombre)


# ─────────────────────────────────────────────
#  SALIDA NORTE → BATALLA
# ─────────────────────────────────────────────
func _on_salida_norte(body: Node) -> void:
	if body == player:
		if not _conflictos_minimos_completos():
			_mostrar_dialogo("no_listo_para_batalla")
			return
		GameManager.acto_actual = 4
		get_tree().change_scene_to_file("res://scenes/combat/batalla_chacabuco.tscn")


func _conflictos_minimos_completos() -> bool:
	# Al menos O'Higgins debe haber dado la orden (3 conflictos)
	return GameManager.mapa_tactico_completado


# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
func _recalcular_conflictos() -> int:
	conflictos_completos = 0
	if GameManager.eventos.get("sable_afilado", false):
		conflictos_completos += 1
	if GameManager.eventos.get("flanco_correcto", false):
		conflictos_completos += 1
	if GameManager.eventos.get("cadena_completada", false):
		conflictos_completos += 1
	return conflictos_completos


func _mostrar_dialogo(id: String) -> void:
	dialogo_activo = true
	dialogo_ui.iniciar_dialogo(id)
	await DialogoManager.dialogo_terminado
	dialogo_activo = false


# ─────────────────────────────────────────────
#  PANEL DE OPCIONES (menú flanco)
#  Crea un Control simple con botones en pantalla
# ─────────────────────────────────────────────
func _crear_panel_opciones(titulo: String, opciones: Array, callback: String) -> Control:
	var panel = PanelContainer.new()
	panel.z_index = 10
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.position = Vector2(80, 300)

	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	var label = Label.new()
	label.text = titulo
	vbox.add_child(label)

	for i in opciones.size():
		var btn = Button.new()
		btn.text = opciones[i]
		btn.connect("pressed", Callable(self, callback).bind(i))
		btn.connect("pressed", panel.queue_free)
		vbox.add_child(btn)

	return panel
