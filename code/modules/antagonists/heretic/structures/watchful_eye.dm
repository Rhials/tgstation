///Decoration for the cosmic heretic gate
///Its eye follows the closest player to it when activated

/obj/structure/watchful_eye
	name = "watchful eye"
	desc = "There's something out here with you, watching you drift through the inky blackness of the cosmos. \
		Truth be told, it's been watching you for longer than you know, but this is the closest look it's gotten so far."
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "cult_sense"
	base_icon_state = "cult_sense"
	light_power = 1
	anchored = TRUE
	density = TRUE
	///Who are we gazing upon?
	var/mob/living/our_target
	///Our rotational angle
	var/angle = 0

/obj/structure/watchful_eye/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/watchful_eye/process()
	if(!our_target)
		our_target = locate(/mob/living) in view(7, src)

	var/turf/target_turf = get_turf(our_target)
	var/turf/our_turf = get_turf(src)
	if(!target_turf || !our_turf || (target_turf.z != our_turf.z))
		our_target = null //We stop tracking our target because they're gone

	var/target_angle = get_angle(our_turf, target_turf)
	cut_overlays()
	var/difference = target_angle - angle
	angle = target_angle
	if(!difference)
		return
	var/matrix/final = matrix(transform)
	final.Turn(difference)
	animate(src, transform = final, time = 5, loop = 0)
