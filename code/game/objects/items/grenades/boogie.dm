/obj/item/grenade/boogie
	name = "boogie brenade"
	icon_state = "emp"
	inhand_icon_state = "emp"

	var/duration = 30 SECONDS

/obj/item/grenade/boogie/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()

	do_sparks(rand(4, 7), FALSE, src)

	new /obj/machinery/jukebox/disco/boogie_ball(get_turf(src), duration)

	qdel(src)

/obj/machinery/jukebox/disco/boogie_ball //An invisible, intangible jukebox that manages dancing operations for about 10-ish seconds before wiping itself from existence
	name = "the localized spirit of dancing"
	desc = "You shouldn't be seeing this." //maybe make this just a floating disco ball, push ppl away on bump
	icon = 'icons/obj/boogie_ball.dmi'
	icon_state = "ball"
	anchored = TRUE

/obj/machinery/jukebox/disco/boogie_ball/Initialize(mapload, duration=10)
	. = ..()

	QDEL_IN(src, duration) //Cleans itself up after 10 seconds

	INVOKE_ASYNC(src, .proc/begin_playing)

/obj/machinery/jukebox/disco/boogie_ball/proc/begin_playing()
	//handle music playing here
	dance_setup()
	lights_spin()
