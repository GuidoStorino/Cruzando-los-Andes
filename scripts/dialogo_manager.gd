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
		"Cabildo: Hable con todos los soldados antes de actuar.",
	],
	"cabildo_alerta": [
		"Cabildo: General, tenemos un problema grave.",
		"Cabildo: Hay un espía infiltrado entre sus hombres.",
		"Cabildo: Debe descubrirlo antes de partir. ¿A quién acusa?",
	],
	"cabildo_sable_post_espia": [
		"Cabildo: General, eliminó la amenaza. El ejército está a salvo.",
		"Cabildo: En nombre del pueblo de Mendoza, le hacemos entrega de este sable.",
		"Cabildo: Que lo guíe hacia la victoria y la libertad de América.",
		"San Martín: Lo acepto con honor. No lo desenvainaré sin razón, ni lo envainaré sin honor.",
	],
	"soldado_inocente_2": [
		"Soldado Pérez: A sus órdenes, mi General.",
		"Soldado Pérez: Ese Quiroga llegó hace poco y ya anda haciendo preguntas sobre las rutas del cruce.",
	],
	"soldado_inocente_3": [
		"Soldado López: Mi General, desconfíe de quien no mira a los ojos.",
		"Soldado López: Ramos y Quiroga estuvieron hablando en secreto esta mañana.",
	],
	"soldado_espia": [
		"Soldado Quiroga: Eh... buenas, mi General. Todo tranquilo por aquí.",
		"Soldado Quiroga: No sé nada de ningún depósito. Yo solo... estaba dando una vuelta.",
	],
	"acusacion_correcta": [
		"San Martín: Quiroga. Sé quién sos.",
		"Quiroga: ¡Maldición! ¡No llegarán a Chile!",
	],
	"acusacion_incorrecta": [
		"San Martín: Sos el espía.",
		"Soldado: ¿Yo?! Mi General, juro por mi vida que es un error.",
		"San Martín: ...Me equivoqué. El espía sigue suelto y nuestros planes están comprometidos.",
	],
	"cabral_reclutamiento": [
		"Cabral: Mi General, soy Juan Bautista Cabral. Vengo a ofrecer mi vida por la patria.",
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
}

func get_dialogo(id: String) -> Array:
	if dialogos.has(id):
		return dialogos[id]
	return ["..."]
