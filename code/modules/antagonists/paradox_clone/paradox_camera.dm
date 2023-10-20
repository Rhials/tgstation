#define PREP_TIME 5 MINUTES

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
	var/mob/living/paradox_target
	var/list/viewing_locations = list()

/mob/camera/paradox/Initialize(mapload)
	.= ..()

	ADD_TRAIT(src, TRAIT_SIXTHSENSE, INNATE_TRAIT)

	viewing_locations += pick(GLOB.generic_maintenance_landmarks)
	viewing_locations += pick(GLOB.generic_maintenance_landmarks)
	viewing_locations += pick(GLOB.generic_maintenance_landmarks) //3, my favorite number. Too short to put in a loop, too long to write out normally without looking weird.

	var/datum/atom_hud/my_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	my_hud.show_to(src)

	addtimer(CALLBACK(src, PROC_REF(deploy_clone)), PREP_TIME, TIMER_STOPPABLE)

/mob/camera/paradox/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_warning("You have [DisplayTimeText(PREP_TIME)] to make your plan and select a spawn location."))

/mob/camera/paradox/proc/deploy_clone(delivery_turf)
	var/datum/antagonist/paradox_clone/clone_datum = src.mind.has_antag_datum(/datum/antagonist/paradox_clone)
	if(delivery_turf)
		clone_datum.make_clone(delivery_turf)
	else
		clone_datum.make_clone(pick(viewing_locations))
	return

#undef PREP_TIME
