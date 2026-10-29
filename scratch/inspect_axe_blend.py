import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="assets/models/pawns/enemy/enemy axe/Enemigo hacha.glb")

print("=== OBJECTS IN Enemigo hacha.glb ===")
for obj in bpy.data.objects:
    print(f"Obj: {obj.name}, type: {obj.type}, mat: {[m.name for m in obj.data.materials] if obj.type == 'MESH' else 'N/A'}")

for mat in bpy.data.materials:
    print(f"Material: {mat.name}")

