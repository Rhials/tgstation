/datum/round_event_control/bureaucratic_error
	name = "Bureaucratic Error"
	typepath = /datum/round_event/bureaucratic_error
	max_occurrences = 1
	weight = 5
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Randomly opens and closes job slots, or changes the overflow role."
	///Will the error change the overflow?
	var/do_overflow
	///What role is going to be overflowed?
	var/datum/job/new_overflow

/datum/round_event_control/bureaucratic_error/admin_setup()
	if(!check_rights(R_FUN))
		return

	var/choice = tgui_alert(usr, "What kind of paperwork error do you want to cause?", "Who cares about paperwork anyways?", list("Change overflow", "Randomize slots", "Suprise me!"))

	switch(choice)
		if("Change overflow")
			var/list/jobs = SSjob.joinable_occupations.Copy()
			new_overflow = tgui_input_list(usr, "Pick a new overflow role!", "Office Space, in Space", jobs)



/datum/round_event/bureaucratic_error
	announce_when = 1
	var/is_overflow = FALSE //Replace this with two seperate round_events for the round_event_control to pick from

/datum/round_event/bureaucratic_error/announce(fake)
	if(is_overflow)
		priority_announce("A catastrophic bureaucratic error in the Organic Resources Department may result in extreme personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert")
	else
		priority_announce("A minor bureaucratic error in the Organic Resources Department may result in personnel shortages in some departments and redundant staffing in others.", "Paperwork Mishap Alert")

/datum/round_event/bureaucratic_error/start()
	var/datum/round_event_control/bureaucratic_error/error_event = control
	if(error_event.do_overflow)
		is_overflow = error_event.do_overflow
	else
		if(prob(33))
			is_overflow = TRUE

	var/list/jobs = SSjob.joinable_occupations.Copy()
	if(is_overflow) // Only allows latejoining as a single role. Add latejoin AI bluespace pods for fun later.
		var/datum/job/overflow = pick_n_take(jobs)
		overflow.spawn_positions = -1
		overflow.total_positions = -1 // Ensures infinite slots as this role. Assistant will still be open for those that cant play it.
		for(var/job in jobs)
			var/datum/job/current = job
			if(!current.allow_bureaucratic_error)
				continue
			current.total_positions = 0
	else // Adds/removes a random amount of job slots from all jobs.
		for(var/datum/job/current as anything in jobs)
			if(!current.allow_bureaucratic_error)
				continue
			var/ran = rand(-2,4)
			current.total_positions = max(current.total_positions + ran, 0)
