# Correr esto UNA VEZ como script de herramienta
@tool
extends EditorScript

func _run():
	var img = Image.create(80, 16, false, Image.FORMAT_RGB8)
	
	# Tile 0: camino (beige)
	for x in range(0, 16):
		for y in range(16):
			img.set_pixel(x, y, Color("#d4c5a9"))
	
	# Tile 1: montaña/nieve (blanco grisáceo)
	for x in range(16, 32):
		for y in range(16):
			img.set_pixel(x, y, Color("#c8d4d4"))
	
	# Tile 2: vegetación (verde oscuro)
	for x in range(32, 48):
		for y in range(16):
			img.set_pixel(x, y, Color("#2d5a27"))
	
	# Tile 3: roca (marrón)
	for x in range(48, 64):
		for y in range(16):
			img.set_pixel(x, y, Color("#6b4226"))
	
	# Tile 4: hielo/río (azul)
	for x in range(64, 80):
		for y in range(16):
			img.set_pixel(x, y, Color("#4a7fb5"))
	
	img.save_png("res://assets/tilesets/tiles_travesia.png")
	print("Textura generada!")
