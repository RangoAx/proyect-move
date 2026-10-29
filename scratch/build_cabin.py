import bpy
import bmesh
import math
import os

bpy.ops.wm.read_factory_settings(use_empty=True)

# Cabin dimensions
w = 6.0   # Width
d = 7.5   # Depth
h = 3.6   # Wall height
roof_h = 2.4 # Roof ridge height

# Materials
wood_wall_mat = bpy.data.materials.new(name="CabinWoodWalls")
wood_wall_mat.use_nodes = True
bsdf1 = wood_wall_mat.node_tree.nodes.get("Principled BSDF")
if bsdf1:
    bsdf1.inputs["Base Color"].default_value = (0.28, 0.18, 0.11, 1.0) # Dark weathered timber
    bsdf1.inputs["Roughness"].default_value = 0.85

wood_trim_mat = bpy.data.materials.new(name="CabinWoodTrim")
wood_trim_mat.use_nodes = True
bsdf2 = wood_trim_mat.node_tree.nodes.get("Principled BSDF")
if bsdf2:
    bsdf2.inputs["Base Color"].default_value = (0.16, 0.10, 0.06, 1.0) # Dark logs/beams
    bsdf2.inputs["Roughness"].default_value = 0.9

roof_mat = bpy.data.materials.new(name="CabinRoof")
roof_mat.use_nodes = True
bsdf3 = roof_mat.node_tree.nodes.get("Principled BSDF")
if bsdf3:
    bsdf3.inputs["Base Color"].default_value = (0.18, 0.16, 0.14, 1.0) # Weathered slate/shingles
    bsdf3.inputs["Roughness"].default_value = 0.8

interior_mat = bpy.data.materials.new(name="CabinDarkInterior")
interior_mat.use_nodes = True
bsdf4 = interior_mat.node_tree.nodes.get("Principled BSDF")
if bsdf4:
    bsdf4.inputs["Base Color"].default_value = (0.02, 0.02, 0.02, 1.0) # Shadowy void
    bsdf4.inputs["Roughness"].default_value = 1.0

# 1. Main building body
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h/2))
body = bpy.context.active_object
body.name = "CabinBody"
body.scale = (w, d, h)
body.data.materials.append(wood_wall_mat)

# 2. Doorway opening (cutout on front face Y = -d/2)
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -d/2 + 0.1, 1.2))
door = bpy.context.active_object
door.name = "DoorVoid"
door.scale = (1.6, 0.5, 2.4)
door.data.materials.append(interior_mat)

# Door frame
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -d/2 - 0.05, 1.25))
frame = bpy.context.active_object
frame.name = "DoorFrame"
frame.scale = (1.8, 0.2, 2.5)
frame.data.materials.append(wood_trim_mat)

# 3. Corner logs/pillars
for cx in [-w/2, w/2]:
    for cy in [-d/2, d/2]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=h, location=(cx, cy, h/2), vertices=8)
        col = bpy.context.active_object
        col.data.materials.append(wood_trim_mat)

# 4. Roof (Prism / triangular gable)
bm = bmesh.new()
# Create triangular prism for roof
r_w = (w / 2) + 0.4
r_d = (d / 2) + 0.5
v1 = bm.verts.new((-r_w, -r_d, h - 0.2))
v2 = bm.verts.new((r_w, -r_d, h - 0.2))
v3 = bm.verts.new((0, -r_d, h + roof_h))
v4 = bm.verts.new((-r_w, r_d, h - 0.2))
v5 = bm.verts.new((r_w, r_d, h - 0.2))
v6 = bm.verts.new((0, r_d, h + roof_h))

bm.faces.new((v1, v2, v3)) # Front gable
bm.faces.new((v4, v6, v5)) # Back gable
bm.faces.new((v1, v3, v6, v4)) # Left slope
bm.faces.new((v2, v5, v6, v3)) # Right slope
bm.faces.new((v1, v4, v5, v2)) # Bottom ceiling

roof_mesh = bpy.data.meshes.new("RoofMesh")
bm.to_mesh(roof_mesh)
bm.free()

roof_obj = bpy.data.objects.new("CabinRoof", roof_mesh)
bpy.context.collection.objects.link(roof_obj)
roof_obj.data.materials.append(roof_mat)

# Join into single modular cabin asset
bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = body
bpy.ops.object.join()
body.name = "RusticCabin"

# Apply all transforms
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

out_glb = r"c:\Godot Proyects\proyect-move\assets\models\world\cabin.glb"
bpy.ops.export_scene.gltf(filepath=out_glb, export_format='GLB', export_apply=True)
print("SUCCESS CABIN EXPORTED TO:", out_glb)

