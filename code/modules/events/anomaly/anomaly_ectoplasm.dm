/datum/round_event_control/anomaly/anomaly_ectoplasm
	name = "Anomaly: Ectoplasmic Outburst"
	typepath = /datum/round_event/anomaly/anomaly_ectoplasm
	min_players = 30
	max_occurrences = 2
	weight = 8
	category = EVENT_CATEGORY_ANOMALIES
	description = "Anomaly that produces an effect of varying intensity based on how many ghosts are orbiting it."
	///The admin-set intensity value
	var/override

/datum/round_event_control/anomaly/anomaly_ectoplasm/admin_setup(mob/admin)
	. = ..()

	if(!check_rights(R_FUN))
		return ADMIN_CANCEL_EVENT

	var/list/power_values = list("Minor", "Moderate", "Major")
	var/selection

	if(tgui_alert(usr, "Override the anomaly effect?", "Criiiiinge.", list("Yes", "No")) == "Yes")
		selection = tgui_input_list(usr, "Provide Override", "Seriously, CRINGE.", power_values) //Override does NOT override the number of ghosts orbiting, only determining which effect that will occur.

	if(!selection)
		return

	switch(selection)
		if("Minor")
			override = 10
		if("Moderate")
			override = 35
		if("Major")
			override = 55

/datum/round_event/anomaly/anomaly_ectoplasm
	anomaly_path = /obj/effect/anomaly/ectoplasm
	start_when = 3
	announce_when = 20

/datum/round_event/anomaly/anomaly_ectoplasm/start()
	var/datum/round_event_control/anomaly/anomaly_ectoplasm/anomaly_event = control

	if(!anomaly_event.override)
		..() //If we provide no override, just run the usual startup.
	else
		var/turf/anomaly_turf = placer.findValidTurf(impact_area)
		var/obj/effect/anomaly/ectoplasm/newAnomaly
		if(anomaly_turf)
			newAnomaly = new anomaly_path(anomaly_turf)
			newAnomaly.override_ghosts = TRUE
			newAnomaly.effect_power = anomaly_event.override
			if(newAnomaly.effect_power > 65) //Otherwise it won't update because anomalyEffect is overridden and blocked
				newAnomaly.icon_state = "ectoplasm_heavy"
				newAnomaly.update_appearance(UPDATE_ICON_STATE)
		if (newAnomaly)
			announce_to_ghosts(newAnomaly)

	anomaly_event.override = null //Clean up for future use.

/datum/round_event/anomaly/anomaly_ectoplasm/announce(fake)
	priority_announce("Localized ectoplasmic outburst detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")
