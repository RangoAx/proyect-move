import os
import subprocess
import tempfile
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("godot")

GODOT_EXECUTABLE = os.environ.get(
    "GODOT_EXECUTABLE",
    r"C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe"
)
PROJECT_ROOT = os.environ.get(
    "PROJECT_ROOT",
    r"c:\Godot Proyects\proyect-move"
)

@mcp.tool()
def reimport_assets() -> str:
    """Runs Godot editor headlessly to scan and reimport all new 3D models and audio assets."""
    cmd = [
        GODOT_EXECUTABLE,
        "--path", PROJECT_ROOT,
        "--headless",
        "--editor",
        "--quit"
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return f"Reimport completed.\nStdout:\n{proc.stdout}\nStderr:\n{proc.stderr}"
    except Exception as e:
        return f"Error reimporting: {str(e)}"

@mcp.tool()
def check_scene(scene_path: str = "res://levels/map_1/toy_box.tscn", frames: int = 30) -> str:
    """Tests loading a scene in Godot headlessly to detect any errors or missing resources."""
    cmd = [
        GODOT_EXECUTABLE,
        "--path", PROJECT_ROOT,
        "--headless",
        "--scene", scene_path,
        f"--quit-after", str(frames)
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
        out = proc.stdout + "\n" + proc.stderr
        status = "PASSED" if proc.returncode == 0 and "ERROR" not in out else "WARNINGS/ERRORS DETECTED"
        return f"Status: {status} (code {proc.returncode})\nOutput:\n{out}"
    except Exception as e:
        return f"Execution error: {str(e)}"

@mcp.tool()
def execute_gdscript(code: str) -> str:
    """Executes a standalone GDScript tool code in Godot headless."""
    script_content = f"""@tool
extends SceneTree

func _init():
{code}
\tquit()
"""
    with tempfile.NamedTemporaryFile("w", suffix=".gd", delete=False, encoding="utf-8") as tf:
        tf.write(script_content)
        temp_path = tf.name

    try:
        cmd = [
            GODOT_EXECUTABLE,
            "--path", PROJECT_ROOT,
            "--headless",
            "--script", temp_path
        ]
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
        return proc.stdout + "\n" + proc.stderr
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

if __name__ == "__main__":
    mcp.run()

