///This component makes turfs give way when stepped over.
/datum/component/snipped
	///signal list given to connect_loc
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	///the overlay we apply when snipped
	var/snip_overlay


/datum/component/snipped/Initialize()
	. = ..()

	if(snip_overlay)
		overlays += snip_overlay

	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))

/datum/component/snipped/UnregisterFromParent()
	. = ..()
	qdel(GetComponent(/datum/component/connect_loc_behalf))
	snip_overlay = null

///Handles when someone steps on a snipped tile
/datum/component/snipped/proc/on_entered(turf/source_turf, atom/movable/crossing_movable)
	SIGNAL_HANDLER

	if(parent == crossing_movable)
		return

	var/mob/living/parent_as_living = parent

	if(parent_as_living.body_position != LYING_DOWN || parent_as_living.m_intent == MOVE_INTENT_WALK)
		return

	if(prob(95))
		collapse()


/datum/component/snipped/proc/collapse(mob/living/target)
	qdel(parent)

	/// Used to maintain the thermite overlay on the parent [/turf].
/datum/component/snipped/proc/on_update_overlays(turf/parent_turf, list/overlays)
	SIGNAL_HANDLER

	if(snip_overlay)
		overlays += snip_overlay
