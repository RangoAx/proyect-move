import bpy
import os

PROJECT_ROOT = r"c:\Godot Proyects\proyect-move"

def create_flat_mat(name, rgba, roughness=0.75, metallic=0.0, emission_rgba=None, emission_strength=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = rgba
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission_rgba and emission_strength > 0:
            if 'Emission Color' in bsdf.inputs:
                bsdf.inputs['Emission Color'].default_value = emission_rgba
                bsdf.inputs['Emission Strength'].default_value = emission_strength
            elif 'Emission' in bsdf.inputs:
                bsdf.inputs['Emission'].default_value = emission_rgba
    return mat

def get_dominant_category(poly, mesh_obj, vg_names):
    bone_weights = {}
    for v_idx in poly.vertices:
        v = mesh_obj.data.vertices[v_idx]
        for g in v.groups:
            bname = vg_names.get(g.group, "unknown")
            bone_weights[bname] = bone_weights.get(bname, 0.0) + g.weight
    dominant_bone = max(bone_weights.items(), key=lambda x: x[1])[0] if bone_weights else "none"

    if any(k in dominant_bone.lower() for k in ['head', 'neck']): return "HEAD"
    elif any(k in dominant_bone.lower() for k in ['spine', 'shoulder']): return "TORSO"
    elif any(k in dominant_bone.lower() for k in ['arm', 'forearm']): return "ARMS"
    elif any(k in dominant_bone.lower() for k in ['hand', 'thumb', 'index']): return "HANDS"
    elif any(k in dominant_bone.lower() for k in ['hips', 'upleg', 'thigh']): return "LEGS"
    elif any(k in dominant_bone.lower() for k in ['leg', 'calf']): return "CALVES"
    elif any(k in dominant_bone.lower() for k in ['foot', 'toe']): return "FEET"
    return "OTHER"

def style_player():
    path = os.path.join(PROJECT_ROOT, "assets/models/Animation personaje.glb")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=path)

    personaje = None
    for obj in bpy.data.objects:
        if obj.type == 'MESH' and 'personaje' in obj.name.lower():
            personaje = obj
            break

    if not personaje:
        print("Player mesh not found!")
        return

    # Materials for Player
    m_skin = create_flat_mat("Mat_PlayerSkin", (0.85, 0.65, 0.50, 1.0), roughness=0.6)
    m_hair = create_flat_mat("Mat_PlayerHair", (0.18, 0.12, 0.08, 1.0), roughness=0.9)
    m_coat = create_flat_mat("Mat_PlayerCoat", (0.18, 0.20, 0.24, 1.0), roughness=0.8)
    m_gloves = create_flat_mat("Mat_PlayerGloves", (0.12, 0.11, 0.10, 1.0), roughness=0.7)
    m_pants = create_flat_mat("Mat_PlayerPants", (0.24, 0.22, 0.18, 1.0), roughness=0.85)
    m_boots = create_flat_mat("Mat_PlayerBoots", (0.10, 0.09, 0.08, 1.0), roughness=0.6)

    personaje.data.materials.clear()
    mat_list = [m_skin, m_hair, m_coat, m_gloves, m_pants, m_boots]
    for m in mat_list:
        personaje.data.materials.append(m)

    vg_names = {vg.index: vg.name for vg in personaje.vertex_groups}

    for poly in personaje.data.polygons:
        cat = get_dominant_category(poly, personaje, vg_names)
        # Calculate polygon center
        center_z = sum(personaje.data.vertices[v_idx].co.z for v_idx in poly.vertices) / len(poly.vertices)
        center_y = sum(personaje.data.vertices[v_idx].co.y for v_idx in poly.vertices) / len(poly.vertices)

        if cat == "HEAD":
            # Hair is on top and back of head
            if center_z > 1.62 or center_y < -0.02:
                poly.material_index = 1 # Hair
            else:
                poly.material_index = 0 # Skin
        elif cat in ["TORSO", "ARMS"]:
            poly.material_index = 2 # Coat
        elif cat == "HANDS":
            poly.material_index = 3 # Gloves
        elif cat in ["LEGS", "CALVES"]:
            poly.material_index = 4 # Pants
        elif cat == "FEET":
            poly.material_index = 5 # Boots
        else:
            poly.material_index = 2

    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format='GLB',
        use_selection=False,
        export_apply=False
    )
    print("Styled and exported Player GLB successfully!")

def style_pitchfork_enemy():
    path = os.path.join(PROJECT_ROOT, "assets/models/pawns/enemy/enemy pitchfork/Enemigo trinche.glb")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=path)

    personaje = None
    for obj in bpy.data.objects:
        if obj.type == 'MESH' and 'personaje' in obj.name.lower():
            personaje = obj
            break

    if not personaje:
        print("Pitchfork enemy mesh not found!")
        return

    m_skin = create_flat_mat("Mat_GhoulSkin", (0.68, 0.70, 0.60, 1.0), roughness=0.7)
    m_eyes = create_flat_mat("Mat_GhoulEyes", (1.0, 0.85, 0.25, 1.0), roughness=0.2, emission_rgba=(1.0, 0.85, 0.25, 1.0), emission_strength=4.0)
    m_poncho = create_flat_mat("Mat_GhoulPoncho", (0.26, 0.28, 0.20, 1.0), roughness=0.9)
    m_hands = create_flat_mat("Mat_GhoulHands", (0.64, 0.66, 0.56, 1.0), roughness=0.7)
    m_pants = create_flat_mat("Mat_GhoulPants", (0.20, 0.16, 0.12, 1.0), roughness=0.9)
    m_wraps = create_flat_mat("Mat_GhoulWraps", (0.14, 0.12, 0.10, 1.0), roughness=0.85)

    personaje.data.materials.clear()
    mat_list = [m_skin, m_eyes, m_poncho, m_hands, m_pants, m_wraps]
    for m in mat_list:
        personaje.data.materials.append(m)

    vg_names = {vg.index: vg.name for vg in personaje.vertex_groups}

    for poly in personaje.data.polygons:
        cat = get_dominant_category(poly, personaje, vg_names)
        center_z = sum(personaje.data.vertices[v_idx].co.z for v_idx in poly.vertices) / len(poly.vertices)
        center_y = sum(personaje.data.vertices[v_idx].co.y for v_idx in poly.vertices) / len(poly.vertices)

        if cat == "HEAD":
            # Eye level is around Z: 1.52 to 1.58 on the front face (Y > 0.05)
            if 1.50 <= center_z <= 1.60 and center_y > 0.06:
                poly.material_index = 1 # Eyes (glowing)
            else:
                poly.material_index = 0 # Pale skin
        elif cat in ["TORSO", "ARMS"]:
            poly.material_index = 2 # Decayed poncho
        elif cat == "HANDS":
            poly.material_index = 3 # Hands
        elif cat in ["LEGS", "CALVES"]:
            poly.material_index = 4 # Tattered pants
        elif cat == "FEET":
            poly.material_index = 5 # Wraps
        else:
            poly.material_index = 2

    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format='GLB',
        use_selection=False,
        export_apply=False
    )
    print("Styled and exported Pitchfork Enemy GLB successfully!")

def style_axe_enemy():
    path = os.path.join(PROJECT_ROOT, "assets/models/pawns/enemy/enemy axe/Enemigo hacha.glb")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=path)

    personaje = None
    sombrero = None
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            if 'personaje' in obj.name.lower():
                personaje = obj
            elif 'sombrero' in obj.name.lower():
                sombrero = obj

    if not personaje:
        print("Axe enemy mesh not found!")
        return

    m_skin = create_flat_mat("Mat_ButcherSkin", (0.55, 0.50, 0.45, 1.0), roughness=0.7)
    m_coat = create_flat_mat("Mat_ButcherCoat", (0.16, 0.16, 0.18, 1.0), roughness=0.85)
    m_apron = create_flat_mat("Mat_ButcherApron", (0.24, 0.12, 0.10, 1.0), roughness=0.8)
    m_hands = create_flat_mat("Mat_ButcherHands", (0.48, 0.44, 0.40, 1.0), roughness=0.7)
    m_boots = create_flat_mat("Mat_ButcherBoots", (0.10, 0.09, 0.08, 1.0), roughness=0.6)
    m_hat = create_flat_mat("Mat_ButcherHat", (0.12, 0.12, 0.14, 1.0), roughness=0.9)

    personaje.data.materials.clear()
    mat_list = [m_skin, m_coat, m_apron, m_hands, m_boots]
    for m in mat_list:
        personaje.data.materials.append(m)

    if sombrero:
        sombrero.data.materials.clear()
        sombrero.data.materials.append(m_hat)

    vg_names = {vg.index: vg.name for vg in personaje.vertex_groups}

    for poly in personaje.data.polygons:
        cat = get_dominant_category(poly, personaje, vg_names)
        if cat == "HEAD":
            poly.material_index = 0 # Skin
        elif cat in ["TORSO", "ARMS"]:
            poly.material_index = 1 # Coat
        elif cat in ["LEGS", "CALVES"]:
            poly.material_index = 2 # Heavy apron
        elif cat == "HANDS":
            poly.material_index = 3 # Rough hands
        elif cat == "FEET":
            poly.material_index = 4 # Heavy boots
        else:
            poly.material_index = 1

    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format='GLB',
        use_selection=False,
        export_apply=False
    )
    print("Styled and exported Axe Enemy GLB successfully!")

if __name__ == "__main__":
    style_player()
    style_pitchfork_enemy()
    style_axe_enemy()
    print("ALL CHARACTERS STYLED WITH FLAT COLORS!")

