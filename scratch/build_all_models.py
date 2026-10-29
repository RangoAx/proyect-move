import bpy
import bmesh
import math
import os

PROJECT_ROOT = r"c:\Godot Proyects\proyect-move"

def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_flat_material(name, color_rgba, roughness=0.8, metallic=0.0, emission_rgba=None, emission_strength=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = color_rgba
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission_rgba and emission_strength > 0:
            if 'Emission Color' in bsdf.inputs:
                bsdf.inputs['Emission Color'].default_value = emission_rgba
                bsdf.inputs['Emission Strength'].default_value = emission_strength
            elif 'Emission' in bsdf.inputs:
                bsdf.inputs['Emission'].default_value = emission_rgba
    return mat

def export_glb(filepath):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=filepath,
        export_format='GLB',
        use_selection=False,
        export_apply=False
    )
    print(f"Exported: {filepath}")

# ─── 1. PINE TREE ─────────────────────────────────────────────────────────────
def make_pine_tree():
    reset_scene()
    mat_wood = create_flat_material("Mat_TreeBark", (0.28, 0.18, 0.10, 1.0), roughness=0.9)
    mat_leaves = create_flat_material("Mat_PineNeedles", (0.11, 0.28, 0.16, 1.0), roughness=0.7)

    # Trunk: 8-sided tapered cylinder
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.35, depth=4.0, location=(0, 0, 2.0))
    trunk = bpy.context.active_object
    trunk.name = "Trunk"
    trunk.data.materials.append(mat_wood)

    # 4 Tiers of low-poly foliage (cones)
    tiers_data = [
        (2.4, 2.2, 2.8), # (radius, height, z_center)
        (2.0, 2.0, 4.2),
        (1.5, 1.8, 5.5),
        (1.0, 1.6, 6.6)
    ]
    foliage_objs = []
    for r, h, z in tiers_data:
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=r, radius2=0.08, depth=h, location=(0, 0, z))
        cone = bpy.context.active_object
        cone.data.materials.append(mat_leaves)
        foliage_objs.append(cone)

    # Join into single object
    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = trunk
    bpy.ops.object.join()
    trunk.name = "PineTree"
    trunk.location = (0, 0, 0)
    export_glb(os.path.join(PROJECT_ROOT, "assets/models/world/pine_tree.glb"))

# ─── 2. DEAD TREE ─────────────────────────────────────────────────────────────
def make_dead_tree():
    reset_scene()
    mat_dead = create_flat_material("Mat_DeadBark", (0.18, 0.15, 0.13, 1.0), roughness=0.95)

    # Crooked trunk
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.32, depth=3.2, location=(0, 0, 1.6))
    trunk = bpy.context.active_object
    trunk.data.materials.append(mat_dead)

    # Branches
    branches = [
        ((0.15, 0.0, 2.5), (0.12, 1.8), (0.4, 0.6, 0.2)),
        ((-0.1, 0.1, 2.8), (0.10, 1.6), (-0.5, -0.4, 0.8)),
        ((0.0, -0.15, 3.2), (0.08, 1.4), (0.2, -0.7, -0.4)),
        ((0.1, 0.1, 3.6), (0.07, 1.2), (-0.3, 0.5, -0.7)),
    ]
    for loc, (r, depth), rot in branches:
        bpy.ops.mesh.primitive_cylinder_add(vertices=5, radius=r, depth=depth, location=loc, rotation=rot)
        b = bpy.context.active_object
        b.data.materials.append(mat_dead)

    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = trunk
    bpy.ops.object.join()
    trunk.name = "DeadTree"
    export_glb(os.path.join(PROJECT_ROOT, "assets/models/world/dead_tree.glb"))

# ─── 3. ROCK BOULDER ──────────────────────────────────────────────────────────
def make_rock_boulder():
    reset_scene()
    mat_stone = create_flat_material("Mat_BoulderStone", (0.42, 0.44, 0.40, 1.0), roughness=0.85)

    # Subdivided / deformed icosphere for jagged low-poly rock
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0, location=(0, 0, 0.8))
    rock = bpy.context.active_object
    rock.name = "RockBoulder"
    rock.scale = (1.4, 1.1, 0.85)
    rock.data.materials.append(mat_stone)

    # Deform vertices slightly for natural organic low-poly feel
    mesh = rock.data
    bm = bmesh.new()
    bm.from_mesh(mesh)
    for v in bm.verts:
        # Subtle displacement based on vertex position
        disp = math.sin(v.co.x * 3.0) * math.cos(v.co.y * 3.0) * 0.18
        v.co += v.normal * disp
    bm.to_mesh(mesh)
    bm.free()

    export_glb(os.path.join(PROJECT_ROOT, "assets/models/world/rock_boulder.glb"))

# ─── 4. WOODEN CRATE ──────────────────────────────────────────────────────────
def make_wooden_crate():
    reset_scene()
    mat_crate = create_flat_material("Mat_CrateWood", (0.46, 0.32, 0.18, 1.0), roughness=0.8)
    mat_iron = create_flat_material("Mat_CrateIron", (0.18, 0.20, 0.22, 1.0), roughness=0.4, metallic=0.7)

    # Main cube (0.9m)
    bpy.ops.mesh.primitive_cube_add(size=0.9, location=(0, 0, 0.45))
    crate = bpy.context.active_object
    crate.name = "WoodenCrate"
    crate.data.materials.append(mat_crate)

    # Edge trims
    bpy.ops.mesh.primitive_cube_add(size=0.92, location=(0, 0, 0.45))
    trim = bpy.context.active_object
    trim.scale = (1.02, 1.02, 0.12)
    trim.data.materials.append(mat_iron)

    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = crate
    bpy.ops.object.join()
    export_glb(os.path.join(PROJECT_ROOT, "assets/models/world/wooden_crate.glb"))

# ─── 5. WOODEN BARREL ─────────────────────────────────────────────────────────
def make_wooden_barrel():
    reset_scene()
    mat_staves = create_flat_material("Mat_BarrelWood", (0.42, 0.28, 0.16, 1.0), roughness=0.8)
    mat_hoops = create_flat_material("Mat_BarrelIron", (0.16, 0.17, 0.19, 1.0), roughness=0.4, metallic=0.8)

    # Barrel body (10-sided cylinder)
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.42, depth=1.05, location=(0, 0, 0.525))
    barrel = bpy.context.active_object
    barrel.data.materials.append(mat_staves)

    # Metal hoops
    for z in [0.22, 0.45, 0.60, 0.83]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.435, depth=0.05, location=(0, 0, z))
        hoop = bpy.context.active_object
        hoop.data.materials.append(mat_hoops)

    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = barrel
    bpy.ops.object.join()
    barrel.name = "WoodenBarrel"
    export_glb(os.path.join(PROJECT_ROOT, "assets/models/world/wooden_barrel.glb"))

# ─── 6. STREET LANTERN ────────────────────────────────────────────────────────
def make_street_lantern():
    reset_scene()
    mat_pole = create_flat_material("Mat_IronPole", (0.12, 0.13, 0.15, 1.0), roughness=0.5, metallic=0.7)
    mat_glow = create_flat_material("Mat_LanternGlow", (1.0, 0.72, 0.28, 1.0), roughness=0.2, emission_rgba=(1.0, 0.75, 0.3, 1.0), emission_strength=4.0)

    # Post
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.08, depth=2.8, location=(0, 0, 1.4))
    pole = bpy.context.active_object
    pole.data.materials.append(mat_pole)

    # Lantern cap & frame
    bpy.ops.mesh.primitive_cube_add(size=0.35, location=(0, 0, 2.8))
    frame = bpy.context.active_object
    frame.scale = (1.0, 1.0, 1.4)
    frame.data.materials.append(mat_pole)

    # Glowing inner bulb
    bpy.ops.mesh.primitive_cube_add(size=0.22, location=(0, 0, 2.8))
    bulb = bpy.context.active_object
    bulb.scale = (0.9, 0.9, 1.2)
    bulb.data.materials.append(mat_glow)

    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = pole
    bpy.ops.object.join()
    pole.name = "StreetLantern"
    export_glb(os.path.join(PROJECT_ROOT, "assets/models/world/street_lantern.glb"))

# ─── 7. PITCHFORK ─────────────────────────────────────────────────────────────
def make_pitchfork():
    reset_scene()
    mat_wood = create_flat_material("Mat_PitchforkWood", (0.45, 0.30, 0.16, 1.0), roughness=0.75)
    mat_iron = create_flat_material("Mat_PitchforkIron", (0.28, 0.30, 0.32, 1.0), roughness=0.35, metallic=0.85)

    # Shaft (1.4m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.02, depth=1.4, location=(0, 0, 0.7))
    shaft = bpy.context.active_object
    shaft.data.materials.append(mat_wood)

    # Cross head
    bpy.ops.mesh.primitive_cube_add(size=0.04, location=(0, 0, 1.42))
    head = bpy.context.active_object
    head.scale = (5.5, 0.8, 0.8)
    head.data.materials.append(mat_iron)

    # 3 Prongs
    for x_offset in [-0.09, 0.0, 0.09]:
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.012, radius2=0.002, depth=0.35, location=(x_offset, 0.02, 1.6))
        prong = bpy.context.active_object
        prong.data.materials.append(mat_iron)

    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = shaft
    bpy.ops.object.join()
    shaft.name = "Pitchfork"
    export_glb(os.path.join(PROJECT_ROOT, "assets/models/objects/pitchfork.glb"))

# ─── 8. THROWING AXE ──────────────────────────────────────────────────────────
def make_throwing_axe():
    reset_scene()
    mat_handle = create_flat_material("Mat_AxeHandle", (0.38, 0.24, 0.14, 1.0), roughness=0.8)
    mat_head = create_flat_material("Mat_AxeBlade", (0.35, 0.37, 0.40, 1.0), roughness=0.3, metallic=0.9)

    # Handle (0.55m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.022, depth=0.55, location=(0, 0, 0.275))
    handle = bpy.context.active_object
    handle.data.materials.append(mat_handle)

    # Axe Blade wedge
    bpy.ops.mesh.primitive_cube_add(size=0.14, location=(0.06, 0, 0.50))
    blade = bpy.context.active_object
    blade.scale = (1.5, 0.25, 1.1)
    blade.data.materials.append(mat_head)

    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = handle
    bpy.ops.object.join()
    handle.name = "ThrowingAxe"
    export_glb(os.path.join(PROJECT_ROOT, "assets/models/objects/hacha1.glb"))

# ─── 9. COMBAT KNIFE ──────────────────────────────────────────────────────────
def make_combat_knife():
    reset_scene()
    mat_grip = create_flat_material("Mat_KnifeGrip", (0.14, 0.15, 0.16, 1.0), roughness=0.7)
    mat_guard = create_flat_material("Mat_KnifeGuard", (0.24, 0.26, 0.28, 1.0), roughness=0.4, metallic=0.8)
    mat_blade = create_flat_material("Mat_KnifeBlade", (0.68, 0.70, 0.74, 1.0), roughness=0.25, metallic=0.95)

    # Grip (0.13m)
    bpy.ops.mesh.primitive_cube_add(size=0.03, location=(0, 0, 0.065))
    grip = bpy.context.active_object
    grip.scale = (0.75, 1.0, 4.3)
    grip.data.materials.append(mat_grip)

    # Guard
    bpy.ops.mesh.primitive_cube_add(size=0.03, location=(0, 0, 0.135))
    guard = bpy.context.active_object
    guard.scale = (1.2, 2.6, 0.4)
    guard.data.materials.append(mat_guard)

    # Blade (0.22m)
    bpy.ops.mesh.primitive_cube_add(size=0.03, location=(0, 0, 0.25))
    blade = bpy.context.active_object
    blade.scale = (0.4, 1.1, 7.3)
    blade.data.materials.append(mat_blade)

    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = grip
    bpy.ops.object.join()
    grip.name = "CombatKnife"
    export_glb(os.path.join(PROJECT_ROOT, "assets/models/Cuchi loco.glb"))

if __name__ == "__main__":
    make_pine_tree()
    make_dead_tree()
    make_rock_boulder()
    make_wooden_crate()
    make_wooden_barrel()
    make_street_lantern()
    make_pitchfork()
    make_throwing_axe()
    make_combat_knife()
    print("ALL PROPS AND WEAPONS GENERATED SUCCESSFULLY!")

