extends Leaf
class_name LeafPitchforkBasic

## NOTA DE FACU
# la manera de hacer ataques aca es completamente distinta a la de todos los otros enemigos asi que
# a falta de reescribir todo meti las animaciones donde entraban a lo largo de las funciones

@export var attack_range: float = 2.5
@export var damage: float = 25.0
@export var recovery_time: float = 1.0
@export var vulnerability_time: float = 1.0
@export var knockback_multiplier: float = 0.5

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
	var npc : Enemy = owner
	var target : Player = Globals.player
	if not target: return Result.FAILURE

	if npc.state != "idle" and npc.state != "basic_attack":
		return Result.FAILURE

	var dist = npc.global_position.distance_to(target.global_position)

	match _internal_state:
		"idle":
			owner.is_attacking = false
			if dist > attack_range:
				return Result.FAILURE

			npc.state = "basic_attack"
			_internal_state = "anticipation"
			_timer = 0.4
			npc.velocity.x = 0
			npc.velocity.z = 0

		"anticipation":
			owner.is_attacking = true
			owner.anim.play("attacks/cargando_ataque")
			npc.velocity.x = 0
			npc.velocity.z = 0
			_timer -= get_physics_process_delta_time()
			
			if _timer <= 0:
				if dist <= attack_range:
					target.take_damage(damage, npc.global_position, knockback_multiplier)
					_internal_state = "recovery"
					_timer = recovery_time
				else:
					_internal_state = "vulnerable"
					_timer = vulnerability_time

		"recovery", "vulnerable":
			owner.is_attacking = false
			npc.velocity.x = 0
			npc.velocity.z = 0
			_timer -= get_physics_process_delta_time()
			
			if _timer <= 0:
				_internal_state = "idle"
				npc.state = "idle"
				return Result.SUCCESS
		"basic_attack":
			owner.is_attacking = true
			owner.anim.play("attacks/estocada_ataque")

	return Result.RUNNING
