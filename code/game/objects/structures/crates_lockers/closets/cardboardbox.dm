/obj/structure/closet/cardboard
	name = "large cardboard box"
	desc = "Just a box..."
	icon_state = "cardboard"
	mob_storage_capacity = 1
	resistance_flags = FLAMMABLE
	max_integrity = 70
	integrity_failure = 0
	can_weld_shut = 0
	cutting_tool = /obj/item/wirecutters
	material_drop = /obj/item/stack/sheet/cardboard
	delivery_icon = "deliverybox"
	anchorable = FALSE
	open_sound = 'sound/machines/cardboard_box.ogg'
	close_sound = 'sound/machines/cardboard_box.ogg'
	open_sound_volume = 35
	close_sound_volume = 35
	has_closed_overlay = FALSE
	door_anim_time = 0 // no animation
	can_install_electronics = FALSE
	paint_jobs = null

	/// Cooldown controlling when the box can trigger the Metal Gear Solid-style '!' alert.
	COOLDOWN_DECLARE(alert_cooldown)
	/// How much time must pass before the box can trigger the next Metal Gear Solid-style '!' alert.
	var/time_between_alerts = 60 SECONDS
	/// List of viewers around the box
	var/list/alerted
	/// How fast a mob can move inside this box
	var/move_speed_multiplier = 1
	/// If the speed multiplier should be applied to mobs inside this box
	var/move_delay = FALSE
	/// Should the box make the occupant(s) perform an alert animation upon being opened?
	var/should_alert = TRUE
	/// Can we be converted into a box-car?
	var/car_convertible = TRUE

/obj/structure/closet/cardboard/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, PROC_REF(on_speed_potioned))

/obj/structure/closet/cardboard/proc/on_speed_potioned(datum/source)
	SIGNAL_HANDLER
	move_speed_multiplier *= 2

/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(opened || move_delay || user.incapacitated || !isturf(loc) || !has_gravity(loc))
		return
	move_delay = TRUE
	var/oldloc = loc
	try_step_multiz(direction);
	if(oldloc != loc)
		addtimer(CALLBACK(src, PROC_REF(ResetMoveDelay)), CONFIG_GET(number/movedelay/walk_delay) * move_speed_multiplier)
	else
		move_delay = FALSE

/obj/structure/closet/cardboard/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/boxcar_spraycan))
		if(!car_convertible)
			balloon_alert(user, "cannot be painted!")
			return

		var/obj/item/boxcar_spraycan/spraycan = W
		if(opened)
			balloon_alert(user, "close the box first!")
			return

		if(!spraycan.worthiness_check(user, TRUE))
			balloon_alert(user, "the nozzle doesn't budge!")
			return

		if(spraycan.used)
			balloon_alert(user, "can is empty!")
			return

		balloon_alert_to_viewers("spraying...")

		if(do_after(user, 6 SECONDS, src))
			playsound(get_turf(src), 'sound/effects/spray2.ogg', 50, TRUE)
			var/obj/structure/closet/cardboard/car/new_boxcar = new (get_turf(src))
			spraycan.used = TRUE
			spraycan.icon_state = "boxcar_can_used"
			new_boxcar.balloon_alert_to_viewers("conversion complete!")
			qdel(src)
	return

/obj/structure/closet/cardboard/proc/ResetMoveDelay()
	move_delay = FALSE

/obj/structure/closet/cardboard/before_open(mob/living/user, force)
	. = ..()
	if(!.)
		return FALSE

	LAZYINITLIST(alerted)
	var/do_alert = (COOLDOWN_FINISHED(src, alert_cooldown) && (locate(/mob/living) in contents))
	if(!do_alert)
		return TRUE

	alerted.Cut() // just in case we runtimed and the list didn't get cleared in after_open
	// Cache the list before we open the box.
	for(var/mob/living/alerted_mob in viewers(7, src))
		alerted += alerted_mob

	return TRUE

/obj/structure/closet/cardboard/after_open(mob/living/user, force)
	. = ..()
	if(!length(alerted))
		return

	if(should_alert)
		COOLDOWN_START(src, alert_cooldown, time_between_alerts)
		for(var/mob/living/alerted_mob as anything in alerted)
			if(alerted_mob.stat != CONSCIOUS || alerted_mob.is_blind())
				continue
			if(!INCAPACITATED_IGNORING(alerted_mob, INCAPABLE_RESTRAINTS))
				alerted_mob.face_atom(src)
			alerted_mob.do_alert_animation()
		alerted.Cut()
		playsound(loc, 'sound/machines/chime.ogg', 50, FALSE, -5)

/// Does the MGS ! animation
/atom/proc/do_alert_animation()
	var/mutable_appearance/alert = mutable_appearance('icons/obj/storage/closet.dmi', "cardboard_special")
	SET_PLANE_EXPLICIT(alert, ABOVE_LIGHTING_PLANE, src)
	var/atom/movable/flick_visual/exclamation = flick_overlay_view(alert, 1 SECONDS)
	exclamation.alpha = 0
	exclamation.pixel_x = -pixel_x
	animate(exclamation, pixel_z = 32, alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)
	// We use this list to update plane values on parent z change, which is why we need the timer too
	// I'm sorry :(
	LAZYADD(update_on_z, exclamation)
	// Intentionally less time then the flick so we don't get weird shit
	addtimer(CALLBACK(src, PROC_REF(forget_alert), exclamation), 0.8 SECONDS, TIMER_CLIENT_TIME)

/atom/proc/forget_alert(atom/movable/flick_visual/exclamation)
	LAZYREMOVE(update_on_z, exclamation)

/obj/structure/closet/cardboard/metal
	name = "large metal box"
	desc = "THE COWARDS! THE FOOLS!"
	icon_state = "metalbox"
	max_integrity = 500
	mob_storage_capacity = 5
	resistance_flags = NONE
	move_speed_multiplier = 2
	cutting_tool = /obj/item/weldingtool
	open_sound = 'sound/machines/crate/crate_open.ogg'
	close_sound = 'sound/machines/crate/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	material_drop = /obj/item/stack/sheet/plasteel
	car_convertible = FALSE

/obj/structure/closet/cardboard/car
	name = "cardboard box-car"
	desc = "A cardboard box, painted to distantly resemble a car. How can the driver even see where they're going?"
	icon_state = "boxcar"
	mob_storage_capacity = 4 //One door, four seats. Perfect for taxi services.
	move_speed_multiplier = 0.5
	COOLDOWN_DECLARE(move_sound_cooldown)
	should_alert = FALSE
	car_convertible = FALSE

/obj/structure/closet/cardboard/car/relaymove(mob/living/user, direction)
	. = ..()

	if(COOLDOWN_FINISHED(src, move_sound_cooldown))
		COOLDOWN_START(src, move_sound_cooldown, 2 SECONDS)
		playsound(get_turf(src), 'sound/vehicles/carrev.ogg', 100, TRUE)

/obj/structure/closet/cardboard/car/Bump(atom/A) //So you dont have to pop out every time you want to open a door
	. = ..()

	if(istype(A, /obj/machinery/door))
		var/obj/machinery/door/bumped_door = A
		for(var/mob/occupant as anything in contents)
			if(bumped_door.try_safety_unlock(occupant))
				return
			bumped_door.bumpopen(occupant)

/obj/structure/closet/cardboard/car/close(mob/living/user)
	. = ..()

	for(var/mob/living/carbon/human/passenger in contents)
		if(passenger.stat == CONSCIOUS) //If you can't contribute to pushing around the box, you can't speed it up
			move_speed_multiplier -= 0.05 //multi-man taxi action

/obj/structure/closet/cardboard/car/open(mob/living/user, force, special_effects = TRUE)
	. = ..()

	move_speed_multiplier = initial(move_speed_multiplier)

/obj/item/boxcar_spraycan
	name = "box-car spraycan"
	desc = "A Decroux brand box-car decal spraycan. The nozzle is secured by a cutting edge electronic lock. Used to convert a large enough box into a fully functional car. It looks like there's a label on the back..."
	icon = 'icons/obj/art/crayons.dmi'
	icon_state = "boxcar_can"
	inhand_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_CREW * 5
	///Prevents spamming the confirmation/denial message and noise
	COOLDOWN_DECLARE(confirmation_cooldown)
	///Whether or not this has been used to paint a box already.
	var/used = FALSE

/obj/item/boxcar_spraycan/examine(mob/user)
	. = ..()
	if(used)
		. += span_notice("It feels considerably lighter than it should be. This can is probably empty...")

/obj/item/boxcar_spraycan/examine_more(mob/user)
	. = ..()

	. += span_notice("The label on the back reads: 'Thank you for purchasing a Decroux Box-Car Spraycan. ") //rewrite all of this omg
	. += span_notice("The spray nozzle will be electronically locked unless used by someone adhering to a vow of silence. ")
	. += span_notice("Those who are bound to silence through other means may also qualify, due to their innate closeness to the spirit of mimery. ")
	. += span_notice("This is a precaution to ensure excellence in mimery, and that a mockery isn't made of our craft. ")
	. += span_notice("Lastly -- <i>No clowns.</i>'")


/obj/item/boxcar_spraycan/attack_self(mob/living/user, direction) //Used to test if you're "worthy" without using it directly on a box.
	. = ..()

	if(COOLDOWN_FINISHED(src, confirmation_cooldown))
		COOLDOWN_START(src, confirmation_cooldown, 3 SECONDS)
		worthiness_check(user)

/obj/item/boxcar_spraycan/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	balloon_alert(user, "zzzt...")
	obj_flags |= EMAGGED

/**
 * Used to check whether or not a user is "worthy" of using a boxcar spraycan
 *
 * Handles the checks for whether or not a given user is allowed to use a boxcar spraycan on a box.
 * If the user is mute, miming, or has emagged the can, it will give feedback that the spray nozzle functions and return true.
 * Otherwise, the user is denied, and may be shocked if they're the clown.
 *
 * Arguments:
 * * user - The mob whose worthiness is being tested
 * * silent - Will the check make noise and a balloon alert?
 */

/obj/item/boxcar_spraycan/proc/worthiness_check(mob/living/user, silent = FALSE)
	if(HAS_MIND_TRAIT(user, TRAIT_MIMING) || HAS_TRAIT(user, TRAIT_MUTE) || obj_flags & EMAGGED) //Mimes n' mutes, unless its emagged
		if(!silent)
			balloon_alert(user, "the nozzle moves!")
			playsound(get_turf(src), 'sound/machines/ping.ogg', 35, TRUE)
		return TRUE
	else
		if(!silent)
			balloon_alert(user, "the nozzle doesn't budge!")
			playsound(get_turf(src), 'sound/machines/buzz/buzz-sigh.ogg', 35, TRUE)
		if(is_clown_job(user.mind?.assigned_role)) //You had your warning, clown //add more clown states here (wizard convert, etc)
			to_chat(user, span_alert("\The nozzle on the [src] sends a jolt of electricity through your hand! Distant, mocking French laughter echoes in the back of your mind..."))
			user.electrocute_act(5, src, flags = SHOCK_SUPPRESS_MESSAGE)
	return FALSE
