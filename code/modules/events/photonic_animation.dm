/// "Photonic Beam" event, station is hit with sci-fi light particles or whatever that reinvigorate anyone they touch.
/// Provides small but useful positive effects (minor heals, satiaitey, slightly recharging held items) for players over time when in the chosen area.
/// Benefits should be broad enough that any job can consider visiting the area, since the goal is to bring people together.
/// Triggers in publish-ish areas (dorm halls), or places that won't encourage B&E or cause problems if 10 people suddenly barge in and camp out in it.
/datum/round_event_control/photonic_beam
	name = "Photonic Beam"
	typepath = /datum/round_event/photonic_beam
	max_occurrences = 3
	weight = 8
	category = EVENT_CATEGORY_FRIENDLY
	description = "The station is blasted with a beam of gentle photonic energy, making an area provide a gentle positive buff to players in the chosen area."
	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 3

/datum/round_event/photonic_beam
	start_when = 1
	end_when = 90
	announce_when = 10
	///The area the event effect will impact.
	var/area/chosen_area
	///A list of turfs that will be affected by this event.
	var/list/affected_turf_list = list()
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

/datum/round_event/photonic_beam/setup()
	end_when += rand(15, 60)
	announce_when = 7

	var/list/possible_areas = typecache_filter_list(GLOB.areas, valid_areas)
	if(!length(possible_areas))
		stack_trace("No valid areas to run this event in! Something must be very wrong.")
		return

	chosen_area = pick(possible_areas)
	affected_turf_list += get_area_turfs(chosen_area)

/datum/round_event/photonic_beam/announce(fake)
	priority_announce(
		"A nearby celestial body is emitting an abnormal amount of polarized photons at the hull of [station_name()]. \
		Expected impact site: [chosen_area.name]. Employees are encouraged to investigate and report any \
		[pick("reinvigorating", "positive", "painful", "abnormal", "rejuvinating")] effects from [pick("existing", "relaxing", "congregating", "occupying", "sitting")] in the area.",
		"Solar Alert",
	)

/datum/round_event/photonic_beam/start()
	RegisterSignal(chosen_area, COMSIG_AREA_ENTERED, PROC_REF(apply_glow))

/datum/round_event/photonic_beam/tick()
	for(var/turf/turf_to_glow in affected_turf_list)
		if(isopenturf(turf_to_glow) && prob(10))
			new /obj/effect/temp_visual/photonic_fizzle(turf_to_glow)

/datum/round_event/photonic_beam/end()
	UnregisterSignal(chosen_area, COMSIG_AREA_ENTERED, COMSIG_AREA_EXITED)

/datum/round_event/photonic_beam/proc/apply_glow(datum/source, atom/movable/arrived, area/old_area)
	SIGNAL_HANDLER
	if(!isliving(arrived))
		return

	var/mob/living/mob_to_glow = arrived
	var/datum/status_effect/photonic_glow/applied_effect = mob_to_glow.apply_status_effect(/datum/status_effect/photonic_glow)
	RegisterSignal(chosen_area, COMSIG_AREA_EXITED, PROC_REF(remove_glow), applied_effect)

///Informs the user's status effect that they are no longer meant to self-refresh and should fade away.
/datum/round_event/photonic_beam/proc/remove_glow(datum/source, atom/movable/gone, direction, datum/status_effect/photonic_glow/effect_to_remove)
	SIGNAL_HANDLER

	if(effect_to_remove)
		effect_to_remove.gaining_power = FALSE

/obj/effect/temp_visual/photonic_fizzle
	name = "photonic glow"
	icon_state = "blessed"
	duration = 10

