extends CanvasLayer

@onready var label_comida = $Panel/LabelComida
@onready var label_pala = $Panel/LabelPala
@onready var label_ungüento = $Panel/LabelUngüento

func _process(delta: float) -> void:
	label_comida.text = "Comida: %d" % GameManager.inventario["comida"]
	label_pala.text = "Pala: %s" % ("Sí" if GameManager.inventario["pala"] else "No")
	label_ungüento.text = "Ungüento: %s" % ("Sí" if GameManager.inventario["ungüento"] else "No")
