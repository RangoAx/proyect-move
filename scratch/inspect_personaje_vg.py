import bpy

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath="assets/models/Animation personaje.glb")

personaje = bpy.data.objects.get("Personaje")
if personaje:
    print(f"Mesh: {personaje.name}, vertices: {len(personaje.data.vertices)}, faces: {len(personaje.data.polygons)}")
    print(f"Vertex groups: {[vg.name for vg in personaje.vertex_groups][:15]}")
    print(f"Materials: {[m.name for m in personaje.data.materials]}")

