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
	var/list/cooking_contents = list()

/obj/machinery/stewing_cauldron/Initialize(mapload)
	. = ..()
	create_reagents(250, OPENCONTAINER | DRAINABLE)

/obj/machinery/stewing_cauldron/examine(mob/user)
	. = ..()
	if(!cooking_contents.len)
		. += "It appears to not be melting anything down right now."
	else
		. += "You can see something moving in the pot as it boils." //Make this show contents of pot and explain the yet-to-be-thought-of method of removing things from it

/obj/machinery/stewing_cauldron/Destroy()
	for(var/obj/item/food/ingredient in cooking_contents)
		ingredient.forceMove(loc)
	. = ..()

/obj/machinery/stewing_cauldron/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/stewing_cauldron/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/food))
		if(!do_after(user, 2 SECONDS, target = src))
			return
		dissolve(weapon)
	else if(istype(weapon, /obj/item/reagent_containers/glass))
		return
	else
		user.balloon_alert(user, "That's not edible!")

/**
 * handles moving reagents from food in the cauldron into the cauldron's reagent holder
 *
 * moves all reagents from an obj/item/food item into the pot, then deletes the food. Called after
 * Arguments:
 * * ingredient - the piece of food having its reagents transferred into the pot.
 */
/obj/machinery/stewing_cauldron/proc/dissolve(obj/item/food/ingredient)
	for(var/datum/reagent/ingredient_reagent in ingredient.reagents.reagent_list)
		ingredient.reagents.trans_to(reagents, ingredient.reagents.total_volume)
	visible_message(span_notice("[ingredient] sinks into the [name], melting into stew!"))
	playsound(src, 'sound/chemistry/heatdam.ogg', 25)
	qdel(ingredient)
