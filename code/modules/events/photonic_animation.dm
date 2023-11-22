/// "Photonic Animation" event, station is hit with sci-fi light particles or whatever that recharge and reinvigorate anyone they touch.
/// Provides small but useful positive effects (minor heals, satiaitey, slightly recharging held items) for players
/// over time when in the chosen area. Benefits should be broad enough that any job can consider visiting the area, since the goal is to bring people together.
/// Triggers in publish-ish areas (dorm halls), or places that won't encourage B&E or cause problems if 10 people suddenly barge in and camp out in it.
/datum/round_event_control/photonic_animation
	name = "Photonic Animation"
	typepath = /datum/round_event/photonic_animation
	max_occurrences = 3
	weight = 8
	category = EVENT_CATEGORY_FRIENDLY
	description = "The station is blasted with a beam of gentle photonic energy, providing benefits to anyone who basks in its light."
	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 3

/datum/round_event/photonic_animation
	start_when = 1
	end_when = 100
	announce_when = 7
	///The area the event effect will impact.
	var/area/chosen_area
	///A list of potential areas to trigger the event in. Meant to be "public-facing", large areas that wouldn't be disruptive for people to crowd in. No maints.
	var/static/list/valid_areas = typecacheof(list(
		/area/station/cargo/lobby,
		/area/station/cargo/sorting,
		/area/station/cargo/warehouse,
		/area/station/command/corporate_showroom,
		/area/station/command/corporate_suite,
		/area/station/command/gateway,
		/area/station/commons,
		/area/station/construction,
		/area/station/construction/storage_wing,
		/area/station/engineering/hallway,
		/area/station/engineering/lobby,
		/area/station/engineering/main,
		/area/station/engineering/atmos/pumproom, //admittedly this one could be a bit disruptive but also heheheha
		/area/station/escapepodbay,
		/area/station/hallway,
		/area/station/holodeck,
		/area/station/medical/coldroom, //hehe
		/area/station/medical/cryo,
		/area/station/medical/exam_room,
		/area/station/medical/patients_rooms,
		/area/station/medical/psychology,
		/area/station/science/lab,
		/area/station/science/lobby,
		/area/station/science/research,
		/area/station/security/courtroom,
		/area/station/security/holding_cell,
		/area/station/security/processing,
		/area/station/service/bar,
		/area/station/service/barber,
		/area/station/service/cafeteria,
		/area/station/service/chapel,
		/area/station/service/greenroom,
		/area/station/service/library,
		/area/station/service/theater,
	))

/datum/round_event/photonic_animation/setup()
	end_when += rand(15, 60)
	announce_when = 7

	var/list/possible_areas = typecache_filter_list(GLOB.areas, valid_areas)
	if(!length(possible_areas))
		stack_trace("No valid areas to run this event in! Something must be very wrong.")
		return

	chosen_area = pick(valid_areas)

/datum/round_event/photonic_animation/announce(fake)
	priority_announce(
		"Celestial readings indicate a nearby star is emitting an abnormal amount of polarized photons at the hull of [station_name()]. Expected impact site: [chosen_area.name].",
		"Anomaly Alert",
	)

/datum/round_event/photonic_animation/start()
	for(var/turf/turf_to_glow in get_area_turfs(chosen_area, subtypes = TRUE)) //Maybe make this FALSE for better control at the cost of a longer typecache?
		turf_to_glow.emp_act()
