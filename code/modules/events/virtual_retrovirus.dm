/datum/round_event_control/virtual_retrovirus
	name = "Virtual Retrovirus"
	typepath = /datum/round_event/virtual_retrovirus
	max_occurrences = 3
	min_players = 20
	category = EVENT_CATEGORY_ENGINEERING
	description = "A computer virus begins spreading into the station's systems. As more consoles are ."

/datum/round_event/virtual_retrovirus
	fakeable = FALSE
	end_when = 99999
	///A list of all consoles to be impacted by this event
	var/list/stored_consoles = list()
	///An assoc list of consoles and their distance to patient zero. Uses
	var/list/list/console_distance_registry = list()
	///The computer spreading the virus.
	var/obj/machinery/computer/patient_zero
	///How many. Determines the severity of side-effects.
	var/takeover_completion = 0

/datum/round_event/virtual_retrovirus/start()
	patient_zero = pick(SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer))
	for(var/obj/machinery/computer/console in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer))
		if(console == patient_zero)
			continue
		console_distance_registry[get_dist(patient_zero, console)] += console
		stored_consoles += console

	sortMerge(console_distance_registry)
