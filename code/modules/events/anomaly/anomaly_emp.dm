/datum/round_event_control/anomaly/anomaly_emp
	name = "Anomaly: Electromagnetic Flux"
	typepath = /datum/round_event/anomaly/anomaly_emp

	max_occurrences = 1
	weight = 15
	description = "This anomaly randomly teleports all items and mobs in a large area."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 2

/datum/round_event/anomaly/anomaly_emp
	start_when = ANOMALY_START_MEDIUM_TIME
	announce_when = ANOMALY_ANNOUNCE_MEDIUM_TIME
	anomaly_path = /obj/effect/anomaly/emp

/datum/round_event/anomaly/anomaly_emp/announce(fake)
	priority_announce("Electromagnetic inverse-wavelength detected on [ANOMALY_ANNOUNCE_MEDIUM_TEXT] [impact_area.name].", "Anomaly Alert")
