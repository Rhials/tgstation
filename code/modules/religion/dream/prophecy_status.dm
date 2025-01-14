///Applied when a sleeping player is given the prophetic dream rite
/datum/status_effect/prophecy
	id = "Prophetic Dream"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH // New effects will add to total duration
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = /atom/movable/screen/alert/status_effect/prophecy

/datum/status_effect/prophecy/on_creation(mob/living/new_owner, bonus_time)
	return ..()

/datum/status_effect/prophecy/on_apply()
	return ..()

/datum/status_effect/prophecy/on_remove()
	return ..()

/atom/movable/screen/alert/status_effect/prophecy
	name = "Prophetic Dream"
	desc = "Your dreams feel clearer. More vivid. You mind dances around with visions of the future to come..."
	icon_state = "exercised" //Change
