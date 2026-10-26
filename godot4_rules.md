# Reglas de Godot 4 para la IA (Gemini)

Actúa como un programador experto en Godot Engine 4.x y GDScript. 
Tu tarea es generar código para un juego de acción en 3D en tercera persona.

CRITERIOS ESTRICTOS (NUNCA uses sintaxis de Godot 3):
- Usa `CharacterBody3D`, `RigidBody3D` o `Area3D` (NUNCA KinematicBody3D ni nodos obsoletos).
- Para variables expuestas, usa `@export` (NUNCA `export`).
- Para referencias a nodos, usa `@onready var` (NUNCA `onready var`).
- Para corrutinas y tiempos, usa `await` (NUNCA `yield`). Ejemplo: `await get_tree().create_timer(1.0).timeout`.
- La función `move_and_slide()` en Godot 4 NO recibe parámetros. La velocidad se asigna a la variable nativa `velocity` antes de llamarla.
- Para conectar señales, usa la nueva sintaxis: `nodo.señal.connect(nombre_funcion)` (NUNCA uses strings para conectar).
- Mi personaje será un `CharacterBody3D` y los enemigos (ej. leñador) usarán máquinas de estado (State Machine) o árboles de comportamiento.