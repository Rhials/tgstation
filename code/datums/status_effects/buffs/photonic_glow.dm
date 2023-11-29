/// Effect intensity gained or lost per tick.
#define TICK_INTENSITY_INCREMENT 5
/// The glowy filter we apply over time
#define GLOWY_FILTER "glow_filter"

/// Provides a few minor positive effects. Intensity of these effects ramps up over time and fades away under certain conditions.
/// Both the mob and any items in their inventory being acted upon are
/datum/status_effect/photonic_glow
	id = "photon_glow"
	alert_type = /atom/movable/screen/alert/status_effect/photonic_glow
	remove_on_fullheal = FALSE
	status_type = STATUS_EFFECT_REFRESH
	///Should we be ramping up or fading away our effects? Switched when the user enters/exits the designated area.
	var/gaining_power = TRUE
	///How powerful should our effect be, from 0-100% intensity.
	var/glow_power = 10

/datum/status_effect/photonic_glow/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/photonic_glow/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(death_effect))
	return TRUE

/datum/status_effect/photonic_glow/tick(seconds_between_ticks)
	if(gaining_power)
		if(glow_power < 100)
			glow_power += TICK_INTENSITY_INCREMENT
	else
		glow_power -= TICK_INTENSITY_INCREMENT

	if(glow_power <= 0)
		qdel(src)
		return

	owner.add_filter(GLOWY_FILTER, 2, list("type" = "outline", "color" = COLOR_VIVID_YELLOW, "alpha" = 0, "size" = 1))
	var/filter = owner.get_filter(GLOWY_FILTER)
	animate(filter, alpha = glow_power, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

	//It's a beam of powerful starlight hitting the station. Vampires do not like sunlight.
	if(isvampire(owner))
		if(glow_power == 100)
			to_chat(owner, span_boldwarning("The intensity of the starlight overwhelms your form. The brightness intensifies to a burning white light, and suddenly... nothing."))
			owner.dust(TRUE, TRUE)
			return

		owner.apply_damage(glow_power * 0.10, BURN)
		to_chat(owner, span_userdanger("Your skin is seared by the intense beam of starlight!"))

/datum/status_effect/photonic_glow/on_remove()
	owner.remove_filter(GLOWY_FILTER)
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

/datum/status_effect/photonic_glow/proc/death_effect(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// The status effect popup for photonic glow.
/atom/movable/screen/alert/status_effect/photonic_glow
	name = "Glowing"
	desc = "Your skin feels tingly. Your electronics are softly humming. Something about where you're standing feels quite pleasant..."
	icon_state = "woozy"

#undef TICK_INTENSITY_INCREMENT
#undef GLOWY_FILTER
