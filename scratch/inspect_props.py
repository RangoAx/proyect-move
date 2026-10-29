import bpy

for model in ['wooden_fence.glb', 'stone_tombstone.glb', 'arena_barricade.glb']:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=f"assets/models/world/{model}")
    for obj in bpy.data.objects:
        print(f"Model: {model} -> Obj: {obj.name}, dim: {obj.dimensions}")

