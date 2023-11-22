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
	description = "The station is blasted with a beam of gentle photonic energy, providing benefits to anyone who basks in the light."
	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 3

/datum/round_event/photonic_animation
	start_when = 1
	end_when = 100
	announce_when = 7
	///A list of potential areas to trigger the event in.
	var/static/list/valid_areas = list(
		/area/station/hallway,









	)


/datum/round_event/photonic_animation/setup()
	end_when += rand(15, 60)
	announce_when = 7


/datum/round_event/photonic_animation/announce(fake)
	priority_announce(
		"Celestial readings indicate a nearby star is emitting an abnormal amount of polarized photons at the hull of [station_name()]. Expected impact site: [].",
		"Anomaly Alert",
	)

/datum/round_event/photonic_animation/start()
	SSweather.run_weather(/datum/weather/rad_storm)
