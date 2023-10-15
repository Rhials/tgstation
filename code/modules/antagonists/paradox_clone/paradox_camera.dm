#define PREP_TIME 3 MINUTES

/mob/camera/paradox
	name = "Spacetime Ripple"
	real_name = "Paradox Clone Camera"
	desc = "Something's pushing against the fabric of space-time."
	icon = 'icons/mob/silicon/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = FALSE
	invisibility = INVISIBILITY_OBSERVER
	see_invisible = SEE_INVISIBLE_LIVING
	layer = BELOW_MOB_LAYER
	// Pale green, bright enough to have good vision
	lighting_cutoff_red = 5
	lighting_cutoff_green = 35
	lighting_cutoff_blue = 20
	sight = SEE_SELF|SEE_THRU
	initial_language_holder = /datum/language_holder/universal

	var/freemove = TRUE
	var/freemove_end = 0
	var/freemove_end_timerid

	var/mob/living/paradox_target
	var/list/viewing_locations

	var/last_move_tick = 0
	var/move_delay = 1

/mob/camera/paradox/Initialize(mapload)
	.= ..()

	ADD_TRAIT(src, TRAIT_SIXTHSENSE, INNATE_TRAIT) //at least they'll have SOMEONE to talk to

	var/datum/atom_hud/my_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED ]
	my_hud.show_to(src)

	freemove_end = world.time + PREP_TIME
	freemove_end_timerid = addtimer(CALLBACK(src, PROC_REF(infect_random_patient_zero)), PREP_TIME, TIMER_STOPPABLE)

/mob/camera/paradox/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_warning("You have [DisplayTimeText(freemove_end - world.time)] to select your first host. Click on a human to select your host."))

#undef PREP_TIME
