import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="assets/models/Animation personaje.glb")

personaje = bpy.data.objects.get("Personaje")
if personaje:
    uv_layer = personaje.data.uv_layers.active
    print("UV Layer:", uv_layer.name if uv_layer else "None")
    
    # Check texture image
    for mat in personaje.data.materials:
        print("Material:", mat.name)
        if mat.node_tree:
            for node in mat.node_tree.nodes:
                if node.type == 'TEX_IMAGE' and node.image:
                    img = node.image
                    print(f"Image: {img.name}, size: {img.size[0]}x{img.size[1]}, filepath: {img.filepath}")

