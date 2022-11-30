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

	/// Multiplier for calculating move delay. Higher means slower, lower means faster
	var/move_speed_multiplier = 1
	/// Is your movement on cooldown? Used to manage whether or not relaymove actually does anything.
	var/move_delay = FALSE
	/// Should the box make the occupant(s) perform an alert animation upon bein opened?
	var/should_alert = TRUE

	/// Cooldown controlling when the box can trigger the Metal Gear Solid-style '!' alert.
	COOLDOWN_DECLARE(alert_cooldown)

	/// How much time must pass before the box can trigger the next Metal Gear Solid-style '!' alert.
	var/time_between_alerts = 60 SECONDS

/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(opened || move_delay || user.incapacitated() || !isturf(loc) || !has_gravity(loc))
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
		if(opened)
			to_chat(user, span_alert("The [src] needs to be closed before you can convert it!"))
			return

		user.visible_message(span_notice("[user] begins spraying the [src] with the [W]."),
			span_notice("You begin spraying down the [src] with the [W]."),
			span_notice("You hear the sound of someone frantically spraying something."),
		)

		playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)

		if(do_after(user, 6 SECONDS, src))
			playsound(user.loc, 'sound/effects/spray2.ogg', 5, TRUE, 5)
			var/obj/new_car = new /obj/structure/closet/cardboard/car(get_turf(src))
			user.visible_message(span_notice("[user] finishes applying the decals to [W], transforming it into a [new_car]!"))
			qdel(src)
	return

/obj/structure/closet/cardboard/proc/ResetMoveDelay()
	move_delay = FALSE

/obj/structure/closet/cardboard/open(mob/living/user, force = FALSE)
	var/do_alert = (COOLDOWN_FINISHED(src, alert_cooldown) && (locate(/mob/living) in contents))

	if(!do_alert)
		return ..()

	// Cache the list before we open the box.
	var/list/alerted = viewers(7, src)

	// There are no mobs to alert?
	if(!(locate(/mob/living) in alerted))
		return ..()

	. = ..()

	// Box didn't open?
	if(!.)
		return


	if(should_alert)
		COOLDOWN_START(src, alert_cooldown, time_between_alerts)

		for(var/mob/living/alerted_mob in alerted)
			if(alerted_mob.stat == CONSCIOUS)
				if(!alerted_mob.incapacitated(IGNORE_RESTRAINTS))
					alerted_mob.face_atom(src)
				alerted_mob.do_alert_animation()

		playsound(loc, 'sound/machines/chime.ogg', 50, FALSE, -5)

/// Does the MGS ! animation
/atom/proc/do_alert_animation()
	var/image/alert_image = image('icons/obj/storage/closet.dmi', src, "cardboard_special", layer+1)
	SET_PLANE_EXPLICIT(alert_image, ABOVE_LIGHTING_PLANE, src)
	flick_overlay_view(alert_image, 0.8 SECONDS)
	alert_image.alpha = 0
	animate(alert_image, pixel_z = 32, alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)
	// We use this list to update plane values on parent z change, which is why we need the timer too
	// I'm sorry :(
	LAZYADD(update_on_z, alert_image)
	addtimer(CALLBACK(src, PROC_REF(forget_alert_image), alert_image), 0.8 SECONDS)

/atom/proc/forget_alert_image(image/alert_image)
	LAZYREMOVE(update_on_z, alert_image)

/obj/structure/closet/cardboard/metal
	name = "large metal box"
	desc = "THE COWARDS! THE FOOLS!"
	icon_state = "metalbox"
	max_integrity = 500
	mob_storage_capacity = 5
	resistance_flags = NONE
	move_speed_multiplier = 2
	cutting_tool = /obj/item/weldingtool
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	material_drop = /obj/item/stack/sheet/plasteel

/obj/structure/closet/cardboard/car //Box car. Use a special spraycan (via cargo or elsewhere, figure this out later) to spray decals to make it look like a car.
	name = "cardboard box box-car car" //Iron out the pun later
	desc = "A cardboard box, painted to distantly resemble a car. How can the driver even see where they're going?"
	icon_state = "boxcar"
	mob_storage_capacity = 4 //One door, four seats. Perfect for taxi services.
	move_speed_multiplier = 0.5
	COOLDOWN_DECLARE(move_sound_cooldown)
	should_alert = FALSE

/obj/structure/closet/cardboard/car/relaymove(mob/living/user, direction)
	. = ..()

	if(COOLDOWN_FINISHED(src, move_sound_cooldown))
		COOLDOWN_START(src, move_sound_cooldown, 2 SECONDS)
		playsound(get_turf(src), 'sound/vehicles/carrev.ogg', 100, TRUE)

/obj/structure/closet/cardboard/car/Bump(atom/A) //Now you dont have to pop out every time you want to open a door
	. = ..()

	if(istype(A, /obj/machinery/door))
		var/obj/machinery/door/bumped_door = A
		for(var/mob/occupant as anything in contents)
			if(bumped_door.try_safety_unlock(occupant))
				return
			bumped_door.bumpopen(occupant)

/obj/item/boxcar_spraycan //absolutely horrid item name
	name = "box-car spraycan"
	desc = "A Donk Co. brand Cardboard Box to Cardboard Box-Car Car Conversion Kit. Can be used to convert a cardboard box into a fully functional car, provided you apply the decals correctly." //You cannot apply them correctly
	icon = 'icons/obj/art/crayons.dmi'
	icon_state = "boxcar_can"
	inhand_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_COMMAND * 3
