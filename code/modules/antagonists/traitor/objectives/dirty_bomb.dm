/datum/traitor_objective_category/dirty_bomb
	name = "Deploy a %GASNAME% dirty bomb in the %AREANAME%"
	objectives = list(
		/datum/traitor_objective/dirty_bomb = 1,
	)

/datum/traitor_objective/dirty_bomb
	name = "Deploy a %GASNAME% bomb in the %GASAREA%" //I think this is what the replacetext was for?
	description = "Trigger a gas bomb."

	progression_minimum = 25 MINUTES //maybe make these vary for subtypes??
	progression_reward = list(10 MINUTES, 12 MINUTES)
	telecrystal_reward = list(1, 2)

	var/progression_objectives_minimum = 20 MINUTES
	/// Area where the GAS will be released (fill the room with gyass)
	var/area/target_area

/datum/traitor_objective/dirty_bomb/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	replace_in_name("%GASNAME%", "whatever the gas name is")
	replace_in_name("%GASAREA%", initial(target_area.name))
	return TRUE

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

/obj/item/dirty_bomb/attack_self(mob/user, modifiers)
	if(!user.mind)
		return

	if(!IS_TRAITOR(user))
		to_chat(user, span_warning("You can't find any sort of triggering mechanism on this device!"))
		return

	var/datum/traitor_objective/dirty_bomb/objective = objective_weakref.resolve()

	if(!objective || objective.objective_state == OBJECTIVE_STATE_INACTIVE || objective.handler.owner != user.mind)
		to_chat(user, span_warning("You don't think it would be wise to use [src]."))
		return

	var/area/current_area = get_area(src)
	if (current_area.type != objective.target_area)
		to_chat(user, span_warning("[src] can only be detonated in [initial(objective.target_area.name)]."))
		return

	objective.succeed_objective()
	balloon_alert(user, "dirty bomb armed")

