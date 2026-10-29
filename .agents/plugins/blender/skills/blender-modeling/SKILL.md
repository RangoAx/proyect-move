---
name: blender-modeling
description: Guide and workflows for creating, modifying, and inspecting 3D models and assets using Blender MCP servers in this Godot project.
---

# Blender 3D Modeling Guide

This project includes Blender MCP servers to automate 3D modeling, asset creation, and inspection directly for Godot 4.

## Configured MCP Servers

1. **`blender` (Headless Automation)**:
   - Runs in the background via `blender.exe -b` using FastMCP.
   - Does **not** require Blender to be open.
   - Ideal for generating game props (crates, barrels, pillars, tables, chairs, coins, rocks, obstacles), executing custom Python scripts, inspecting `.blend` files, and rendering preview thumbnails.
   - Automatically exports `.glb` models ready for Godot's asset pipeline (`assets/models/objects/`).

2. **`blender-live` (`mcp-for-blender`)**:
   - Connects to an active interactive Blender session on port 9876.
   - The addon `blender_mcp` is pre-installed in Blender 5.2 (`%APPDATA%\Blender Foundation\Blender\5.2\scripts\addons`).
   - Use this when working inside the Blender GUI for real-time viewport feedback, shaders, or manual adjustments.

## Available Headless Tools

- `create_simple_model(model_type, export_path, name, width, height, depth, color_hex, metallic, roughness)`:
  Creates clean, game-ready primitives and props (`cube`, `crate`, `barrel`, `pillar`, `table`, `chair`, `coin`, `rock`, `stairs`, `cylinder`, `cone`, `sphere`) and exports to `.glb` or `.blend`.
- `execute_blender_code(code, blend_file, output_glb_path)`:
  Runs arbitrary `bpy` Python code headlessly and can automatically export the resulting scene to `.glb`.
- `inspect_blend_file(blend_file_path)`:
  Inspects existing `.blend` models (mesh poly count, materials, bones, animations) without opening the GUI.
- `render_model_preview(model_path, output_image_path, width, height)`:
  Sets up automatic camera/lights and renders an isometric PNG preview image.

## Godot Integration Workflow

1. Generate the model to `assets/models/objects/<name>.glb`.
2. Godot automatically imports the `.glb` file and generates `.import` metadata.
3. Instantiate the `.glb` into a `.tscn` scene (e.g. `RigidBody3D`, `StaticBody3D`, or weapon prop) with collision shapes.

