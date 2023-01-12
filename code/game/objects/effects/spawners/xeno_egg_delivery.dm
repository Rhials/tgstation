/obj/effect/spawner/xeno_egg_delivery
	name = "xeno egg delivery"
	icon = 'icons/mob/nonhuman-player/alien.dmi'
	icon_state = "egg_growing"
	var/announcement_time = 1200

/obj/effect/spawner/xeno_egg_delivery/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)

	new /obj/structure/alien/egg(T)
	new /obj/effect/temp_visual/gravpush(T)
	playsound(T, 'sound/items/party_horn.ogg', 50, TRUE, -1)

	message_admins("An alien egg has been delivered to [ADMIN_VERBOSEJMP(T)].")
	log_game("An alien egg has been delivered to [AREACOORD(T)]")
	var/message = "Attention [station_name()], we have entrusted you with a research specimen in [get_area_name(T, TRUE)]. Remember to follow all safety precautions when dealing with the specimen."
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(print_command_report), message), announcement_time))

/obj/structure/alien/egg/delivery
	name = "egg"
	desc = "A large mottled egg, sent as a part of a Xenobiological Research Initiative by the higher-ups. Handle with care!"
	icon_state = "egg_growing" //NEW SPRITES pls
	base_icon_state = "egg"
	max_integrity = 300

/obj/structure/alien/egg/delivery/Initialize(mapload)
	. = ..()

	SScommunications.xenomorph_delivery_poi = src // Begin the tracking chain

	child = null //destroy the child
	child = new/obj/item/clothing/mask/facehugger/delivery(src) //make a new SPECIAL one

/obj/item/clothing/mask/facehugger/delivery
	name = "xenobiological specimen"
	desc = "Produces a specimen after a brief incubation period. Monkey not included. Some assembly required."
	icon_state = "egg_growing" //NEW SPRITES pls

/obj/item/clothing/mask/facehugger/delivery/Impregnate(mob/living/target)
	. = ..()

	var/obj/item/organ/internal/body_egg/alien_embryo/special_egg = locate(/obj/item/organ/internal/body_egg/alien_embryo) in target
	SScommunications.xenomorph_delivery_poi = special_egg
