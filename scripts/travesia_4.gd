extends Node2D
 
# ─────────────────────────────────────────────
#  REFERENCIAS
# ─────────────────────────────────────────────
@onready var dialogo_ui  = $DialogoUI
@onready var player      = $Player
@onready var npcs        = $Objetos/NPCs
@onready var items_node  = $Objetos/Items
@onready var salida_norte = $SalidaMapa
 
# NPCs — asignar en Inspector
@onready var sanmartin        = $Objetos/NPCs/NPC        # Diálogo inicial
@onready var ohiggins         = $Objetos/NPCs/NPC2       # Zona baja, diálogo inicial
@onready var soldado_herido   = $Objetos/NPCs/NPC3       # Zona alta
@onready var oficial_rendido  = $Objetos/NPCs/NPC4       # Zona media
@onready var soldado_mula     = $Objetos/NPCs/NPC5       # Zona lateral (mula perdida)
@onready var campamento_npc   = $Objetos/NPCs/NPC6       # Campamento improvisado (pausa clima)
 
# Ítems
@onready var item_comida_deposito = $Objetos/Items/item   # Depósito zona alta
@onready var item_unguento        = $Objetos/Items/item2  # Zona media
@onready var item_comida_extra    = $Objetos/Items/item3  # Zona baja (reservas)
 
# Panel de recursos — siempre visible
@onready var panel_recursos = $UI/PanelRecursos
@onready var label_comida   = $UI/PanelRecursos/LabelComida
@onready var label_municion = $UI/PanelRecursos/LabelMunicion
@onready var label_soldados = $UI/PanelRecursos/LabelSoldados
@onready var label_clima    = $UI/PanelRecursos/LabelClima
 
# ─────────────────────────────────────────────
#  ESTADO LOCAL
# ─────────────────────────────────────────────
var dialogo_activo: bool = false
 
# Timer del clima
var timer_clima: Timer
const INTERVALO_CLIMA: float = 8.0   # segundos entre cada turno de clima
var tormenta_activa: bool = true
var tormenta_pausada: bool = false
var segundos_pausa: float = 0.0
 
# Estado del oficial rendido
enum OpcionOficial { NINGUNA, IGNORAR, AYUDAR, ARRESTAR }
var decision_oficial: OpcionOficial = OpcionOficial.NINGUNA
 
# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	GameManager.acto_actual = 4
 
	# Restaurar posición si venimos de algún reset
	if GameManager.posicion_guardada != Vector2.ZERO:
		player.global_position = GameManager.posicion_guardada
		GameManager.posicion_guardada = Vector2.ZERO
 
	# Inicializar recursos del acto si es la primera vez
	if not GameManager.eventos.get("acto4_iniciado", false):
		GameManager.recursos["comida"]    = 6
		GameManager.recursos["municion"]  = 4
		GameManager.recursos["soldados"]  = 5
		GameManager.eventos["acto4_iniciado"] = true
 
	# Ocultar ítems ya recogidos
	if GameManager.eventos.get("deposito_saqueado", false):
		item_comida_deposito.visible = false
	if GameManager.eventos.get("unguento_encontrado", false):
		item_unguento.visible = false
	if GameManager.eventos.get("comida_extra_recogida", false):
		item_comida_extra.visible = false
 
	# Ocultar NPCs ya resueltos
	if GameManager.eventos.get("soldado_herido_resuelto", false):
		soldado_herido.visible = false
	if GameManager.eventos.get("oficial_resuelto", false):
		oficial_rendido.visible = false
	if GameManager.eventos.get("mula_acto4_resuelta", false):
		soldado_mula.visible = false
 
	# Velocidad reducida por la tormenta
	player.tormenta_activa = true
 
	# Iniciar timer del clima
	_iniciar_timer_clima()
 
	# Conectar salida
	if salida_norte:
		salida_norte.connect("body_entered", _on_salida_norte)
 
	# Diálogo de apertura (solo la primera vez)
	if not GameManager.eventos.get("acto4_intro_vista", false):
		GameManager.eventos["acto4_intro_vista"] = true
		await get_tree().process_frame
		_mostrar_dialogo("acto4_intro")
 
	_actualizar_ui_recursos()
 
 
# ─────────────────────────────────────────────
#  PROCESO — pausa de tormenta
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if tormenta_pausada:
		segundos_pausa -= delta
		if segundos_pausa <= 0:
			tormenta_pausada = false
			timer_clima.paused = false
			_mostrar_dialogo("tormenta_reanuda")
	_actualizar_ui_recursos()
 
 
# ─────────────────────────────────────────────
#  TIMER DEL CLIMA
# ─────────────────────────────────────────────
func _iniciar_timer_clima() -> void:
	timer_clima = Timer.new()
	timer_clima.wait_time = INTERVALO_CLIMA
	timer_clima.autostart = true
	timer_clima.connect("timeout", _on_turno_clima)
	add_child(timer_clima)
 
 
func _on_turno_clima() -> void:
	if tormenta_pausada or not tormenta_activa:
		return
 
	# Consumir recursos
	if GameManager.recursos["comida"] > 0:
		GameManager.recursos["comida"] -= 1
	else:
		# Sin comida → pierde soldados
		if GameManager.recursos["soldados"] > 0:
			GameManager.recursos["soldados"] -= 1
			_mostrar_dialogo("clima_soldado_perdido")
		else:
			# Sin soldados → game over del acto
			_game_over_acto()
			return
 
	_actualizar_ui_recursos()
 
	# Mensaje de clima aleatorio
	var mensajes = ["clima_viento_fuerte", "clima_nieve_intensa", "clima_frio_extremo"]
	_mostrar_dialogo_sin_bloqueo(mensajes[randi() % mensajes.size()])
 
 
func _pausar_tormenta(segundos: float) -> void:
	tormenta_pausada = true
	segundos_pausa = segundos
	timer_clima.paused = true
	_mostrar_dialogo("tormenta_pausada")
 
 
func _game_over_acto() -> void:
	tormenta_activa = false
	timer_clima.stop()
	_mostrar_dialogo("acto4_derrota")
	await DialogoManager.dialogo_terminado
	GameManager.resetear_acto()
	get_tree().change_scene_to_file("res://scenes/world/travesia_4.tscn")
 
 
# ─────────────────────────────────────────────
#  UI DE RECURSOS
# ─────────────────────────────────────────────
func _actualizar_ui_recursos() -> void:
	if label_comida:
		label_comida.text   = "Comida:    %d" % GameManager.recursos["comida"]
	if label_municion:
		label_municion.text = "Munición:  %d" % GameManager.recursos["municion"]
	if label_soldados:
		label_soldados.text = "Soldados:  %d" % GameManager.recursos["soldados"]
	if label_clima:
		if tormenta_pausada:
			label_clima.text = "❄ Tormenta pausada (%.0fs)" % segundos_pausa
		else:
			label_clima.text = "❄ Ventisca activa"
 
 
# ─────────────────────────────────────────────
#  CONFLICTO 1 — EL DEPÓSITO
#  Ítem de comida en zona alta (zona de daño)
# ─────────────────────────────────────────────
# La "zona de daño" se maneja con un Area2D en la escena llamado ZonaVentisca.
# Conectar su body_entered/body_exited desde el editor o acá:
func _on_zona_ventisca_entered(body: Node) -> void:
	if body == player:
		# Duplicar velocidad de consumo en zona de tormenta fuerte
		timer_clima.wait_time = INTERVALO_CLIMA / 2.0
		_mostrar_dialogo_sin_bloqueo("zona_ventisca_fuerte")
 
 
func _on_zona_ventisca_exited(body: Node) -> void:
	if body == player:
		timer_clima.wait_time = INTERVALO_CLIMA
		_mostrar_dialogo_sin_bloqueo("zona_ventisca_salida")
 
 
# El ítem del depósito se recoge con item.gd normalmente.
# Al recogerlo (tipo "comida_deposito") se suma en item.gd y se marca el evento.
# Agregar en item.gd dentro del match:
#   "comida_deposito":
#       GameManager.recursos["comida"] += cantidad
#       GameManager.eventos["deposito_saqueado"] = true
 
 
# ─────────────────────────────────────────────
#  CONFLICTO 2 — EL SOLDADO HERIDO
# ─────────────────────────────────────────────
# Manejado en npc.gd con es_soldado_herido_acto4 = true
# Las tres opciones se resuelven con un panel de opciones igual al del flanco.
func mostrar_opciones_soldado_herido() -> void:
	if GameManager.eventos.get("soldado_herido_resuelto", false):
		return
	var opciones = ["Curar con ungüento", "Llevarlo en la mula", "Dejarlo"]
	var panel = _crear_panel_opciones("¿Qué hacés con el soldado herido?", opciones, "_on_soldado_herido_elegido")
	add_child(panel)
 
 
func _on_soldado_herido_elegido(opcion: int) -> void:
	GameManager.eventos["soldado_herido_resuelto"] = true
	soldado_herido.visible = false
	match opcion:
		0:  # Curar con ungüento
			if GameManager.inventario.get("ungüento", false):
				GameManager.inventario["ungüento"] = false
				GameManager.recursos["municion"] += 2
				GameManager.eventos["soldado_herido_curado"] = true
				_mostrar_dialogo("soldado_herido_curado")
			else:
				# Sin ungüento no puede curar → queda como dejarlo
				GameManager.eventos["soldado_herido_abandonado"] = true
				_mostrar_dialogo("soldado_herido_sin_unguento")
		1:  # Llevarlo en la mula
			GameManager.eventos["soldado_herido_mula"] = true
			# La mula no puede cargar recursos extra este acto
			GameManager.eventos["mula_acto4_ocupada"] = true
			_mostrar_dialogo("soldado_herido_mula")
		2:  # Dejarlo
			GameManager.recursos["soldados"] -= 1
			GameManager.eventos["soldado_herido_abandonado"] = true
			_mostrar_dialogo("soldado_herido_abandonado")
	_actualizar_ui_recursos()
 
 
# ─────────────────────────────────────────────
#  CONFLICTO 3 — LA MULA PERDIDA
# ─────────────────────────────────────────────
# Manejado en npc.gd con es_soldado_mula_acto4 = true
func mostrar_opciones_mula_acto4() -> void:
	if GameManager.eventos.get("mula_acto4_resuelta", false):
		return
	if GameManager.eventos.get("mula_acto4_ocupada", false):
		_mostrar_dialogo("mula_acto4_ocupada")
		return
	var opciones = ["Ir a buscarla (tarda tiempo)", "Seguir sin ella"]
	var panel = _crear_panel_opciones("La mula se escapó. ¿Qué hacés?", opciones, "_on_mula_acto4_elegida")
	add_child(panel)
 
 
func _on_mula_acto4_elegida(opcion: int) -> void:
	GameManager.eventos["mula_acto4_resuelta"] = true
	soldado_mula.visible = false
	match opcion:
		0:  # Ir a buscarla — consume tiempo (2 turnos de clima extra)
			_on_turno_clima()
			_on_turno_clima()
			GameManager.eventos["mula_acto4_recuperada"] = true
			GameManager.recursos["comida"] += 2   # puede cargar más
			_mostrar_dialogo("mula_acto4_recuperada")
		1:  # Seguir sin ella
			_mostrar_dialogo("mula_acto4_abandonada")
	_actualizar_ui_recursos()
 
 
# ─────────────────────────────────────────────
#  CONFLICTO 4 — EL OFICIAL RENDIDO
# ─────────────────────────────────────────────
# Manejado en npc.gd con es_oficial_rendido_acto4 = true
func mostrar_opciones_oficial_rendido() -> void:
	if GameManager.eventos.get("oficial_resuelto", false):
		return
	var opciones = ["Ayudarlo", "Arrestarlo", "Ignorarlo"]
	var panel = _crear_panel_opciones("Encontrás a un oficial realista congelado.", opciones, "_on_oficial_rendido_elegido")
	add_child(panel)
 
 
func _on_oficial_rendido_elegido(opcion: int) -> void:
	GameManager.eventos["oficial_resuelto"] = true
	oficial_rendido.visible = false
	match opcion:
		0:  # Ayudar → da atajo + ítem
			decision_oficial = OpcionOficial.AYUDAR
			GameManager.eventos["oficial_ayudado"] = true
			GameManager.eventos["atajo_desbloqueado"] = true
			_mostrar_dialogo("oficial_ayudado")
		1:  # Arrestar → bonus moral en batalla
			decision_oficial = OpcionOficial.ARRESTAR
			GameManager.eventos["oficial_arrestado"] = true
			GameManager.stats_jugador["ataque"] += 2
			_mostrar_dialogo("oficial_arrestado")
		2:  # Ignorar → nada
			decision_oficial = OpcionOficial.IGNORAR
			_mostrar_dialogo("oficial_ignorado")
 
 
# ─────────────────────────────────────────────
#  CAMPAMENTO — PAUSA EL CLIMA
# ─────────────────────────────────────────────
# Manejado en npc.gd con es_campamento = true (ya existe)
# Al interactuar llama a este método desde npc.gd:
func pausar_clima_campamento() -> void:
	if GameManager.eventos.get("campamento_acto4_usado", false):
		_mostrar_dialogo("campamento_ya_usado")
		return
	GameManager.eventos["campamento_acto4_usado"] = true
	_pausar_tormenta(30.0)
 
 
# ─────────────────────────────────────────────
#  SALIDA NORTE → ACTO 5
# ─────────────────────────────────────────────
func _on_salida_norte(body: Node) -> void:
	if body != player:
		return
 
	# Necesita al menos algo de comida y soldados para avanzar
	if GameManager.recursos["comida"] <= 0 and GameManager.recursos["soldados"] <= 1:
		_mostrar_dialogo("acto4_no_recursos")
		return
 
	tormenta_activa = false
	timer_clima.stop()
 
	# Aplicar consecuencias en stats para batalla
	_aplicar_consecuencias_batalla()
 
	GameManager.acto_actual = 5
	GameManager.completar_evento("travesia_completada")
	get_tree().change_scene_to_file("res://scenes/combat/batalla_chacabuco.tscn")
 
 
func _aplicar_consecuencias_batalla() -> void:
	# Comida > 5 → +20 HP máximo
	if GameManager.recursos["comida"] >= 5:
		GameManager.stats_jugador["hp_max"] += 20
		GameManager.stats_jugador["hp"] = min(
			GameManager.stats_jugador["hp"] + 20,
			GameManager.stats_jugador["hp_max"]
		)
	# Munición > 3 → se guarda en GameManager para combate
	# (batalla_chacabuco.gd lo lee desde GameManager.recursos["municion"])
 
	# Soldado herido curado → NPC especial en batalla (evento ya guardado)
	# Mula recuperada → opción táctica extra (evento ya guardado)
	# Oficial ayudado → atajo en batalla (evento ya guardado)
	# Oficial arrestado → +2 ataque ya aplicado arriba
 
 
# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
func _mostrar_dialogo(id: String) -> void:
	dialogo_activo = true
	dialogo_ui.iniciar_dialogo(id)
	await DialogoManager.dialogo_terminado
	dialogo_activo = false
 
 
func _mostrar_dialogo_sin_bloqueo(id: String) -> void:
	if dialogo_activo:
		return
	dialogo_ui.iniciar_dialogo(id)
 
 
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


func _on_zona_ventisca_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_zona_ventisca_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
