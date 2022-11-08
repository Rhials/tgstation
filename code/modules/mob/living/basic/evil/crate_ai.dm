/datum/ai_controller/basic_controller/mimic
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED //It would be really funny if someone managed to accidentally take one of these to the cargo shuttle
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk //Change to return/lurk behavior

	planning_subtrees = list(
		/datum/ai_planning_subtree/crate_lurk,
		/datum/ai_planning_subtree/crate_prowl
	)

/datum/ai_planning_subtree/crate_lurk

/datum/ai_planning_subtree/crate_lurk/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(QDELETED(target))
		return
	priority_announce("pee")

/datum/ai_planning_subtree/crate_prowl

/datum/ai_planning_subtree/crate_prowl/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_EXECUTION_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(QDELETED(target) || target.stat < UNCONSCIOUS)
		return

	priority_announce("pee")

	return SUBTREE_RETURN_FINISH_PLANNING
