import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="assets/models/Animation personaje.glb")

print("=== OBJECTS IN Animation personaje.glb ===")
for obj in bpy.data.objects:
    print(f"Obj: {obj.name}, type: {obj.type}, mat: {[m.name for m in obj.data.materials] if obj.type == 'MESH' else 'N/A'}")

for mat in bpy.data.materials:
    print(f"Material: {mat.name}, use_nodes: {mat.use_nodes}")
    if mat.node_tree:
        for node in mat.node_tree.nodes:
            if node.type == 'TEX_IMAGE' and node.image:
                print(f"   Image texture: {node.image.name}, filepath: {node.image.filepath}")
            elif node.type == 'BSDF_PRINCIPLED':
                base_col = node.inputs['Base Color'].default_value[:]
                print(f"   BSDF Base Color: {base_col}")

