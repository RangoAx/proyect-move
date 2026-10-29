import bpy
import os

PROJECT_ROOT = r"c:\Godot Proyects\proyect-move"
glb_path = os.path.join(PROJECT_ROOT, "assets/models/Animation personaje.glb")

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=glb_path)

personaje = bpy.data.objects.get("Personaje")
vg_names = {vg.index: vg.name for vg in personaje.vertex_groups}

# Classify polygons by dominant bone
counts = {}
for poly in personaje.data.polygons:
    # Find average vertex group weights for this polygon
    bone_weights = {}
    for v_idx in poly.vertices:
        v = personaje.data.vertices[v_idx]
        for g in v.groups:
            name = vg_names.get(g.group, "unknown")
            bone_weights[name] = bone_weights.get(name, 0.0) + g.weight
    dominant_bone = max(bone_weights.items(), key=lambda x: x[1])[0] if bone_weights else "none"
    
    # Categorize into body part
    if any(k in dominant_bone.lower() for k in ['head', 'neck']):
        cat = "HEAD"
    elif any(k in dominant_bone.lower() for k in ['spine', 'shoulder']):
        cat = "TORSO"
    elif any(k in dominant_bone.lower() for k in ['arm', 'forearm']):
        cat = "ARMS"
    elif any(k in dominant_bone.lower() for k in ['hand', 'thumb', 'index']):
        cat = "HANDS"
    elif any(k in dominant_bone.lower() for k in ['hips', 'upleg', 'thigh']):
        cat = "LEGS"
    elif any(k in dominant_bone.lower() for k in ['leg', 'calf']):
        cat = "CALVES"
    elif any(k in dominant_bone.lower() for k in ['foot', 'toe']):
        cat = "FEET"
    else:
        cat = "OTHER"
    counts[cat] = counts.get(cat, 0) + 1

print("Polygon categorization counts for Personaje:")
for cat, count in sorted(counts.items()):
    print(f"  {cat:10}: {count} polygons")

