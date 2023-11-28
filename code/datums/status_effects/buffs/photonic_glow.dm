/// Provides a few small
/// Both the mob and any items in their inventory being acted upon are
/datum/status_effect/photonic_glow
	id = "glowing"
	alert_type = /atom/movable/screen/alert/status_effect/photonic_glow
	remove_on_fullheal = FALSE
	///Should we be ramping up or fading away our effects? Switched when the user enters/exits the designated area.
	var/gaining_power = TRUE

/datum/status_effect/photonic_glow/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/photonic_glow/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(death_effect))

	return TRUE

/datum/status_effect/photonic_glow/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

/datum/status_effect/photonic_glow/proc/death_effect(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/// The status effect popup for photonic glow.
/atom/movable/screen/alert/status_effect/photonic_glow
	name = "Glowing"
	desc = "Your skin feels tingly. Your electronics are softly humming. Something about where you're standing feels quite pleasant..."
	icon_state = "woozy"
