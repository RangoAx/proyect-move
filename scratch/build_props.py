import bpy
import os

# --- 1. Wooden Fence ---
bpy.ops.wm.read_factory_settings(use_empty=True)
wood_mat = bpy.data.materials.new(name="FenceWood")
bsdf = wood_mat.node_tree.nodes.get("Principled BSDF")
if bsdf:
    bsdf.inputs["Base Color"].default_value = (0.32, 0.22, 0.14, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85

# Posts (2 vertical posts)
bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=1.2, location=(-1.2, 0, 0.6), vertices=8)
p1 = bpy.context.active_object
p1.data.materials.append(wood_mat)

bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=1.2, location=(1.2, 0, 0.6), vertices=8)
p2 = bpy.context.active_object
p2.data.materials.append(wood_mat)

# Rails (2 horizontal rails)
for rz in [0.4, 0.85]:
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, rz))
    rail = bpy.context.active_object
    rail.scale = (2.5, 0.08, 0.12)
    rail.data.materials.append(wood_mat)

bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = p1
bpy.ops.object.join()
p1.name = "WoodenFence"
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
bpy.ops.export_scene.gltf(filepath=r"c:\Godot Proyects\proyect-move\assets\models\world\wooden_fence.glb", export_format='GLB')

# --- 2. Stone Tombstone ---
bpy.ops.wm.read_factory_settings(use_empty=True)
stone_mat = bpy.data.materials.new(name="GraveStone")
bsdf_s = stone_mat.node_tree.nodes.get("Principled BSDF")
if bsdf_s:
    bsdf_s.inputs["Base Color"].default_value = (0.38, 0.40, 0.42, 1.0)
    bsdf_s.inputs["Roughness"].default_value = 0.75

# Plinth
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.1))
base = bpy.context.active_object
base.scale = (0.7, 0.4, 0.2)
base.data.materials.append(stone_mat)

# Upright stone with rounded top
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.65))
slab = bpy.context.active_object
slab.scale = (0.55, 0.2, 0.9)
slab.data.materials.append(stone_mat)

bev = slab.modifiers.new(name="Bevel", type='BEVEL')
bev.width = 0.08
bev.segments = 3

bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = base
bpy.ops.object.join()
base.name = "StoneTombstone"
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
bpy.ops.export_scene.gltf(filepath=r"c:\Godot Proyects\proyect-move\assets\models\world\stone_tombstone.glb", export_format='GLB')

# --- 3. Fog Arena Gate / Barricade ---
bpy.ops.wm.read_factory_settings(use_empty=True)
gate_mat = bpy.data.materials.new(name="FogGateWood")
bsdf_g = gate_mat.node_tree.nodes.get("Principled BSDF")
if bsdf_g:
    bsdf_g.inputs["Base Color"].default_value = (0.12, 0.10, 0.09, 1.0)
    bsdf_g.inputs["Roughness"].default_value = 0.9

# Heavy spiked wooden barricade
for x in [-2.0, -1.0, 0.0, 1.0, 2.0]:
    bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=3.0, location=(x, 0, 1.5), vertices=8)
    log_obj = bpy.context.active_object
    log_obj.data.materials.append(gate_mat)
    # Spike top
    bpy.ops.mesh.primitive_cone_add(radius1=0.15, depth=0.6, location=(x, 0, 3.3), vertices=8)
    spk = bpy.context.active_object
    spk.data.materials.append(gate_mat)

for bz in [0.8, 2.0]:
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, bz))
    cross = bpy.context.active_object
    cross.scale = (4.8, 0.2, 0.25)
    cross.data.materials.append(gate_mat)

bpy.ops.object.select_all(action='SELECT')
act = bpy.context.selected_objects[0]
bpy.context.view_layer.objects.active = act
bpy.ops.object.join()
act.name = "ArenaBarricade"
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
bpy.ops.export_scene.gltf(filepath=r"c:\Godot Proyects\proyect-move\assets\models\world\arena_barricade.glb", export_format='GLB')

print("SUCCESS ALL PROPS EXPORTED!")

