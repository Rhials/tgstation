/datum/round_event_control/anomaly/anomaly_ectoplasm
	name = "Anomaly: Ectoplasmic Outburst"
	typepath = /datum/round_event/anomaly/anomaly_ectoplasm
	min_players = 30
	max_occurrences = 2
	weight = 15
	category = EVENT_CATEGORY_ANOMALIES
	description = "Anomaly that produces an effect of varying intensity based on how many ghosts are orbiting it."

/datum/round_event_control/anomaly/anomaly_ectoplasm/can_spawn_event(players_amt) //Ghost check here (might need config thing??)
	. = ..()



/datum/round_event/anomaly/anomaly_ectoplasm
	anomaly_path = /obj/effect/anomaly/ectoplasm

/datum/round_event/anomaly/anomaly_ectoplasm/announce(fake)
	priority_announce("Localized ectoplasmic outburst detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")
