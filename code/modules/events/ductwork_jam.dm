#define GAS_LIMIT 50

///Ductwork Jam random event
///A random vent begins leaking Miasma due to a dead animal clogging it up and spraying gross corpse fumes everywhere.
///Can be fixed by plunging, like the ventilation clog event.
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
		/mob/living/basic/drone,
		/mob/living/basic/chicken,
		/mob/living/basic/wumborian_fugu,
		)
		spawned_mob = pick(silly_mob_list)
	else
		var/static/list/mob_list = list(
			/mob/living/basic/butterfly,
			/mob/living/basic/spider/maintenance,
			/mob/living/basic/mouse,
			/mob/living/basic/axolotl,
		)
		spawned_mob = pick(mob_list)

/datum/round_event/ductwork_jam/announce(fake)
	priority_announce("A dead animal has been detected in the [get_area_name(vent)] ventilation. As a result, it is currently expelling noxious fumes into the surrounding area.", "Seismic Report")

/datum/round_event/ductwork_jam/start()
	notify_ghosts(
		"A vent has begun spewing miasma!",
		source = vent,
		header = "Gross!",
	)
	RegisterSignal(vent, COMSIG_QDELETING, PROC_REF(vent_destroyed))
	RegisterSignal(vent, COMSIG_PLUNGER_ACT, PROC_REF(plunger_unclog))

/datum/round_event/ductwork_jam/tick()
	if(!ISMULTIPLE(activeFor, 3))
		return

	var/gas_to_spawn = min(GAS_LIMIT, activeFor / 3)

	if(vent.welded) //Sealing it up is just gonna spread it into the pipe network. Don't do that!
		var/datum/gas_mixture/vent_gasmix = vent.airs[1]
		vent_gasmix.add_gases(/datum/gas/miasma)
		vent_gasmix.gases[/datum/gas/miasma][MOLES] += (gas_to_spawn)
	else
		var/turf/vent_turf = get_turf(vent)
		vent_turf.atmos_spawn_air("[GAS_MIASMA]=[gas_to_spawn];[TURF_TEMPERATURE(T20C)]")

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

///Signal catcher for plunger_act()
/datum/round_event/ductwork_jam/proc/plunger_unclog(datum/source, obj/item/plunger/attacking_plunger, mob/user, reinforced)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attempt_unclog), user)
	return COMPONENT_NO_AFTERATTACK

///Handles the actual unclogging action and ends the event on completion.
/datum/round_event/ductwork_jam/proc/attempt_unclog(mob/user)
	if(vent.welded)
		to_chat(user, span_notice("You cannot pump [vent] if it's welded shut!"))
		return

	user.balloon_alert_to_viewers("plunging ductwork...", "plunging clogged ductwork...")
	if(do_after(user, 6 SECONDS, target = vent))
		user.balloon_alert_to_viewers("finished plunging")
		clear_signals()
		kill()

///Wraps up the event, and spews out a bunch of miasma for taking the easy way out.
/datum/round_event/ductwork_jam/proc/vent_destroyed(datum/source)
	SIGNAL_HANDLER
	spawn_corpse()
	///Add miasma release here
	end() //Probably make this a different proc to handle post-event behavior
	kill()

///Clears the signals related to the event, before we wrap things up.
/datum/round_event/ductwork_jam/proc/clear_signals()
	UnregisterSignal(vent, list(COMSIG_QDELETING, COMSIG_PLUNGER_ACT))

///Spawns the mob's corpse.
/datum/round_event/ductwork_jam/proc/spawn_corpse()
	var/mob/living/dead_mob = new spawned_mob(get_turf(vent))
	dead_mob.death(FALSE)
	dead_mob.adjustOxyLoss(dead_mob.maxHealth)

#undef GAS_LIMIT
