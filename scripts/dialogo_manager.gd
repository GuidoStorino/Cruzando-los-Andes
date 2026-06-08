extends Node

signal dialogo_terminado

var dialogos = {
	"intro_sanmartin": [
		"General San Martín: El momento ha llegado. Debemos cruzar los Andes.",
		"General San Martín: Chile nos espera. Y con Chile, la libertad de América.",
	],
	"soldado_inocente_1": [
		"Soldado Ramos: Mi General, llevo tres años esperando este momento.",
		"Soldado Ramos: Vi al nuevo recluta merodeando el depósito de armas anoche. Raro, ¿no?",
	],
	"cabildo_neutral": [
		"Cabildo: General, aún no tenemos información suficiente.",
	],
	"cabildo_alerta": [
		"Cabildo: General, tenemos un problema grave.",
		"Cabildo: Hay un espía infiltrado entre sus hombres.",
		"Cabildo: Debe descubrirlo antes de partir.",
	],
	"cabildo_sable_post_espia": [
		"Cabildo: General, eliminó la amenaza. El ejército está a salvo.",
		"Cabildo: En nombre del pueblo de Mendoza, le hacemos entrega de este sable.",
		"Cabildo: Que lo guíe hacia la victoria y la libertad de América.",
		"San Martín: Lo acepto con honor. No lo desenvainaré sin razón, ni lo envainaré sin honor.",
	],
	"soldado_inocente_2": [
		"Soldado Pérez: A sus órdenes, San Martín. Una observación...",
		"Soldado Pérez: López anda haciendo preguntas sobre las rutas del cruce.",
	],
	"soldado_inocente_3": [
		"Soldado López: Mi General, desconfíe de quien no mira a los ojos.",
		"Soldado López: Ramos y Cabral estuvieron hablando en secreto.",
	],
	"soldado_espia": [
		"Soldado Quiroga: Mi General. Todo tranquilo por aquí.",
		"Soldado Quiroga: Las carreteras están despejadas esta mañana...",
	],
	"acusacion_correcta": [
		"San Martín: Quiroga. Sé quién sos.",
		"Quiroga: ¡Joder! ¡No llegarán a Chile!",
	],
	"acusacion_incorrecta": [
		"San Martín: Sos el espía.",
		"Soldado: ¿Yo?! Mi General, juro por mi vida que es un error.",
		"San Martín: ...Me equivoqué. El espía sigue suelto y nuestros planes están comprometidos.",
	],
	"cabral_reclutamiento": [
		"Cabral: Hola San Martín, soy Juan Bautista Cabral. Vengo a ofrecer mi vida por la patria.",
		"San Martín: Bienvenido, soldado. La patria necesita hombres como vos.",
		"Cabral: A sus órdenes, mi General. Hasta el último aliento.",
	],
	"cabildo_sable": [
		"Cabildo: General San Martín, el pueblo de Mendoza le hace entrega de este sable.",
		"Cabildo: Que lo guíe hacia la victoria y la libertad de América.",
		"San Martín: Lo acepto con honor. No lo desenvainaré sin razón, ni lo envainaré sin honor.",
	],
	"cabral_travesia": [
		"Cabral: Mi General, los hombres están agotados. Pero nadie se rinde.",
		"San Martín: Eso es lo que nos diferencia de ellos, Cabral. La voluntad.",
		"Cabral: Cruzaremos estos Andes aunque sea lo último que hagamos.",
	],
	"cabral_antes_chacabuco": [
		"Cabral: Mi General... ¿cree que mañana ganaremos?",
		"San Martín: No lo creo, Cabral. Lo sé.",
		"Cabral: Entonces mañana festejamos. Cuídese, mi General.",
	],
	"ohiggins_encuentro": [
		"O'Higgins: San Martín, los realistas están mejor posicionados de lo que pensábamos.",
		"San Martín: Eso no cambia nada. Chile será libre mañana.",
		"O'Higgins: Juntos, amigo. Juntos.",
	],
	"cabral_salva_sanmartin": [
		"Cabral: ¡CUIDADO, MI GENERAL!",
		"*Cabral recibe el golpe destinado a San Martín*",
		"San Martín: ¡Cabral! ¡Cabral, hablame!",
		"Cabral: ...no se preocupe, mi General. Muero contento... hemos batido al enemigo.",
	],
	"fin_batalla": [
		"San Martín: Chile es libre. Pero el precio fue alto.",
		"O'Higgins: Su sacrificio no será olvidado, General.",
	],
	"rechazo_gobierno": [
		"Pueblo de Santiago: ¡San Martín! ¡Gobernador! ¡Gobernador!",
		"San Martín: Agradezco el honor. Pero no vine a gobernar Chile.",
		"San Martín: Vine a liberarlo. Mi camino sigue hacia el norte.",
		"O'Higgins: América no lo olvidará, amigo.",
	],
	"cabral_final": [
		"Cabral: Mi General... lo logramos.",
		"San Martín: Lo logramos, Cabral. Descansá.",
		"Cabral: ¿Y ahora qué?",
		"San Martín: Ahora... Perú.",
	],
	"soldado_pista_1": [
	"Soldado Rivas: Vi al cabo Herrera ir hacia el norte con su mula.",
	"Soldado Rivas: Fue dispuesto a explorar pero no volvió.",
],
"soldado_pista_2": [
	"Soldado Núñez: Tenga cuidado, mi General.",
	"Hay patrullas enemigas en todas partes.",
],
"soldado_pista_3": [
	"Soldado Díaz: Vi huellas de mula yendo hacia el norte.",
	"Soldado Díaz: Pero el paso está bloqueado por la nieve. Nadie puede pasar.",
],
"soldado_pista_4": [
	"Soldado Mora: Sin novedades por acá...",
	"Sólo espero que no esté herido, pero deberíamos mantener al médico alerta",
],
"curandero_sin_comida": [
	"Médico: Para sanarla necesito un ungüento de yuyos.",
	"Si tan solo consiguiéramos algunas hierbas tal vez podría hacer algo...",
],
"curandero_con_comida": [
	"Curandero: Bien, esto nos va a servir mucho.",
	"Curandero: Tomá el ungüento. Ojalá llegues a tiempo.",
],
"curandero_ya_entregado": [
	"Curandero: Ya te di el ungüento. ¡Andá a buscar a ese soldado!",
],
"campamento_descanso": [
	"Aquí podés descansar y recuperar fuerzas.",
	"San Martín descansa brevemente. El ejército lo necesita en pie.",
],
"paso_bloqueado_sin_pala": [
	"El paso está bloqueado por nieve y hielo.",
	"Necesitás algo para despejarlo.",
],
"paso_bloqueado_con_pala": [
	"San Martín usa la pala para despejar la nieve.",
],
"mula_sin_ungüento": [
	"La mula de Herrera está herida. No puede moverse.",
],
"mula_con_ungüento": [
	"San Martín aplica el ungüento en la mula.",
	"La mula se recupera lentamente."
],
"soldado_perdido_encontrado": [
	"Cabo Herrera: ¡Mi General! No podía abandonar a mi mula.",
	"Cabo Herrera: Gracias por venir a buscarme.",
	"San Martín: Nadie se queda atrás, Herrera. Volvamos al campamento.",
	"Cabral: ¡Lo encontramos! El ejército está completo, mi General.",
],
"cabral_acto2_inicio": [
	"Cabral: Mi General, el cabo Herrera no regresó.",
	"Cabral: Fue hacia el norte con su mula. Deberíamos buscarlo.",
	"San Martín: Tenés razón. Hablemos con los soldados, alguien sabe algo.",
],
# ═══════════════════════════════════════════════════════════════
#  DIÁLOGOS ACTO 3 — VALLE DE CHACABUCO
#  Agregar dentro del diccionario `dialogos` en dialogo_manager.gd
# ═══════════════════════════════════════════════════════════════

# ── CONFLICTO 1: La piedra de afilar ──────────────────────────

	"piedra_encontrada": [
		"Encontraste una piedra de afilar.",
		"Quizás el armero del campamento pueda usarla.",
	],

	"armero_sin_piedra": [
		"Armero: Tu sable está bien, General... pero podría estar mejor.",
		"Armero: Si encontraras una piedra de afilar, podría dejarlo como nuevo.",
	],

	"armero_afila_sable": [
		"Armero: ¡Excelente piedra, mi General!",
		"Armero: Con esto el Sable Corvo cortará el aire antes de tocar al enemigo.",
		"El Sable Corvo ha sido afilado. Su daño aumenta permanentemente.",
	],
	
	"mula_ya_montada": [
	"Soldado: Ya está montado, General. Presione Z para bajar.",
],

	"armero_ya_afilado": [
		"Armero: El sable ya está en perfectas condiciones, General.",
		"Armero: No hay nada más que pueda hacer por él.",
	],

# ── CONFLICTO 2: Mini juego de lógica ─────────────────────────

	"explorador_1_falso": [
		"Explorador Mendez: General, mis hombres confirmaron que el grueso realista está en el flanco izquierdo.",
		"Explorador Mendez: Atacar por ahí los tomará por sorpresa.",
		"Nota: algo en su mirada no transmite confianza.",
	],

	"explorador_2_correcto": [
		"Explorador Quirós: General, he rastreado personalmente el terreno.",
		"Explorador Quirós: El flanco derecho está desguarnecido. Es nuestra oportunidad.",
		"Explorador Quirós: Los realistas no esperan un ataque por allí.",
	],

	"oficial_espera_exploradores": [
		"Oficial Vargas: General, antes de decidir debería escuchar a los dos exploradores.",
		"Oficial Vargas: Uno está en el noroeste, el otro en el noreste del campamento.",
	],

	"oficial_presenta_mapa": [
		"Oficial Vargas: Bien, General. Aquí está el mapa táctico.",
		"Oficial Vargas: El explorador del noroeste señala el flanco izquierdo.",
		"Oficial Vargas: El del noreste señala el derecho. Yo creo que el derecho es correcto.",
		"Oficial Vargas: La decisión es suya.",
	],

	"flanco_izquierda": [
		"Decidiste atacar por la izquierda.",
		"Los realistas estarán preparados allí... pero algo es algo.",
	],

	"flanco_centro": [
		"Decidiste atacar por el centro.",
		"Una táctica directa. Los realistas podrían resistir más de lo esperado.",
	],

	"flanco_derecha_correcto": [
		"Decidiste atacar por la derecha.",
		"Oficial Vargas: ¡Excelente elección, General! El flanco derecho los tomará completamente desprevenidos.",
		"Ventaja táctica asegurada: tendrás una opción extra en el mapa táctico.",
	],

	"oficial_ya_decidido": [
		"Oficial Vargas: El plan de ataque ya está decidido, General.",
		"Oficial Vargas: Solo resta ejecutarlo.",
	],

# ── CONFLICTO 3: Cadena de favores ────────────────────────────

	"soldado_a_necesita_vendas": [
		"Soldado Acosta: General... estoy herido. No tengo vendas.",
		"El soldado Carrizo las tiene, pero había marchado para ayudar al soldado Benítez.",
		"No entiendo bien qué pasó.",
	],

	"soldado_a_agradecido": [
		"Soldado Acosta: Gracias, General. La herida ya está vendada.",
		"Soldado Acosta: Pelearemos con todo mañana.",
	],

	"soldado_b_antes_de_a": [
		"Soldado Benítez: ¿Qué se le ofrece, General?",
	],

	"soldado_b_perdio_fusil": [
		"Soldado Benítez: General... perdí mi fusil cruzando el paso.",
		"Sé que es una vergüenza. Pero si alguien lo encontrara...",
		"Lo vi caer cerca de los riscos del noreste.",
	],

	"soldado_b_recibe_fusil": [
		"Soldado Benítez: ¡Mi fusil! General, no sé cómo agradecerle.",
		"Soldado Benítez: Ahora Carrizo ya no tiene excusa para no ayudar a Acosta.",
	],

	"soldado_b_agradecido": [
		"Soldado Benítez: Gracias de nuevo, General. Estoy listo para la batalla.",
	],

	"fusil_encontrado": [
		"Encontraste un fusil entre las rocas.",
		"Podría ser el del soldado que lo estaba buscando.",
	],

	"soldado_c_espera": [
		"Soldado Carrizo: ¡Hola San Martín! Cerca de los riscos hay patrullas realistas demasiado fuertes para nosotros.",
		"San Martín: Supongo que si se quiere un trabajo bien hecho, tiene que hacerlo uno mismo. Vaya a darle vendas al soldado Acosta.",
		"Soldado Carrizo: Sí, mi General."
	],

	"soldado_c_da_vendas": [
		"Soldado Carrizo: Benítez ya tiene su fusil. Ya le di las vendas a Acosta, General",
	],

	"soldado_c_contento": [
		"Soldado Carrizo: Todo está en orden. Listos para Chacabuco.",
	],

	"cadena_completada_bonus": [
		"La cadena de favores se completó.",
		"Los tres soldados se unirán a la batalla en mejor estado.",
		"HP máximo aumentado en +15 para la batalla.",
	],

# ── CONFLICTO 4: La mula ──────────────────────────────────────

	"mula_ofrecida": [
		"Soldado: General, la mula está descansada.",
		"Soldado: Úsela para recorrer el campamento más rápido.",
		"Soldado: Cuando quiera bajar, presione Z.",
	],

# ── O'HIGGINS ─────────────────────────────────────────────────

	"ohiggins_espera_todo": [
		"O'Higgins: General San Martín, todavía no estamos listos.",
		"O'Higgins: Afile el sable, consulte a los exploradores y cuide a los soldados.",
		"O'Higgins: Cuando todo esté en orden, vuelva a hablarme.",
	],

	"ohiggins_falta_sable": [
		"O'Higgins: Casi listos, General.",
		"O'Higgins: El armero me comentó que el sable podría estar mejor.",
		"O'Higgins: Búsquele una piedra de afilar antes de la batalla.",
	],

	"ohiggins_falta_flanco": [
		"O'Higgins: Aún falta definir el plan de ataque.",
		"O'Higgins: Hable con los dos exploradores y con el oficial Vargas.",
		"O'Higgins: Necesitamos elegir el flanco antes de avanzar.",
	],

	"ohiggins_falta_cadena": [
		"O'Higgins: Hay soldados con problemas entre ellos.",
		"O'Higgins: No podemos entrar a la batalla con la moral así.",
		"O'Higgins: Resuelva lo que pasa entre Acosta, Benítez y Carrizo.",
	],

	"ohiggins_llama_batalla": [
		"O'Higgins: ¡Todo está listo, General San Martín!",
		"O'Higgins: El sable afilado, el flanco elegido, los hombres unidos.",
		"O'Higgins: Chacabuco nos espera. Chile nos espera.",
		"O'Higgins: ¡Por la libertad de América!",
	],

# ── SALIDA BLOQUEADA ──────────────────────────────────────────

	"no_listo_para_batalla": [
		"Todavía no es el momento.",
		"Hable con el General O'Higgins cuando todo esté listo.",
	],
	
		"acto4_intro": [
		"General San Martín: El paso está más alto de lo que esperábamos.",
		"O'Higgins: La ventisca empeoró en la última hora, General.",
		"O'Higgins: Debemos llegar al refugio antes de que el frío se lleve a nuestros hombres.",
		"General San Martín: Avancemos. Y que Dios nos acompañe.",
	],
	"ohiggins_acto4": [
	"O'Higgins: La ventisca no cede, General.",
	"O'Higgins: Debemos llegar al refugio antes de que anochezca.",
],
 
# ── CLIMA — mensajes periódicos ───────────────────────────────
 
	"clima_viento_fuerte": [
		"El viento arrecia. Los hombres consumen más raciones para mantener el calor.",
	],
 
	"clima_nieve_intensa": [
		"La nieve cae sin parar. El avance se hace más lento.",
	],
 
	"clima_frio_extremo": [
		"El frío es despiadado. Los soldados tiemblan pero siguen marchando.",
	],
 
	"clima_soldado_perdido": [
		"Sin comida, un soldado no puede continuar. Se queda atrás.",
		"El ejército sigue adelante, más reducido.",
	],
 
	"tormenta_pausada": [
		"El campamento ofrece algo de abrigo. La ventisca amaina por un momento.",
	],
 
	"tormenta_reanuda": [
		"La tormenta vuelve a arreciar. Hay que seguir moviéndose.",
	],
 
	"zona_ventisca_fuerte": [
		"Esta zona está completamente expuesta al viento.",
		"Los recursos se consumen más rápido aquí.",
	],
 
	"zona_ventisca_salida": [
		"Saliste de la zona más peligrosa.",
	],
 
# ── CONFLICTO 1 — EL DEPÓSITO ─────────────────────────────────
 
	"deposito_encontrado": [
		"Encontraste un depósito abandonado.",
		"Hay raciones adentro. El ejército las necesita.",
	],
	
	"aviso_refugio": [
		"San Martín, tenemos información de un refugio realista más al norte."
	],
	
	"aviso_ventisca": [
		"Hola San Martín. Esto cada vez se pone peor.",
		"Si atravesamos esto nos costará hombres y raciones de comida.",
		"Podemos rodear la zona, pero nos llevará tiempo."
	],
 
# ── CONFLICTO 2 — EL SOLDADO HERIDO ──────────────────────────
 
	"soldado_herido_dialogo": [
		"Soldado Pereyra: Mi... General... no puedo seguir.",
		"Soldado Pereyra: La pierna. Me caí en el paso. No puedo caminar.",
	],
 
	"soldado_herido_curado": [
		"Soldado Pereyra: El ungüento... ya puedo apoyar el pie.",
		"Soldado Pereyra: Gracias, General. Tome estas municiones, las guardaba para un caso extremo.",
	],
 
	"soldado_herido_sin_unguento": [
		"No tenés ungüento. No podés curarlo.",
		"El soldado se queda atrás. El ejército sigue.",
	],
 
	"soldado_herido_mula": [
		"Cargás al soldado en la mula.",
		"La mula ya no puede llevar recursos extra, pero el soldado llega al refugio.",
	],
 
	"soldado_herido_abandonado": [
		"No hay otra opción. El soldado queda atrás.",
		"General San Martín: Volveremos por él cuando esto termine.",
	],
 
# ── CONFLICTO 3 — LA MULA PERDIDA ────────────────────────────
 
	"mula_acto4_dialogo": [
		"Soldado Castro: General, una de las mulas se asustó con el viento y se escapó.",
		"Soldado Castro: La vi doblar hacia el desfiladero lateral. Podría recuperarla.",
		"Soldado Castro: Pero va a costarnos tiempo... y el frío no espera.",
	],
 
	"mula_acto4_recuperada": [
		"Encontraron la mula. Estaba resguardada entre las rocas.",
		"Puede cargar raciones extra. El esfuerzo valió la pena.",
	],
 
	"mula_acto4_abandonada": [
		"Seguís sin la mula. No hay tiempo que perder.",
	],
 
	"mula_acto4_ocupada": [
		"La mula ya lleva al soldado herido. No puede cargar nada más.",
	],
 
# ── CONFLICTO 4 — EL OFICIAL RENDIDO ─────────────────────────
 
	"oficial_rendido_dialogo": [
		"Oficial Realista: Por favor... no me dejen aquí.",
		"Oficial Realista: Estoy congelado. No puedo moverme.",
		"Oficial Realista: Soy el Teniente Varela, del regimiento de Osorio.",
	],
 
	"oficial_ayudado": [
		"General San Martín: Nadie muere en estas montañas si podemos evitarlo.",
		"Teniente Varela: Gracias, General. Les debo la vida.",
		"Teniente Varela: Hay un atajo al refugio. Sigan el río hacia el noreste.",
		"El atajo al refugio está desbloqueado.",
	],
 
	"oficial_arrestado": [
		"Soldado: Queda detenido bajo custodia del Ejército de los Andes.",
		"Teniente Varela: Está bien... no tengo fuerzas para resistir.",
		"La moral del ejército sube. El ataque aumenta en +2.",
	],
 
	"oficial_ignorado": [
		"General San Martín: No podemos detenernos.",
		"O'Higgins: El tiempo apremia, General.",
	],
 
# ── CAMPAMENTO ────────────────────────────────────────────────
 
	"campamento_acto4_dialogo": [
		"Soldado: General, hay un refugio improvisado aquí.",
		"Soldado: Podemos descansar un momento. La ventisca amainará por un rato.",
	],
 
	"campamento_ya_usado": [
		"Ya descansaron aquí. Hay que seguir moviéndose.",
	],
 
# ── FINAL DEL ACTO ────────────────────────────────────────────
 
	"acto4_no_recursos": [
		"El ejército está demasiado debilitado para avanzar.",
		"Necesitás más comida o más hombres para llegar al refugio.",
	],
 
	"acto4_derrota": [
		"El ejército no puede continuar.",
		"General San Martín: Reagrupemos fuerzas. No es el fin.",
		"Los hombres se retiran para recuperar fuerzas y volver a intentarlo.",
	],
 
	"acto4_llegada_refugio": [
		"¡El refugio! El ejército llega exhausto pero entero.",
		"General San Martín: Lo logramos. Mañana, Chacabuco.",
		"O'Higgins: Chile está al otro lado de estas montañas, General.",
		"O'Higgins: Y nosotros estamos aquí para liberarla.",
	],
 
}

func get_dialogo(id: String) -> Array:
	if dialogos.has(id):
		return dialogos[id]
	return ["..."]
