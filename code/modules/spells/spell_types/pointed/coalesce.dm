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
	Can be cast on ventilation openings or lights to summon a larger-than-usual cloud of darkness, on a longer cooldown."
	button_icon_state = "shadow_portal"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'
	school = SCHOOL_CONJURATION
	cooldown_time = 1 SECONDS //DEBUG VALUE PLS FIX
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cast_range = 7
	active_msg = "You prepare to conjure the shadows..."
	deactive_msg = "You decide not to conjure any shadows..."
	aim_assist = FALSE
	///A list of sources to spawn larger plumes of shadows from.
	var/list/shadow_sources = list(
			/obj/machinery/atmospherics/components/unary,
			/obj/structure/steam_vent,
			/obj/machinery/light,
	)
	///Do we do an extended cooldown (for casting on machinery).
	var/extended_cooldown = FALSE

/datum/action/cooldown/spell/pointed/coalesce/New(Target)
	. = ..()

	shadow_sources = typecacheof(shadow_sources)

/datum/action/cooldown/spell/pointed/coalesce/is_valid_target(atom/cast_on)
	if(is_type_in_typecache(cast_on, shadow_sources))
		if(istype(cast_on, /obj/machinery/atmospherics/components/unary))
			var/obj/machinery/atmospherics/components/unary/machinery = cast_on
			if(machinery.welded) //This SHOULD mean it will only work open vents/pumps.
				cast_on.balloon_alert(owner, "nowhere to manifest from!")
				return FALSE
		return TRUE //We don't run the light checks when cast on machinery, meaning it can be used to completely put out smaller rooms.

	if(ismachinery(cast_on)) //If it is any other piece of machinery, we give an alert that the machinery is invalid
		cast_on.balloon_alert(owner, "this machine won't work!") //...But we don't return false, because we still want to attempt to make a plume if we're targetting in the dark
	//The message shows up alongside the too bright message (fix pls)
	var/turf/open/turf_to_check = get_turf(cast_on)

	if(turf_to_check.get_lumcount() > 0.2)
		cast_on.balloon_alert(owner, "too bright!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/coalesce/cast(atom/cast_on)
	. = ..()

	//The plan here -- Move the cloud stuff to a different proc on an addtimer. Do a visual effect when used on the shadows to
	//telegraph the attack

	if(is_type_in_typecache(cast_on, shadow_sources)) //Summon a shorter-lasting, larger, thinner smoke cloud.
		var/datum/effect_system/fluid_spread/smoke/chem/quick/shadow_cloud = new
		shadow_cloud.chemholder.add_reagent(/datum/reagent/coalesced_shadow, 50)
		cast_on.visible_message(span_warning("[owner] summons a plume of darkness from within [cast_on]!"))
		shadow_cloud.set_up(4, location = get_turf(cast_on))
		shadow_cloud.start()
		extended_cooldown = TRUE
	else //Summon a longer-lasting, smaller, thicker cloud after a brief telegraph.
		var/datum/effect_system/fluid_spread/smoke/chem/thick/shadow_cloud = new
		shadow_cloud.chemholder.add_reagent(/datum/reagent/coalesced_shadow, 50)
		shadow_cloud.set_up(1, 3, location = get_turf(cast_on))
		shadow_cloud.start()

/datum/action/cooldown/spell/pointed/coalesce/StartCooldownSelf(override_cooldown_time)
	if(extended_cooldown)
		override_cooldown_time = 45 //DOES NOT WORK RIGHT NOW
		extended_cooldown = FALSE

	..()
