/**
 * # Coalesce spell
 *
 * Releases a gas cloud containing coalesced shadows, which extinguishes any lights caught in it.
 *
 * When cast on a target atom in darkness, releases a small smoke cloud containing coalesced shadows.
 * Coalesced Shadow reagents have the Light Eater component, making the gas cloud a temporary obstacle
 * that combatants must avoid.
 *
 * This spell also works on some pieces of machinery, which produces a larger cloud on a longer cooldown.
 * While a specific theme for what this works on hasn't really been decided yet, the idea is for it to be
 * and emergency option for putting out an entire room.
 *
 */

/datum/action/cooldown/spell/pointed/coalesce
	name = "Coalesce Shadows"
	desc = "Coalesce the darkness into a thick black mist, destroying any light caught in the cloud. \
	Can be cast on ventilation openings to summon a larger-than-usual cloud of darkness, on a longer cooldown" //todo: figure out how to add longer cooldown
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
	///A list of ventilation sources, used for istype comparisons, that allow larger smoke conjurations.
	var/list/ventilation_sources = list(
			/obj/machinery/atmospherics/components/unary,
			/obj/structure/steam_vent,
			/obj/machinery/light,
	)

/datum/action/cooldown/spell/pointed/coalesce/New(Target)
	. = ..()

	ventilation_sources = typecacheof(ventilation_sources)

/datum/action/cooldown/spell/pointed/coalesce/is_valid_target(atom/cast_on)
	if(istype(cast_on, /obj/machinery/atmospherics/components/unary)) //Move this to a static list of comparisons to a few different objects. Include maint steam vents and stuff.
		if(istype(cast_on, /obj/machinery/atmospherics/components/unary))
			var/obj/machinery/atmospherics/components/unary/machinery = cast_on
			if(machinery.welded) //This SHOULD mean it will only work open vents/pumps.
				cast_on.balloon_alert(owner, "nowhere to manifest from!")
				return FALSE
		return TRUE //We don't run the light checks when cast on machinery, as it is meant to be an emergency option

	var/turf/open/turf_to_check = get_turf(cast_on)

	if(turf_to_check.get_lumcount() > 0.2)
		cast_on.balloon_alert(owner, "too bright!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/coalesce/cast(atom/cast_on)
	. = ..()

	//The plan here -- Move the cloud stuff to a different proc. Do a visual effect when used on the shadows to
	//telegraph the attack

	var/datum/effect_system/fluid_spread/smoke/chem/shadow_cloud = new
	shadow_cloud.chemholder.add_reagent(/datum/reagent/coalesced_shadow, 20)
	if(is_type_in_typecache(cast_on, ventilation_sources)) //We have a bigger smoke plume when used on pipes
		cast_on.visible_message(span_warning("Shadows billow out from within [cast_on]!")) //Make the message for on_expose light eater component to be silent
		shadow_cloud.set_up(3, location = get_turf(cast_on))
	else
		shadow_cloud.set_up(1, 1, location = get_turf(cast_on))

	shadow_cloud.start()
