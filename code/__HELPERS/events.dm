#define UNLIT_AREA_BRIGHTNESS 0.2

/**
 * Finds us a generic maintenance spawn location.
 *
 * Goes through the list of the generic mainteance landmark locations, checking for atmos safety if required, and returns
 * a valid turf. Returns MAP_ERROR if no valid locations are present.
 * Returns nothing and alerts admins if no valid points are found. Keep this in mind
 * when using this helper.
 */

/proc/find_maintenance_spawn(atmos_sensitive = FALSE, require_darkness = FALSE)
	var/list/possible_spawns = list()
	for(var/spawn_location in GLOB.generic_maintenance_landmarks)
		var/turf/spawn_turf = get_turf(spawn_location)

		if(atmos_sensitive && !is_safe_turf(spawn_turf))
			continue

		if(require_darkness && spawn_turf.get_lumcount() > UNLIT_AREA_BRIGHTNESS)
			continue

		possible_spawns += spawn_turf

	if(!length(possible_spawns))
		message_admins("No valid generic_maintenance_landmark landmarks found, aborting...")
		return null

	return pick(possible_spawns)

/**
 * Finds us a generic spawn location in space.
 *
 * Goes through the list of the space carp spawn locations, picks from the list, and
 * returns that turf. Returns MAP_ERROR if no landmarks are found.
 */

/proc/find_space_spawn()
	var/list/possible_spawns = list()
	for(var/obj/effect/landmark/carpspawn/spawn_location in GLOB.landmarks_list)
		if(!isturf(spawn_location.loc))
			stack_trace("Carp spawn found not on a turf: [spawn_location.type] on [isnull(spawn_location.loc) ? "null" : spawn_location.loc.type]")
			continue
		possible_spawns += get_turf(spawn_location)

	if(!length(possible_spawns))
		message_admins("No valid carpspawn landmarks found, aborting...")
		return null

	return pick(possible_spawns)

/**
 * Forces a random event
 *
 * Locates the round_event_control typepath passed on the event controller, and forces it to run an event.
 *
 * * event_typepath - the /datum/round_event_control of the event we wish to run.
 * * cause - a string explaining the cause of the event. Should be in lowercase with no bookending punctuation or spaces.
 */

/proc/force_event(event_typepath, cause)
	var/datum/round_event_control/our_event = locate(event_typepath) in SSevents.control
	if(!our_event)
		CRASH("Attempted to force event [event_typepath], but the event path could not be found!")
	our_event.run_event(event_cause = cause)

/**
 * Forces a random event, asynchronously
 *
 * Locates the round_event_control typepath passed on the event controller, and forces it to run asynchronously.
 *
 * * event_typepath - the /datum/round_event_control of the event we wish to run.
 * * cause - a string explaining the cause of the event. Should be in lowercase with no bookending punctuation or spaces.
 */
/proc/force_event_async(event_typepath, cause)
	var/datum/round_event_control/our_event = locate(event_typepath) in SSevents.control
	if(!our_event)
		CRASH("Attempted to force event [event_typepath], but the event path could not be found!")
	INVOKE_ASYNC(our_event, TYPE_PROC_REF(/datum/round_event_control, run_event), event_cause = cause)

/**
 * Forces a random event after the given delay.
 *
 * Locates the round_event_control typepath passed on the event controller, and forces it to run after the given delay has passed.
 *
 * * event_typepath - the /datum/round_event_control of the event we wish to run.
 * * cause - a string explaining the cause of the event. Should be in lowercase with no bookending punctuation or spaces.
 */
/proc/force_event_after(event_typepath, cause, delay)
	var/datum/round_event_control/our_event = locate(event_typepath) in SSevents.control
	if(!our_event)
		CRASH("Attempted to force event [event_typepath], but the event path could not be found!")
	addtimer(CALLBACK(our_event, TYPE_PROC_REF(/datum/round_event_control, run_event), FALSE, null, FALSE, cause), delay)

#undef UNLIT_AREA_BRIGHTNESS
