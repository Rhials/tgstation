#define GAS_LIMIT 25

///Ductwork Jam random event
///A random vent begins leaking Miasma due to a dead animal clogging it up and spraying gross corpse fumes everywhere.
///Can be fixed by (idk)
/datum/round_event_control/ductwork_jam
	name = "Ductwork Jam"
	description = "Causes a vent to begin spewing out miasma. Gross!"
	typepath = /datum/round_event/ductwork_jam
	category = EVENT_CATEGORY_ENGINEERING
	earliest_start = 5 MINUTES
	weight = 15

/datum/round_event_control/ductwork_jam/can_spawn_event(players_amt, allow_magic)
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		var/turf/vent_turf = get_turf(vent)
		if(vent_turf && is_station_level(vent_turf.z) && !vent.welded)
			return TRUE //make sure we have a valid vent to spawn from.
	return FALSE

/datum/round_event/ductwork_jam
	start_when = 1
	announce_when = 20
	end_when = 2000 //figure out if you can make this last forever
	announce_chance = 80
	///Vent selected for the event.
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent
	///What mob will be kicked out of the vent when cleared.
	var/mob/spawned_mob = /mob/living/basic/mouse

/datum/round_event/ductwork_jam/setup()
	vent = get_vent()
	if(prob(10)) //Sometimes a silly mob get picked as the clogger instead. Enterprising crew could potentially revive and play around with it?
		var/static/list/silly_mob_list = list(
		/mob/living/basic/deer,
		/mob/living/basic/spider/maintenance,
		/mob/living/basic/mouse,
		)
	else
		var/static/list/mob_list = list(
			/mob/living/basic/butterfly,
			/mob/living/basic/spider/maintenance,
			/mob/living/basic/mouse,
		)

/datum/round_event/ductwork_jam/announce(fake)
	priority_announce("A dead animal has been detected in the [get_area_name(vent)] ventilation. As a result, it is currently expelling noxious fumes into the ventilation.", "Seismic Report")

/datum/round_event/ductwork_jam/start()
	notify_ghosts(
		"A vent has begun spewing miasma!",
		source = vent,
		header = "Gross!",
	)

/datum/round_event/ductwork_jam/tick()
	if(!ISMULTIPLE(activeFor, 5))
		return

	var/gas_to_spawn = min(GAS_LIMIT, activeFor / 5)

	if(vent.welded) //Sealing it up is just gonna spread it into the pipe network. Don't do that!
		var/datum/gas_mixture/vent_gasmix = vent.airs[1]
		vent_gasmix.add_gases(/datum/gas/miasma)
		vent_gasmix.gases[/datum/gas/miasma][MOLES] += (gas_to_spawn)
	else
		var/turf/vent_turf = get_turf(vent)
		vent_turf.atmos_spawn_air("[GAS_MIASMA]=][gas_to_spawn];[TURF_TEMPERATURE(T20C)]")

/**
 * Finds a valid vent to spawn mobs from.
 *
 * Randomly selects a vent that is on-station, unwelded, and hosted by a passable turf. If no vents are found, the event is immediately killed.
 */

/datum/round_event/ductwork_jam/proc/get_vent()
	var/list/vent_list = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		var/turf/vent_turf = get_turf(vent)
		if(vent_turf && is_station_level(vent_turf.z) && !vent.welded && !vent_turf.is_blocked_turf_ignore_climbable())
			vent_list += vent

	if(!length(vent_list))
		kill()
		CRASH("Unable to find suitable vent.")

	return pick(vent_list)

#undef GAS_LIMIT
