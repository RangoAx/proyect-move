extends Leaf
class_name LeafThrowAxe

@export var throw_range: float = 8.0
@export var vulnerability_time: float = 1.5
@export var min_throw_range: float = 4.0
@export var max_throw_range: float = 15.0 

var _internal_state = "idle"
var _timer: float = 0.0

func _ready():
	if owner is NPC:
		owner.took_damage.connect(_on_took_damage)

func _on_took_damage():
	_internal_state = "idle"
	if owner and "state" in owner:
		owner.state = "idle"

func step() -> Result:
	
	var npc: AxeEnemy = owner
	var target = Globals.player
	if not target: return Result.FAILURE

	if npc.state != "idle" and npc.state != "throwing":
		return Result.FAILURE

	match _internal_state:
		"idle":
			if npc._throw_timer > 0:
				return Result.FAILURE
				
			var dist = npc.global_position.distance_to(target.global_position)
			if dist < min_throw_range or dist > max_throw_range:
				return Result.FAILURE

			npc.state = "throwing"
			
			npc.throw_axe()
			
			_internal_state = "vulnerable"
			_timer = vulnerability_time

			npc.velocity.x = 0
			npc.velocity.z = 0

		"vulnerable":
			npc.velocity.x = move_toward(npc.velocity.x, 0, get_physics_process_delta_time() * 20.0)
			npc.velocity.z = move_toward(npc.velocity.z, 0, get_physics_process_delta_time() * 20.0)

			_timer -= get_physics_process_delta_time()
			if _timer <= 0:
				_internal_state = "idle"
				npc.state = "idle"
				return Result.SUCCESS

	return Result.RUNNING
