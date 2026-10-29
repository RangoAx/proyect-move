import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="assets/models/pawns/enemy/enemy pitchfork/Enemigo trinche.glb")

print("=== OBJECTS IN Enemigo trinche.glb ===")
for obj in bpy.data.objects:
    print(f"Obj: {obj.name}, type: {obj.type}, mat: {[m.name for m in obj.data.materials] if obj.type == 'MESH' else 'N/A'}")

for mat in bpy.data.materials:
    print(f"Material: {mat.name}")
    if mat.node_tree:
        for node in mat.node_tree.nodes:
            if node.type == 'BSDF_PRINCIPLED':
                print(f"   BSDF Base Color: {node.inputs['Base Color'].default_value[:]}")

