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
}

func get_dialogo(id: String) -> Array:
	if dialogos.has(id):
		return dialogos[id]
	return ["..."]
