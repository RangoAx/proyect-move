import bpy

# Inspect cabin in blender
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="assets/models/world/cabin.glb")
for obj in bpy.data.objects:
    print(f"Obj: {obj.name}, dim: {obj.dimensions}, loc: {obj.location}")

