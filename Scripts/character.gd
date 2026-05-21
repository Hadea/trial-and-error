extends Node2D

@export var NavigationTarget: Vector2:
	set(value):
		NavigationTarget = value
		navigationAgent.target_position = value
	get:
		return NavigationTarget

@export var NavigationTargetArray: Array[Vector2] ##maybe packed array?
@export var CurrentCharacterStatus: Constants.CharacterStatus = Constants.CharacterStatus.Idle
@export var CharacterSpawner: Node2D
@export var WalkingSpeed: float = 50
var timeToNextStatus: float = 1
var navigationAgent: NavigationAgent2D
var startingPosition: Vector2

func _ready() -> void:
	startingPosition = global_position
	randomize()
	navigationAgent = find_child("NavigationAgent2D", true) as NavigationAgent2D ##Agent buffer to avoid constant searches
	if !navigationAgent:
		print_debug("no nav agent found")


func ReevaluateTarget():
	if navigationAgent.is_target_reachable():
		return # still reachable, nothing to do
	else:
		# resetting the character to search for a new target
		CurrentCharacterStatus = Constants.CharacterStatus.Idle
		timeToNextStatus = 0.0

func _physics_process(delta: float) -> void:
	timeToNextStatus -= delta
	if timeToNextStatus <= 0.0:
		match CurrentCharacterStatus:
			Constants.CharacterStatus.Idle:
				#find a target
				var reachableTargets: PackedVector2Array
				for target in NavigationTargetArray:
					NavigationTarget = target
					if navigationAgent.is_target_reachable():
						reachableTargets.push_back(target)
						
				if reachableTargets.size() > 0: # reachable targets exist
					NavigationTarget = reachableTargets[randi_range(0,reachableTargets.size()-1)] # choosing random target from list
					CurrentCharacterStatus = Constants.CharacterStatus.Walking
					timeToNextStatus = 0.2
			Constants.CharacterStatus.Walking:
				if navigationAgent.is_navigation_finished():
					CurrentCharacterStatus = Constants.CharacterStatus.Browsing
					timeToNextStatus = 3.0
				else:
					if !navigationAgent.is_target_reachable():
						# target disappeared
						CurrentCharacterStatus = Constants.CharacterStatus.Idle
						timeToNextStatus = 1.0
					else:
						# walking towards the target until reached
						transform.origin = global_position.move_toward(navigationAgent.get_next_path_position(), WalkingSpeed*delta)
			Constants.CharacterStatus.Browsing:
				# preparing to leave
				NavigationTarget = startingPosition
				CurrentCharacterStatus = Constants.CharacterStatus.Leaving
				timeToNextStatus = 1
			Constants.CharacterStatus.Leaving:
				if navigationAgent.is_navigation_finished():
					CharacterSpawner.KillCharacter(self)
				else:
					if !navigationAgent.is_target_reachable():
						# Exit not reachable
						print_debug("Exit is not reachable")
						CharacterSpawner.KillCharacter(self)
					else:
						# walking towards the exit until reached
						transform.origin = global_position.move_toward(navigationAgent.get_next_path_position(), WalkingSpeed*delta)
				
			Constants.CharacterStatus.NoTarget:
				print_debug("No target to move to")
				timeToNextStatus = 1.0
