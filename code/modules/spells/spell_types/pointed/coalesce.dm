/datum/action/cooldown/spell/pointed/coalesce
	name = "Coalesce Shadows"
	desc = "Coalesce the darkness into a thick black mist, consuming any light caught in the cloud."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'
	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 30 SECONDS
	button_icon_state = "terrify"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	cast_range = 7
	active_msg = "You prepare to conjure the shadows..."
	deactive_msg = "You decide not to conjure any shadows..."

/datum/action/cooldown/spell/pointed/coalesce/is_valid_target(atom/cast_on)
	if(istype(/obj/machinery/atmospherics/components/unary, cast_on))
		var/obj/machinery/atmospherics/components/unary/machinery = cast_on
		if(machinery.welded) //This SHOULD mean it will only work open vents/pumps.
			cast_on.balloon_alert(owner, "nowhere to manifest!") //AWFUL message pls change
			return FALSE

	if(isopenturf(cast_on))
		var/turf/open/turf_to_check = cast_on
		if(turf_to_check.get_lumcount() > 0.2)
			cast_on.balloon_alert(owner, "too bright!")
			return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/coalesce/cast(atom/cast_on)
	. = ..()

	var/datum/effect_system/fluid_spread/smoke/chem/shadow_cloud = new
	shadow_cloud.chemholder.add_reagent(/datum/reagent/coalesced_shadow, 10)
	shadow_cloud.set_up(2, 1, get_turf(cast_on))
	shadow_cloud.start()
