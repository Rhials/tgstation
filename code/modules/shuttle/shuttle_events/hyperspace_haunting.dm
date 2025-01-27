/// Repeat the "buckle in or fall over" event a couple times
/datum/shuttle_event/hyperspace_haunting
	name = "Hyperspace Haunting"
	event_probability = 2 //Increase this with wizard spells maybe? Maybe on how many dead there are?
	activation_fraction = 0.05
	var/list/areas_to_reveal = list()

/datum/shuttle_event/hyperspace_haunting/activate()
	. = ..()
	minor_announce("Supernatural entities have migrated into your station's localized hyperspace vectors. \
		The ",
		title = "Emergency Shuttle", alert = TRUE)
	areas_to_reveal = get_areas(/area/shuttle/transit)
	for(var/area/individual_area in areas_to_reveal)
		RegisterSignal(individual_area, COMSIG_AREA_ENTERED, PROC_REF(reveal_ghost)) //Doesnt fucking work bc ghosts dont send this signal. Damnit.
		RegisterSignal(individual_area, COMSIG_AREA_EXITED, PROC_REF(conceal_ghost))

/datum/shuttle_event/hyperspace_haunting/proc/reveal_ghost(datum/source, atom/movable/arrived, area/old_area)
	SIGNAL_HANDLER

	if(isobserver(arrived))
		var/mob/dead/observer/observer_mover = arrived
		observer_mover.set_invisibility(0)

/datum/shuttle_event/hyperspace_haunting/proc/conceal_ghost(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(isobserver(gone))
		var/mob/dead/observer/observer_mover = gone
		observer_mover.set_invisibility(GLOB.observer_default_invisibility)
