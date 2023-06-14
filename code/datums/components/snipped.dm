///This component makes stuff give way when stepped over.
/datum/component/snipped
	///signal list given to connect_loc
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	///the overlay we apply when snipped
	var/snip_overlay


/datum/component/snipped/Initialize(snip_overlay)
	. = ..()

	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/snipped/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_UPDATE_OVERLAYS))
	qdel(GetComponent(/datum/component/connect_loc_behalf))
	snip_overlay = null

///Handles when someone steps on a snipped tile
/datum/component/snipped/proc/on_entered(turf/source_turf, atom/movable/crossing_movable)
	SIGNAL_HANDLER

	if(parent == crossing_movable)
		return

	if(prob(5)) //Sometimes, you just get lucky.
		return//put audio here :3

	if(isliving(crossing_movable))
		var/mob/living/crossing_mob = crossing_movable
		if(crossing_mob.body_position == LYING_DOWN || crossing_mob.m_intent == MOVE_INTENT_WALK)
			return

	to_chat(crossing_movable, span_alert("The [parent] creaks for a moment, then collapses under your weight!"))
	qdel(parent)

	/// Used to apply the snipping overlay, for a tiny visual indicator.
/datum/component/snipped/proc/on_update_overlays(turf/parent_turf, list/overlays)
	SIGNAL_HANDLER

	if(snip_overlay)
		overlays += snip_overlay

/datum/component/snipped/proc/on_examine(mob/living/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_warning("[parent] looks like it's barely held in place, and will collapse under any weight!")

/obj/item/tampering_saw
	name = "tampering saw"
	desc = "An arm-mounted holographic blade. Its lengthy blade can be used to sabotage equipment, "
	icon_state = "tampering_saw"
	inhand_icon_state = "tampering_saw"
	attack_verb_continuous = list("devastates", "brutalizes", "commits a war crime against", "obliterates", "humiliates")
	attack_verb_simple = list("devastate", "brutalize", "commit a war crime against", "obliterate", "humiliate")
	tool_behaviour = null

/obj/item/snipper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = 12, \
		throwforce_on = 6, \ //You're not supposed to throw it dumbass
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives it saw behaviors when active.
 */
/obj/item/snipper/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(active)
		tool_behaviour = TOOL_SAW
	else
		tool_behaviour = initial(tool_behaviour)

	balloon_alert(user, "[name] [active ? "active!":"disabled"]")
	playsound(user ? user : src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 5, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE
