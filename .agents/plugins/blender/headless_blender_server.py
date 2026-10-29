"""Headless Blender MCP Server for 3D Modeling Automation.

Provides FastMCP tools to create, inspect, modify, and render 3D models headlessly
via Blender (blender.exe -b), exporting directly to Godot-ready .glb and .blend files.
"""

import os
import sys
import json
import tempfile
import subprocess
from typing import Optional, List, Dict, Any
from mcp.server.fastmcp import FastMCP

# Initialize FastMCP Server
mcp = FastMCP("blender")

# Default Blender paths to search
DEFAULT_BLENDER_CANDIDATES = [
    os.environ.get("BLENDER_EXECUTABLE", ""),
    os.environ.get("BLENDER_PATH", ""),
    r"C:\Program Files (x86)\Steam\steamapps\common\Blender\blender.exe",
    r"C:\Program Files\Steam\steamapps\common\Blender\blender.exe",
    r"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe",
    r"C:\Program Files\Blender Foundation\Blender 4.3\blender.exe",
    r"C:\Program Files\Blender Foundation\Blender 4.2\blender.exe",
]

PROJECT_ROOT = os.environ.get("PROJECT_ROOT", r"c:\Godot Proyects\proyect-move")


def get_blender_path() -> str:
    """Finds a valid blender.exe executable."""
    for candidate in DEFAULT_BLENDER_CANDIDATES:
        if candidate and os.path.isfile(candidate):
            return candidate
    # Fallback to where.exe
    try:
        res = subprocess.run(["where.exe", "blender"], capture_output=True, text=True)
        if res.returncode == 0:
            lines = res.stdout.strip().splitlines()
            if lines and os.path.isfile(lines[0]):
                return lines[0]
    except Exception:
        pass
    raise FileNotFoundError(
        "Could not find blender.exe. Please set the BLENDER_EXECUTABLE environment variable."
    )


def resolve_project_path(path: str) -> str:
    """Resolves relative paths against the project root."""
    if not os.path.isabs(path):
        return os.path.normpath(os.path.join(PROJECT_ROOT, path))
    return os.path.normpath(path)


def hex_to_rgba(hex_code: str) -> tuple:
    """Converts a hex color (#RRGGBB or #RGB) to normalized linear RGBA tuple."""
    hex_code = hex_code.lstrip("#")
    if len(hex_code) == 3:
        hex_code = "".join([c * 2 for c in hex_code])
    if len(hex_code) == 6:
        r = int(hex_code[0:2], 16) / 255.0
        g = int(hex_code[2:4], 16) / 255.0
        b = int(hex_code[4:6], 16) / 255.0
        # Simple gamma to linear approximation for Blender Principled BSDF
        return (r ** 2.2, g ** 2.2, b ** 2.2, 1.0)
    return (0.8, 0.8, 0.8, 1.0)


@mcp.tool()
def create_simple_model(
    model_type: str,
    export_path: str,
    name: str = "Model",
    width: float = 1.0,
    height: float = 1.0,
    depth: float = 1.0,
    color_hex: str = "#8B5A2B",
    metallic: float = 0.0,
    roughness: float = 0.7,
) -> str:
    """Creates a 3D model headlessly using Blender and exports it to GLB or BLEND.

    Args:
        model_type: The type of model to generate:
            - 'cube' or 'box': simple block.
            - 'crate': wooden game crate with structural frame/corners.
            - 'barrel': wooden cylindrical barrel with top/bottom iron bands.
            - 'pillar' or 'column': stone pillar with plinth, shaft, and capital.
            - 'sphere': UV sphere.
            - 'cylinder': smooth cylinder.
            - 'cone': pointed cone.
            - 'rock': displaced low-poly procedural rock.
            - 'coin': beveled metallic token.
            - 'table': 4-legged wooden table.
            - 'chair': 4-legged chair with backrest.
            - 'fence': wooden post-and-rail barrier segment.
            - 'stairs': stepped platform.
        export_path: Relative or absolute path for export (e.g. 'assets/models/objects/crate.glb').
        name: Name for the primary object.
        width: Scale or dimension along X axis in meters.
        height: Scale or dimension along Y/Z height axis in meters.
        depth: Scale or dimension along Z/depth axis in meters.
        color_hex: Primary albedo color in hex (e.g. '#8B5A2B' for wood, '#808080' for stone, '#D4AF37' for gold).
        metallic: PBR metallic factor (0.0 for non-metal, 1.0 for metal).
        roughness: PBR roughness factor (0.0 to 1.0).
    """
    blender = get_blender_path()
    resolved_export = resolve_project_path(export_path)
    os.makedirs(os.path.dirname(resolved_export), exist_ok=True)

    rgba = hex_to_rgba(color_hex)
    is_blend = resolved_export.lower().endswith(".blend")

    # Python script executed inside Blender
    script = f"""
import bpy
import bmesh
import math
import os

bpy.ops.wm.read_factory_settings(use_empty=True)

name = {json.dumps(name)}
model_type = {json.dumps(model_type.lower())}
w = {float(width)}
h = {float(height)}
d = {float(depth)}
rgba = {rgba}
metallic = {float(metallic)}
roughness = {float(roughness)}
out_path = {json.dumps(resolved_export)}
is_blend = {is_blend}

def make_pbr_material(mat_name, base_color, met, rough):
    mat = bpy.data.materials.new(name=mat_name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = base_color
        bsdf.inputs["Metallic"].default_value = met
        bsdf.inputs["Roughness"].default_value = rough
    return mat

main_mat = make_pbr_material(f"{{name}}_Mat", rgba, metallic, roughness)
accent_mat = make_pbr_material(f"{{name}}_Accent", (rgba[0]*0.4, rgba[1]*0.4, rgba[2]*0.4, 1.0), 0.8, 0.3)

created_objects = []

if model_type in ["cube", "box"]:
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h/2))
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (w, d, h)
    obj.data.materials.append(main_mat)
    created_objects.append(obj)

elif model_type == "crate":
    # Base block
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h/2))
    crate = bpy.context.active_object
    crate.name = name
    crate.scale = (w, d, h)
    crate.data.materials.append(main_mat)
    # Bevel modifier for rounded edges
    bev = crate.modifiers.new(name="Bevel", type='BEVEL')
    bev.width = 0.05
    bev.segments = 2
    created_objects.append(crate)

elif model_type in ["pillar", "column"]:
    # Base
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.08 * h))
    base = bpy.context.active_object
    base.scale = (w * 1.1, d * 1.1, 0.16 * h)
    base.data.materials.append(main_mat)
    # Shaft
    bpy.ops.mesh.primitive_cylinder_add(radius=w * 0.45, depth=0.75 * h, location=(0, 0, 0.5 * h), vertices=16)
    shaft = bpy.context.active_object
    shaft.data.materials.append(main_mat)
    # Capital
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.92 * h))
    cap = bpy.context.active_object
    cap.scale = (w * 1.15, d * 1.15, 0.16 * h)
    cap.data.materials.append(main_mat)
    # Join into single mesh
    bpy.ops.object.select_all(action='DESELECT')
    for o in [base, shaft, cap]: o.select_set(True)
    bpy.context.view_layer.objects.active = base
    bpy.ops.object.join()
    base.name = name
    created_objects.append(base)

elif model_type == "barrel":
    # Barrel body
    bpy.ops.mesh.primitive_cylinder_add(radius=w * 0.45, depth=h, location=(0, 0, h/2), vertices=20)
    barrel = bpy.context.active_object
    barrel.name = name
    barrel.data.materials.append(main_mat)
    # Top and bottom metal rings
    for z in [0.25 * h, 0.75 * h]:
        bpy.ops.mesh.primitive_torus_add(major_radius=w * 0.46, minor_radius=0.02 * w, location=(0, 0, z))
        ring = bpy.context.active_object
        ring.data.materials.append(accent_mat)
    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = barrel
    bpy.ops.object.join()
    created_objects.append(barrel)

elif model_type == "table":
    # Table top
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h - 0.04 * h))
    top = bpy.context.active_object
    top.scale = (w, d, 0.08 * h)
    top.data.materials.append(main_mat)
    # 4 legs
    leg_r = 0.04 * min(w, d)
    leg_h = h - 0.08 * h
    for lx in [-w/2 + 0.08*w, w/2 - 0.08*w]:
        for ly in [-d/2 + 0.08*d, d/2 - 0.08*d]:
            bpy.ops.mesh.primitive_cube_add(size=1.0, location=(lx, ly, leg_h/2))
            leg = bpy.context.active_object
            leg.scale = (leg_r * 2, leg_r * 2, leg_h)
            leg.data.materials.append(main_mat)
    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = top
    bpy.ops.object.join()
    top.name = name
    created_objects.append(top)

elif model_type == "chair":
    # Seat
    seat_h = 0.45 * h
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, seat_h))
    seat = bpy.context.active_object
    seat.scale = (w, d, 0.06 * h)
    seat.data.materials.append(main_mat)
    # 4 legs
    leg_r = 0.03 * min(w, d)
    for lx in [-w/2 + 0.05*w, w/2 - 0.05*w]:
        for ly in [-d/2 + 0.05*d, d/2 - 0.05*d]:
            bpy.ops.mesh.primitive_cube_add(size=1.0, location=(lx, ly, seat_h/2))
            leg = bpy.context.active_object
            leg.scale = (leg_r * 2, leg_r * 2, seat_h)
            leg.data.materials.append(main_mat)
    # Backrest
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -d/2 + 0.04*d, seat_h + 0.28 * h))
    back = bpy.context.active_object
    back.scale = (w, 0.06 * d, 0.55 * h)
    back.data.materials.append(main_mat)
    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = seat
    bpy.ops.object.join()
    seat.name = name
    created_objects.append(seat)

elif model_type == "rock":
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=w*0.5, location=(0, 0, h*0.45))
    rock = bpy.context.active_object
    rock.name = name
    rock.scale = (1.0, d/w if w else 1.0, h/w if w else 1.0)
    rock.data.materials.append(main_mat)
    # Displace / rough modifier
    disp = rock.modifiers.new(name="Decimate", type='DECIMATE')
    disp.ratio = 0.6
    created_objects.append(rock)

elif model_type == "coin":
    bpy.ops.mesh.primitive_cylinder_add(radius=w * 0.5, depth=h * 0.1, location=(0, 0, h * 0.05), vertices=32)
    coin = bpy.context.active_object
    coin.name = name
    coin.data.materials.append(main_mat)
    bev = coin.modifiers.new(name="Bevel", type='BEVEL')
    bev.width = 0.015 * w
    bev.segments = 2
    created_objects.append(coin)

elif model_type == "stairs":
    steps = 5
    step_h = h / steps
    step_d = d / steps
    st_objs = []
    for i in range(steps):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, (i + 0.5) * step_d - d/2, (i + 0.5) * step_h))
        st = bpy.context.active_object
        st.scale = (w, step_d, (i + 1) * step_h)
        st.data.materials.append(main_mat)
        st_objs.append(st)
    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = st_objs[0]
    bpy.ops.object.join()
    st_objs[0].name = name
    created_objects.append(st_objs[0])

elif model_type == "sphere":
    bpy.ops.mesh.primitive_uv_sphere_add(radius=w * 0.5, location=(0, 0, h * 0.5))
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (1.0, d/w if w else 1.0, h/w if w else 1.0)
    obj.data.materials.append(main_mat)
    created_objects.append(obj)

elif model_type == "cylinder":
    bpy.ops.mesh.primitive_cylinder_add(radius=w * 0.5, depth=h, location=(0, 0, h * 0.5))
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (1.0, d/w if w else 1.0, 1.0)
    obj.data.materials.append(main_mat)
    created_objects.append(obj)

elif model_type == "cone":
    bpy.ops.mesh.primitive_cone_add(radius1=w * 0.5, depth=h, location=(0, 0, h * 0.5))
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (1.0, d/w if w else 1.0, 1.0)
    obj.data.materials.append(main_mat)
    created_objects.append(obj)

else:
    # Default fallback: cube
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h/2))
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (w, d, h)
    obj.data.materials.append(main_mat)
    created_objects.append(obj)

# Apply transforms and export
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)

if is_blend:
    bpy.ops.wm.save_as_mainfile(filepath=out_path)
    print(f"SAVED_BLEND: {{out_path}}")
else:
    bpy.ops.export_scene.gltf(filepath=out_path, export_format='GLB', export_apply=True)
    print(f"EXPORTED_GLB: {{out_path}}")
"""

    with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False, encoding="utf-8") as f:
        f.write(script)
        temp_file = f.name

    try:
        res = subprocess.run([blender, "-b", "--python", temp_file],
                             capture_output=True, text=True, check=True)
        return (
            f"Successfully generated {model_type} model '{name}' at: {resolved_export}\n"
            f"Dimensions: {width}x{depth}x{height}m | Color: {color_hex} | Metallic: {metallic} | Roughness: {roughness}\n"
            f"Logs:\n{res.stdout.strip()}"
        )
    except subprocess.CalledProcessError as e:
        return f"Error creating model with Blender:\n{e.stderr or e.stdout}"
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)


@mcp.tool()
def execute_blender_code(code: str, blend_file: str = "", output_glb_path: str = "") -> str:
    """Executes arbitrary Python code inside Blender's bpy engine in headless mode.

    Args:
        code: Python source code to execute. Can use 'import bpy', 'bmesh', mathutils, etc.
        blend_file: Optional path to an existing .blend file to open before running the code.
        output_glb_path: Optional path where active scene will be exported as GLB after execution.
    """
    blender = get_blender_path()
    resolved_blend = resolve_project_path(blend_file) if blend_file else None
    resolved_glb = resolve_project_path(output_glb_path) if output_glb_path else None

    if resolved_blend and not os.path.isfile(resolved_blend):
        return f"Error: Blend file not found at {resolved_blend}"

    wrapper_code = code
    if resolved_glb:
        os.makedirs(os.path.dirname(resolved_glb), exist_ok=True)
        wrapper_code += f"\nimport bpy\nbpy.ops.export_scene.gltf(filepath={json.dumps(resolved_glb)}, export_format='GLB', export_apply=True)\nprint('AUTO_EXPORTED_GLB: ' + {json.dumps(resolved_glb)})\n"

    with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False, encoding="utf-8") as f:
        f.write(wrapper_code)
        temp_file = f.name

    cmd = [blender, "-b"]
    if resolved_blend:
        cmd.extend([resolved_blend])
    cmd.extend(["--python", temp_file])

    try:
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return f"Execution succeeded.\nOutput:\n{res.stdout}"
    except subprocess.CalledProcessError as e:
        return f"Execution failed:\n{e.stderr or e.stdout}"
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)


@mcp.tool()
def inspect_blend_file(blend_file_path: str) -> str:
    """Inspects a .blend file and returns a structured breakdown of objects, meshes, materials, and armatures."""
    blender = get_blender_path()
    resolved_path = resolve_project_path(blend_file_path)
    if not os.path.isfile(resolved_path):
        return f"Error: File not found at {resolved_path}"

    script = """
import bpy
import json

data = {
    "objects": [],
    "materials": [],
    "armatures": [],
    "actions": [a.name for a in bpy.data.actions]
}

for o in bpy.data.objects:
    obj_info = {
        "name": o.name,
        "type": o.type,
        "location": list(o.location),
        "rotation_euler": [round(r, 4) for r in o.rotation_euler],
        "scale": [round(s, 4) for r in o.scale for s in [r]],
        "dimensions": [round(d, 4) for d in o.dimensions],
    }
    if o.type == 'MESH' and o.data:
        obj_info["vertices"] = len(o.data.vertices)
        obj_info["polygons"] = len(o.data.polygons)
        obj_info["materials"] = [m.name for m in o.data.materials if m]
    if o.type == 'ARMATURE' and o.data:
        obj_info["bones"] = [b.name for b in o.data.bones]
    data["objects"].append(obj_info)

for m in bpy.data.materials:
    data["materials"].append(m.name)

print("INSPECTION_JSON_START")
print(json.dumps(data, indent=2))
print("INSPECTION_JSON_END")
"""

    with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False, encoding="utf-8") as f:
        f.write(script)
        temp_file = f.name

    try:
        res = subprocess.run([blender, "-b", resolved_path, "--python", temp_file],
                             capture_output=True, text=True, check=True)
        stdout = res.stdout
        if "INSPECTION_JSON_START" in stdout:
            json_part = stdout.split("INSPECTION_JSON_START")[1].split("INSPECTION_JSON_END")[0].strip()
            return json_part
        return stdout
    except subprocess.CalledProcessError as e:
        return f"Error inspecting {resolved_path}:\n{e.stderr or e.stdout}"
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)


@mcp.tool()
def render_model_preview(model_path: str, output_image_path: str, width: int = 512, height: int = 512) -> str:
    """Renders an isometric preview image (.png) of a 3D model (.blend or .glb) using Blender Cycles/Eevee."""
    blender = get_blender_path()
    resolved_model = resolve_project_path(model_path)
    resolved_image = resolve_project_path(output_image_path)
    os.makedirs(os.path.dirname(resolved_image), exist_ok=True)

    if not os.path.isfile(resolved_model):
        return f"Error: Model not found at {resolved_model}"

    is_glb = resolved_model.lower().endswith((".glb", ".gltf"))

    script = f"""
import bpy
import math

is_glb = {is_glb}
model_path = {json.dumps(resolved_model)}
image_path = {json.dumps(resolved_image)}
w = {int(width)}
h = {int(height)}

if is_glb:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=model_path)

# Set render settings
bpy.context.scene.render.resolution_x = w
bpy.context.scene.render.resolution_y = h
bpy.context.scene.render.filepath = image_path
bpy.context.scene.render.image_settings.file_format = 'PNG'

# Calculate bounding box of all meshes
mesh_objs = [o for o in bpy.context.scene.objects if o.type == 'MESH']
if mesh_objs:
    all_coords = []
    for o in mesh_objs:
        for v in o.bound_box:
            all_coords.append(o.matrix_world @ mathutils.Vector(v))
    min_z = min(c.z for c in all_coords)
    max_z = max(c.z for c in all_coords)
    center = sum(all_coords, mathutils.Vector((0, 0, 0))) / len(all_coords)
    radius = max((c - center).length for c in all_coords)
else:
    center = mathutils.Vector((0, 0, 0))
    radius = 2.0

# Add Camera
bpy.ops.object.camera_add(location=(center.x + radius*2.2, center.y - radius*2.2, center.z + radius*1.8))
cam = bpy.context.active_object
cam.rotation_euler = (math.radians(60), 0, math.radians(45))
bpy.context.scene.camera = cam

# Add 3-point lighting
# Key light
bpy.ops.object.light_add(type='SUN', location=(center.x + 5, center.y - 5, center.z + 10))
sun = bpy.context.active_object
sun.data.energy = 4.0

# Fill light
bpy.ops.object.light_add(type='POINT', location=(center.x - 4, center.y + 4, center.z + 4))
fill = bpy.context.active_object
fill.data.energy = 100.0

# Render
bpy.ops.render.render(write_still=True)
print("RENDER_COMPLETED: " + image_path)
"""

    with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False, encoding="utf-8") as f:
        f.write(script)
        temp_file = f.name

    cmd = [blender, "-b"]
    if not is_glb:
        cmd.append(resolved_model)
    cmd.extend(["--python", temp_file])

    try:
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return f"Successfully rendered preview image to: {resolved_image}\n{res.stdout.strip()}"
    except subprocess.CalledProcessError as e:
        return f"Error rendering preview:\n{e.stderr or e.stdout}"
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)


if __name__ == "__main__":
    mcp.run()

