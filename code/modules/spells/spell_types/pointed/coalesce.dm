/datum/action/cooldown/spell/pointed/coalesce
	name = "Coalesce Shadows"
	desc = "Coalesce the darkness into a thick black mist, destroying any light caught in the cloud. \
	Can be cast on ventilation openings to summon a larger-than-usual cloud of darkness, on a longer cooldown" //todo: figure out how to add longer cooldown
	button_icon = 'icons/effects/genetics.dmi'
	button_icon_state = "shadow_portal"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'
	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_CONJURATION
	cooldown_time = 20 SECONDS
	button_icon_state = "terrify"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cast_range = 7
	active_msg = "You prepare to conjure the shadows..."
	deactive_msg = "You decide not to conjure any shadows..."
	aim_assist = FALSE

/datum/action/cooldown/spell/pointed/coalesce/is_valid_target(atom/cast_on)
	if(istype(cast_on, /obj/machinery/atmospherics/components/unary)) //Move this to a static list of comparisons to a few different objects. Include maint steam vents and stuff.
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
	shadow_cloud.chemholder.add_reagent(/datum/reagent/coalesced_shadow, 20)
	if(istype(cast_on, /obj/machinery/atmospherics/components/unary)) //We have a bigger smoke plume when used on pipes
		cast_on.visible_message(span_warning("Shadows spill out from within [cast_on]!"))
		shadow_cloud.set_up(4, location = get_turf(cast_on))
	else
		shadow_cloud.set_up(1, location = get_turf(cast_on))

	shadow_cloud.start()
