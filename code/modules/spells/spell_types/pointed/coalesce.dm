/datum/action/cooldown/spell/pointed/coalesce
	name = "Coalesce Shadows"
	desc = "Coalesce the darkness into a thick black mist, destroying any light caught in the cloud."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'
	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_CONJURATION
	cooldown_time = 15 SECONDS
	button_icon_state = "terrify"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	cast_range = 7
	active_msg = "You prepare to conjure the shadows..."
	deactive_msg = "You decide not to conjure any shadows..."
	aim_assist = FALSE

/datum/action/cooldown/spell/pointed/coalesce/is_valid_target(atom/cast_on)
	if(istype(/obj/machinery/atmospherics/components/unary, cast_on))
		var/obj/machinery/atmospherics/components/unary/machinery = cast_on
		if(machinery.welded) //This SHOULD mean it will only work open vents/pumps.
			cast_on.balloon_alert(owner, "nowhere to manifest from!")
			return FALSE
		else
			return TRUE //We don't run the light checks when cast on unary machinery

	var/turf/open/turf_to_check = get_turf(cast_on)

	if(turf_to_check.get_lumcount() > 0.2)
		cast_on.balloon_alert(owner, "too bright!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/coalesce/cast(atom/cast_on)
	. = ..()

	var/datum/effect_system/fluid_spread/smoke/chem/shadow_cloud = new
	shadow_cloud.chemholder.add_reagent(/datum/reagent/coalesced_shadow, 25)
	if(istype(/obj/machinery/atmospherics/components/unary, cast_on)) //We have a bigger smoke plume when used on pipes
		cast_on.visible_message(span_warning("Shadows spill out from within [cast_on]!"))
		shadow_cloud.set_up(4, location = get_turf(cast_on))
	else
		shadow_cloud.set_up(2, location = get_turf(cast_on))

	shadow_cloud.start()
