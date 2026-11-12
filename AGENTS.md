# AGENTS.md - Guía de Desarrollo para Agentes IA

> **Proyecto:** Proyect-move  
> **Motor:** Godot Engine 4.x (4.7+, Renderizador Forward+, Motor de físicas Jolt Physics 3D)  
> **Género:** Juego de Acción 3D en Tercera Persona (Third-Person Hack & Slash / Action RPG)  
> **Lenguaje Principal:** GDScript (Tipado estricto Godot 4)  
> **Pipeline 3D / Herramientas:** Blender 5.2 / Blender MCP Servers (Headless & Live)

---

## 1. Visión General y Filosofía de Arquitectura

`Proyect-move` es un juego de combate en 3D en tercera persona donde el jugador interactúa con enemigos (con máquinas de estado y Behavior Trees), recoge fragmentos monetarios, desbloquea áreas cerradas con llaves y atraviesa zonas delimitadas por niebla de combate.

### Principios Fundamentales:
1. **Composición sobre herencia rígida:** Aunque existe una jerarquía base (`CharacterBody3D` -> `Pawn` -> `Player` / `NPC` / `Enemy`), la lógica modular se delega a nodos componentes (`Movement`, `WeaponManager`, `Camera`, `BehaviorTree`).
2. **Autoloads para estado global:** `Globals` gestiona el inventario de fragmentos, niveles de mejora y referencias críticas (`Globals.player`).
3. **GDScript 2.0 Estricto:** Código limpio, fuertemente tipado, sin advertencias del linter y totalmente adaptado a Godot 4.
4. **Verificación Headless:** Validar cambios mecánicos y de escenas utilizando la CLI headless de Godot antes de dar por cerrada una tarea.

---

## 2. Reglas Estrictas de Godot 4.x (GDScript)

> [!IMPORTANT]
> **NUNCA utilices sintaxis de Godot 3.** Cualquier código que contenga APIs obsoletas romperá la compilación.

- **Nodos de física:**
  - Usar `CharacterBody3D`, `RigidBody3D`, `StaticBody3D` o `Area3D`.
  - **NUNCA** usar `KinematicBody3D`, `Spatial` o nombres de nodos de Godot 3.
- **Variables expuestas y preparación:**
  - Usar `@export`, `@export_group`, `@export_category` (NUNCA `export var`).
  - Usar `@onready var` (NUNCA `onready var`).
- **Corrutinas y Temporizadores:**
  - Usar `await` (NUNCA `yield`).
  - Ejemplo: `await get_tree().create_timer(1.0).timeout`
- **Movimiento de CharacterBody3D:**
  - La función `move_and_slide()` en Godot 4 **NO recibe parámetros**.
  - La velocidad se asigna directamente a la propiedad nativa `velocity` antes de la llamada:
    ```gdscript
    velocity = direction * speed
    move_and_slide()
    ```
- **Señales:**
  - Emisión: `mi_senal.emit(args)` (NUNCA `emit_signal("mi_senal", ...)`).
  - Conexión: `nodo.senal.connect(metodo_o_callable)` (NUNCA pasar el nombre del método como String).
- **Tipado estático:**
  - Tipar siempre parámetros y valores de retorno: `func aplicar_dano(cantidad: float) -> void:`
  - Declarar tipos en variables explícitas cuando sea posible: `var dir: Vector3 = Vector3.ZERO`

---

## 3. Configuración del Proyecto y Capas de Física (Collision Layers)

Definidas en `project.godot`:

| Capa (Layer) | Nombre | Descripción |
|---|---|---|
| **Layer 1** | `Environment` | Terreno, arquitectura estática, muros, obstáculos sólidos. |
| **Layer 2** | `Enemy` | Cuerpos físicos y hurtboxes de enemigos. |
| **Layer 3** | `Player` | Cuerpo físico y áreas de detección del jugador. |
| **Layer 4** | `Projectiles` | Hachas arrojadizas, proyectiles y cajas de impacto (hitboxes). |

*Física 3D:* Configurada con **Jolt Physics**, ofreciendo un rendimiento superior y colisiones más estables.

---

## 4. Mapeo de Acciones de Entrada (Input Map)

| Acción | Teclas / Botones por defecto | Propósito |
|---|---|---|
| `move_forward` / `move_back` | `W` / `S` | Movimiento frontal / trasero |
| `move_left` / `move_right` | `A` / `D` | Movimiento lateral |
| `jump` | `Espacio` | Salto |
| `run` | `Shift Izquierdo` | Carrera / Sprint |
| `dash` | `Alt Izquierdo` | Esquiva rápida con efecto ghost trail |
| `attack` | `Click Izquierdo` / `F` | Ataque primario / combo con arma activa |
| `aim` | `Click Derecho` | Modo apuntado de cámara |
| `weapon_1` | `1` | Seleccionar Espada / Cuchillo |
| `weapon_2` | `2` | Seleccionar Hacha |
| `interact` | `E` | Interacción con puertas, cofres, llaves |
| `pausa` | `Escape` | Menú de pausa |
| `debug` | `F1` | Acciones de depuración |

---

## 5. Estructura de Directorios

```text
proyect-move/
├── .agents/                    # Configuraciones y plugins MCP para agentes IA
│   └── plugins/
│       ├── blender/            # Servidor MCP Headless y Live para Blender 5.2
│       └── godot/              # Servidor MCP para reimportación y ejecución headless
├── assets/                     # Modelos (.glb, .blend), texturas, audio, efectos
│   ├── audio/                  # Efectos de sonido (.mp3, .wav)
│   ├── models/                 # Mallas 3D divididas en world, weapons, props
│   └── textures/               # Iconos, materiales y shaders
├── components/                 # Sistemas modulares y reutilizables
│   ├── behavior_tree/          # Framework de Behavior Tree (BT) para IA
│   ├── globals/                # Autoloads (Globals.gd, Settings.gd)
│   ├── pawns/                  # Clases base Pawn, Player y NPC
│   │   ├── player/             # Controladores: Movement, Camera, WeaponManager, HUD
│   │   └── npc/                # Base NPC
│   ├── ui/                     # Árbol de habilidades, menú de pausa, HUD
│   └── world/                  # Mecánicas de nivel (puertas, arenas, niebla, spawners)
├── enemies/                    # Escenas y scripts de enemigos específicos
│   ├── enemy.gd                # Clase base Enemy
│   ├── enemy_lumberjack.gd     # Jefe o enemigo Leñador
│   ├── enemy_axe.gd            # Enemigo con hacha
│   ├── enemy_pitchfork.gd      # Enemigo con horca
│   └── enemy_fist.gd           # Enemigo cuerpo a cuerpo básico
├── interactuables/             # Objetos con los que el jugador puede interactuar
│   ├── weapons/                # Hachas arrojadizas y armas recogibles
│   ├── church_key.gd           # Llaves de progreso
│   └── floor_trap.gd           # Trampas de suelo
├── levels/                     # Niveles y mapas de juego
│   └── map_1/                  # Nivel principal (toy_box.tscn, cajas destructibles, eventos)
├── scenes/                     # Escenas generales (menú principal)
├── scratch/                    # Scripts de prueba y validación rápida en desarrollo
├── godot4_rules.md             # Reglas básicas históricas
└── project.godot               # Archivo maestro de configuración de Godot Engine
```

---

## 6. Arquitectura de Código y Sistemas Clave

### A. Jerarquía Pawn (`Pawn` -> `Player` / `Enemy`)
- **`Pawn` (`components/pawns/pawn.gd`):**
  - Hereda de `CharacterBody3D`.
  - Gestiona `health`, `max_health`, `invulnerable`, gravedad automática si `floating == false`.
  - Métodos base: `take_damage(damage, attacker_pos, knockback_mult)` y `die()`.

- **`Player` (`components/pawns/player/player.gd`):**
  - Se registra automáticamente en `Globals.player = self` en `_ready()`.
  - Conecta con sus subnodos:
    - `$Movement`: Maneja velocidades, saltos, dashes e inputs direccionales relativos a la cámara.
    - `$Camera`: Brazo elástico (`SpringArm3D`) y rotación orbital en 3ra persona.
    - `$WeaponManager`: Controla armas instanciadas en sockets de huesos (`BoneAttachment3D`).
    - `$HUD`: Barra de vida, contador de fragmentos, pantalla de reintento (`DeathScreen`).
  - Regeneración pasiva de vida tras un periodo sin recibir daño.

- **`Enemy` (`enemies/enemy.gd`):**
  - Hereda de `NPC` (que a su vez hereda de `Pawn`).
  - Detección del jugador mediante grupo `"player"` o `Globals.player`.
  - Material hit-flash instanciado por clonación de materiales para no afectar otras instancias compartidas.
  - Generación de botín al morir (`amount_scarce` / `amount_generous` de `fragmento.tscn`).

### B. Sistema de Árbol de Comportamiento (Behavior Tree)
Ubicado en `components/behavior_tree/`:
- **`BehaviorNode`**: Clase base con retorno de estados (`SUCCESS`, `FAILURE`, `RUNNING`).
- **`Selector`**: Evalúa hijos secuencialmente; tiene éxito con el primero que retorne `SUCCESS`.
- **`Sequencer`**: Ejecuta hijos en orden; falla si alguno retorna `FAILURE`.
- **`Leaf` (Hojas de acción/condición):**
  - `leaf_follow_target.gd`: Persigue al objetivo usando navegación o vector hacia el jugador.
  - `leaf_axe_combo.gd`, `leaf_pitchfork_charge.gd`, `leaf_throw_axe.gd`: Ejecución de ataques específicos con timings y animaciones.

### C. Autoload: `Globals` (`components/globals/globals.gd`)
- Mantiene referencia a `player`.
- Señales del juego:
  - `fragments_updated(total, added_amount)`
  - `weapon_swapped(weapon_name)`
  - `axe_acquired`
  - `objective_updated(new_text)`
  - `upgrade_purchased(stat_name, new_level)`
- Flags de estado y progresión: `has_church_key`, `has_axe`, `can_run`, `can_dash`, `can_attack`.
- Sistema de mejoras (Upgrades): `knife_level`, `axe_level`, `player_level` pagados con fragmentos.

### D. Interactuables y Elementos de Nivel
- **`Caja` (`levels/map_1/caja.gd`):** Objeto destructible que al detectar un área de impacto instancia múltiples `RigidBody3D` (`fragmento.tscn`) con impulsos aleatorios.
- **`CombatArena` & `CircularFogWall`:** Zonas cerradas con niebla volumétrica y barreras que atrapan al jugador durante oleadas de enemigos.

---

## 7. Integración con Blender y Creación de Assets 3D

El proyecto cuenta con un entorno automatizado de Blender en `.agents/plugins/blender/`:
- **Servidor Headless (`headless_blender_server.py`):**
  - Permite generar primitivas optimizadas (`create_simple_model`), ejecutar scripts de Blender Python (`execute_blender_code`) y exportar directamente en formato `.glb`.
  - Inspeccionar polígonos, jerarquías de huesos y animaciones de archivos `.blend` con `inspect_blend_file`.
- **Servidor Live (`blender-live`):**
  - Para sesiones interactivas conectadas por WebSocket/puerto 9876 cuando Blender está abierto con la interfaz gráfica.
- **Directorio de destino de modelos:** Guardar mallas en `assets/models/objects/` o `assets/models/world/`.

---

## 8. Flujo de Trabajo para Tareas Habituales

### Crear un Nuevo Enemigo
1. Crear una nueva carpeta o archivo en `enemies/enemy_<nombre>.gd` heredando de `Enemy`.
2. Crear la escena `.tscn` con nodo raíz `CharacterBody3D` (asignando Collision Layer 2: `Enemy`).
3. Añadir el modelo 3D o `Node3D` con `AnimationPlayer` y el árbol de colisión (`CollisionShape3D`).
4. Configurar el árbol de comportamiento (`BehaviorTree`) añadiendo `Selector`, `Sequencer` y las `Leaf` correspondientes a sus ataques.
5. Asignar los puntos de vida (`health`), rangos de ataque y drop de fragmentos en el inspector (`@export`).

### Crear una Nueva Arma para el Jugador
1. Heredar de `Weapon` (`components/pawns/player/weapons/weapon.gd`).
2. Configurar animaciones de ataque, daño, multiplicador de knockback y rangos de hitbox (`Area3D` en Layer 4).
3. Añadir el arma al `WeaponManager` en la escena del jugador y registrar la tecla correspondiente en el Input Map si es necesario.

### Crear un Nuevo Interactuable
1. Usar un `Area3D` o `StaticBody3D` (Layer 1 para colisión física, o un `Area3D` para triggers).
2. Conectar la señal `body_entered` o responder al método de interacción `interact()` al pulsar `E`.
3. Notificar a `Globals` si modifica inventario o activa objetivos.

---

## 9. Pruebas y Validación en Godot Headless

El ejecutable oficial de Godot en este sistema se encuentra en:
`C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`

Para validar sintaxis de scripts o ejecutar pruebas automáticas sin abrir la interfaz gráfica:

```powershell
# Comprobar carga y funcionamiento de una escena (ej. 60 frames)
& "C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --path . --headless --scene res://levels/map_1/toy_box.tscn --quit-after 60

# Ejecutar un script de prueba de SceneTree (ej. validaciones de gameplay)
& "C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe" --path . --headless -s res://scratch/full_gameplay_test.gd
```

---

## 10. Buenas Prácticas y Consejos para el Agente

- **Preservar UIDs:** Al editar escenas `.tscn` o archivos de recursos `.tres`, no modifiques ni elimines los atributos `uid="uid://..."` a menos que sea estrictamente necesario.
- **Comprobación de referencias nulas:** Siempre verifica `is_instance_valid(nodo)` o `get_node_or_null()` antes de acceder a subcomponentes dinámicos que puedan haber sido destruidos (`queue_free()`).
- **Materiales en tiempo de ejecución:** Si vas a cambiar propiedades visuales de un mesh en tiempo de ejecución (como el hit-flash de daño), clona el material (`material.duplicate()`) para no teñir accidentalmente todas las demás instancias que comparten el mismo recurso en memoria.
- **Mantener documentación:** Si agregas nuevas acciones de input en `project.godot` o nuevos autoloads, actualiza este archivo `AGENTS.md`.
