import bpy

img = bpy.data.images.load("assets/models/Animation personaje_jugador texture.png")
print("Loaded texture:", img.name, img.size[0], img.size[1])

# Sample some pixel colors across the texture
pixels = list(img.pixels)
print(f"Total pixel floats: {len(pixels)}")
# Sample center and corners
for coord in [(100, 100), (500, 500), (800, 800), (250, 750)]:
    idx = (coord[1] * img.size[0] + coord[0]) * 4
    r, g, b, a = pixels[idx:idx+4]
    print(f"Pixel at {coord}: R={r:.2f}, G={g:.2f}, B={b:.2f}, A={a:.2f}")

