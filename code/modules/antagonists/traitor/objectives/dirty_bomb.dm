/datum/traitor_objective_category/dirty_bomb
	name = "Deploy a %GASNAME% dirty bomb in the %AREANAME%"
	objectives = list(
		/datum/traitor_objective/dirty_bomb = 1,
	)

/datum/traitor_objective/dirty_bomb
	name = "Deploy a %GASNAME% bomb in the %GASAREA%" //I think this is what the replacetext was for?
	description = "Trigger a gas bomb "

	progression_minimum = 60 MINUTES
	progression_reward = list(30 MINUTES, 40 MINUTES)
	telecrystal_reward = list(7, 12)

	var/progression_objectives_minimum = 20 MINUTES
	/// Area where the GAS will be released (fill the room with gyass)
	var/area/target_area

/datum/traitor_objective/dirty_bomb/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(SStraitor.get_taken_count(/datum/traitor_objective/hack_comm_console) > 0)
		return FALSE
	if(handler.get_completion_progression(/datum/traitor_objective) < progression_objectives_minimum)
		return FALSE
	return TRUE

/datum/traitor_objective/dirty_bomb/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	replace_in_name("%GASNAME%", "whatever the gas name is"))
	replace_in_name("%GASAREA%", initial(target_area.name))
	return TRUE

/datum/traitor_objective/dirty_bomb/ungenerate_objective()
	UnregisterSignal(SSdcs, COMSIG_GLOB_TRAITOR_OBJECTIVE_COMPLETED) //replace this with whatever signals u use

/datum/traitor_objective/dirty_bomb/proc/on_unarmed_attack(mob/user, obj/machinery/computer/communications/target, proximity_flag, modifiers)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return
	if(!modifiers[RIGHT_CLICK])
		return
	if(!istype(target))
		return
	INVOKE_ASYNC(src, PROC_REF(begin_hack), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/traitor_objective/dirty_bomb/proc/begin_hack(mob/user, obj/machinery/computer/communications/target)
	if(!target.try_hack_console(user))
		return

	succeed_objective()

/obj/item/dirty_bomb
	name = "gas bomb"
	desc = "A device that injects fiendish amounts of hazardous gasses into the air around it. Handle with care!"
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "eyesnatcher"
	base_icon_state = "eyesnatcher"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	///Have we begun releasing our payload?
	var/active = FALSE
	/// Weakref to user's objective
	var/datum/weakref/objective_weakref

/obj/item/dirty_bomb/Initialize(mapload, objective)
	. = ..()
	objective_weakref = WEAKREF(objective)

/obj/item/dirty_bomb/Destroy()
	objective_weakref = null
	return ..()

/obj/item/dirty_bomb/afterattack(atom/movable/target, mob/user, flag) //replace this with inhand use
	if(!user.mind)
		return

	if(!IS_TRAITOR(user))
		to_chat(user, span_warning("You can't find any sort of triggering mechanism on this device!"))
		return

	var/datum/traitor_objective/locate_weakpoint/objective = objective_weakref.resolve()

	if(!objective || objective.objective_state == OBJECTIVE_STATE_INACTIVE || objective.handler.owner != user.mind)
		to_chat(user, span_warning("You don't think it would be wise to use [src]."))
		return

	var/area/target_area = get_area(target)
	if (target_area.type != objective.weakpoint_area)
		to_chat(user, span_warning("[src] can only be detonated in [initial(objective.weakpoint_area.name)]."))
		return

	var/area/target_area = get_area(target)
	var/datum/traitor_objective/locate_weakpoint/objective = objective_weakref.resolve()
