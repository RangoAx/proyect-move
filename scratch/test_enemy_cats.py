import bpy
import os

PROJECT_ROOT = r"c:\Godot Proyects\proyect-move"

for name in ["pawns/enemy/enemy pitchfork/Enemigo trinche.glb", "pawns/enemy/enemy axe/Enemigo hacha.glb"]:
    glb_path = os.path.join(PROJECT_ROOT, f"assets/models/{name}")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=glb_path)
    
    personaje = None
    for obj in bpy.data.objects:
        if obj.type == 'MESH' and 'personaje' in obj.name.lower():
            personaje = obj
            break
            
    if not personaje:
        print(f"Mesh not found in {name}")
        continue
        
    vg_names = {vg.index: vg.name for vg in personaje.vertex_groups}
    counts = {}
    for poly in personaje.data.polygons:
        bone_weights = {}
        for v_idx in poly.vertices:
            v = personaje.data.vertices[v_idx]
            for g in v.groups:
                bname = vg_names.get(g.group, "unknown")
                bone_weights[bname] = bone_weights.get(bname, 0.0) + g.weight
        dominant_bone = max(bone_weights.items(), key=lambda x: x[1])[0] if bone_weights else "none"
        
        if any(k in dominant_bone.lower() for k in ['head', 'neck']): cat = "HEAD"
        elif any(k in dominant_bone.lower() for k in ['spine', 'shoulder']): cat = "TORSO"
        elif any(k in dominant_bone.lower() for k in ['arm', 'forearm']): cat = "ARMS"
        elif any(k in dominant_bone.lower() for k in ['hand', 'thumb', 'index']): cat = "HANDS"
        elif any(k in dominant_bone.lower() for k in ['hips', 'upleg', 'thigh']): cat = "LEGS"
        elif any(k in dominant_bone.lower() for k in ['leg', 'calf']): cat = "CALVES"
        elif any(k in dominant_bone.lower() for k in ['foot', 'toe']): cat = "FEET"
        else: cat = "OTHER"
        counts[cat] = counts.get(cat, 0) + 1
        
    print(f"\n{name} -> {personaje.name} ({len(personaje.data.polygons)} faces):")
    for cat, count in sorted(counts.items()):
        print(f"  {cat:10}: {count} polygons")

