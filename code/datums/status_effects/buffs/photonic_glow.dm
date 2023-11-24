/// Provides a few small
/// Both the mob and any items in their inventory being acted upon are
/datum/status_effect/photonic_glow
	id = "glowing"
	alert_type = /atom/movable/screen/alert/status_effect/photonic_glow
	remove_on_fullheal = FALSE

/datum/status_effect/drugginess/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/drugginess/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(death_effect))

	return TRUE

/datum/status_effect/drugginess/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

	owner.clear_mood_event(id)

/datum/status_effect/drugginess/proc/death_effect(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/// The status effect popup for photonic glow.
/atom/movable/screen/alert/status_effect/photonic_glow
	name = "Glowing"
	desc = "."
	icon_state = "high"
