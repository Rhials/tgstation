/obj/machinery/stewing_cauldron
	name = "stewing cauldron"
	desc = "A gigantic, cast-iron Lay-zee Chef brand soup cauldron. For when your company-catered lunches aren't bland and tasteless enough."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer_off"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	anchored = FALSE
	use_power = NO_POWER_USE

	///objects "inside" of the pot. Will be released on destruction (or if I decide to add some way of removing uncooked items from the pot)
	var/list/cooking_contents

/obj/machinery/stewing_cauldron/Initialize(mapload)
	. = ..()
	create_reagents(50, OPENCONTAINER)

/obj/machinery/stewing_cauldron/examine(mob/user)
	. = ..()
	if(!cooking_contents.len)
		. += "It appears to not be melting anything down right now."
	else
		. += "You can see something moving in the pot as it boils." //Make this show contents of pot and explain the yet-to-be-thought-of method of removing things from it

/obj/machinery/stewing_cauldron/Destroy()
	for(var/obj/item/food/ingredient in cooking_contents)
		igredient.forceMove(loc)
	. = ..()
