/datum/round_event_control/bureaucratic_error
	name = "Bureaucratic Error"
	typepath = /datum/round_event/bureaucratic_error
	max_occurrences = 1
	weight = 5
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Randomly opens and closes job slots, or changes the overflow role."
	/// Will the error change the overflow?
	var/do_overflow
	/// What role is going to be overflowed?
	var/datum/job/new_overflow

/datum/round_event_control/bureaucratic_error/admin_setup()
	if(!check_rights(R_FUN))
		return

	do_overflow = null
	new_overflow = null // We only need to scrub these values in admin_setup, because the event only ever runs naturally once.

	var/choice = tgui_alert(usr, "What kind of paperwork error do you want to cause?", "Who cares about paperwork anyways?", list("Change overflow", "Randomize slots", "Suprise me!"))

	switch(choice)
		if("Change overflow")
			do_overflow = TRUE
			var/list/jobs = SSjob.joinable_occupations.Copy()
			new_overflow = tgui_input_list(usr, "Pick a new overflow role!", "Office Space, in Space", jobs)
		if("Randomize slots")
			do_overflow = FALSE
		if("Suprise me!")
			if(prob(50))
				do_overflow = TRUE
				to_chat(usr, span_notice("Randomly modifying the overflow role..."))
			else
				do_overflow = FALSE
				to_chat(usr, span_notice("Scrambling the available jobs..."))

/datum/round_event/bureaucratic_error
	announce_when = 1
	/// Will we be overflowing a random role? (If not, the event will scramble the job slots).
	var/modify_overflow = FALSE
	/// The selected overflow role, passed down from the round_event_control.
	var/datum/job/new_overflow

/datum/round_event/bureaucratic_error/announce(fake)
	if(modify_overflow)
		priority_announce("A catastrophic bureaucratic error in the Organic Resources Department may result in extreme personnel shortages in most departments and redundant staffing in others.", "Paperwork Mishap Alert")
	else
		priority_announce("A minor bureaucratic error in the Organic Resources Department may result in personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert")

/datum/round_event/bureaucratic_error/start()
	var/datum/round_event_control/bureaucratic_error/error_event = control

	if(error_event.new_overflow) // If there is a specific role to overflow passed down, we grab it here.
		new_overflow = error_event.new_overflow

	if(isnull(error_event.do_overflow)) // If no admin preference has been passed down, we randomly decide to overflow or not.
		if(prob(33))
			modify_overflow = TRUE
	else if(error_event.do_overflow) // If an admin has decided that yes, we will absolutely have an overflow event.
		modify_overflow = error_event.do_overflow
		new_overflow = error_event.new_overflow

	var/list/joinable_jobs = SSjob.joinable_occupations.Copy() // Grab the jobs that we're going to modify.

	if(modify_overflow)
		do_overflow(joinable_jobs) // Only allows latejoining as a single role. Add latejoin AI bluespace pods for fun later.
	else
		scramble_jobs(joinable_jobs) // Adds/removes a random amount of job slots from all jobs.

/**
 * Closes all job slots except for one randomly selected job, which becomes an overflow role.
 *
 * Selects one job to be a overflow role (in addition to assistant), closes all other job slots.
 * This is the functionality for if the event decides to modify the overflow role.
 *
 * Arguments:
 * * jobs - The joinable occupations to iterate through and modify.
 */

/datum/round_event/bureaucratic_error/proc/do_overflow(list/jobs)
	if(!new_overflow) // If no overflow role has been passed by the round_event_control, we pick one.
		new_overflow = pick_n_take(jobs)

	new_overflow.spawn_positions = -1
	new_overflow.total_positions = -1 // Ensures infinite slots as this role. Assistant will still be open for those that cant play it.
	for(var/job in jobs)
		var/datum/job/current = job
		if(!current.allow_bureaucratic_error)
			continue
		current.total_positions = 0

/**
 * Closes all job slots except for one randomly selected job, which becomes an overflow role.
 *
 * Picks out the jobs in the passed list and modifies their available slots by anywhere from -2 to +4.
 * This is the functionality for if the event decides to scramble the available job slots.
 *
 * Arguments:
 * * jobs - The joinable occupations to iterate through and modify.
 */

/datum/round_event/bureaucratic_error/proc/scramble_jobs(list/jobs)
	for(var/datum/job/current as anything in jobs)
		if(!current.allow_bureaucratic_error)
			continue
		var/ran = rand(-2,4)
		current.total_positions = max(current.total_positions + ran, 0)
