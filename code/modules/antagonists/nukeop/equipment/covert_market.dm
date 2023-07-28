/obj/item/covert_market
	name = "Covert Operations Market Uplink"
	desc = "An uplink that connects you to an underground network of black-market equipment smugglers. \
		These dealers value their secrecy, and will not do business if your operative team has done anything too conspicuous (like delcaring war)."
	icon = 'icons/obj/device.dmi'
	icon_state = "covert_uplink" //This has associated overlay sprites you should use
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	///Has this device been activated?
	var/activated = FALSE

/obj/item/covert_market/Initialize(mapload)
	. = ..()
	if((world.time - SSticker.round_start_time > CHALLENGE_TIME_LIMIT) && !GLOB.war_declared)
		unlock_market(FALSE) ///Instantly opens the bargain market for midround nukies.
	else
		update_appearance(UPDATE_OVERLAYS)
		addtimer(CALLBACK(src, PROC_REF(unlock_market)), CHALLENGE_TIME_LIMIT - world.time + SSticker.round_start_time)

/obj/item/covert_market/examine(mob/user)
	. = ..()
	if(GLOB.war_declared)
		. += span_notice("<b>This uplink has been locked and rendered inaccessible due to the recent declaration of war.</B>")
	else
		if(!activated)
			. += span_notice("<b>You can gain access to the market early by using your war declaration device on this uplink.</B>")

/obj/item/covert_market/attack_self(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(GLOB.war_declared)
		to_chat(user, span_notice("An error message flashes across the screen. This device cannot be used while at war!"))
		return

	if(!activated)
		to_chat(user, span_notice("An error message flashes across the screen. This uplink is still being prepared!"))

/obj/item/covert_market/attackby(obj/item/attacking_item, mob/user, params)
	..()

	if(istype(attacking_item, /obj/item/nuclear_challenge))
		if(GLOB.war_declared)
			balloon_alert(user, "war has already been declared!")
			return
		if(activated)
			balloon_alert(user, "market already unlocked!")
			return
		var/are_you_sure = tgui_alert(usr, "Are you sure you wish to unlock the [src]? You will not be able to declare war if you do!", "Reject war?", list("Yes", "No"))
		if(are_you_sure != "Yes")
			return
		do_sparks(2, source = attacking_item)
		qdel(attacking_item)
		unlock_market(FALSE)
		balloon_alert_to_viewers("market unlocked!")

///When we know we aren't going to war, we make the market available.
/obj/item/covert_market/proc/unlock_market(time_expired = TRUE)
	if(QDELETED(src))
		return
	if(activated)
		return
	if(GLOB.war_declared) //Updates to the "rejected" overlay
		update_appearance(UPDATE_OVERLAYS)
		return

	var/datum/component/uplink/new_uplink =	AddComponent(\
		/datum/component/uplink, \
		owner = src, \
		lockable = FALSE, \
		enabled = TRUE, \
		uplink_flag = NONE, \
		starting_tc = 0, \
		uplink_handler_override = null, \
	)

	var/list/batch_uplink_offers = list()
	for(var/datum/uplink_item/item as anything in SStraitor.uplink_items)
		if(item.item && !item.cant_discount && (item.purchasable_from & UPLINK_NUKE_OPS) && item.cost >= COVERT_ORIGINAL_PRICE_MINIMUM && item.cost <= COVERT_ORIGINAL_PRICE_MAXIMUM)
			batch_uplink_offers += item

	new_uplink.uplink_handler.extra_purchasable += create_batch_sales(COVERT_BATCH_QUANTITY, /datum/uplink_category/batch_discounts, 1, batch_uplink_offers)

	if(time_expired)
		say("The deadline for launching a major operation has passed. Access to the covert discount market has been approved. Happy shopping!")

	activated = TRUE
	update_appearance(UPDATE_OVERLAYS)

/// Creates "batch sales" of nukie items, wherein a large discount is offered, however a high minimum of the item MUST be purchased, all at once.
/// Takes an average discount (sometimes a big discount) and adds a 1.1-1.5x multiplier to it, capped at 90% off.
/obj/item/covert_market/proc/create_batch_sales(sale_count, datum/uplink_category/category, limited_stock, list/sale_items)
	var/list/sales = list()
	var/list/sale_items_copy = sale_items.Copy()
	for (var/i in 1 to sale_count)
		var/datum/uplink_item/taken_item = pick_n_take(sale_items_copy)
		var/datum/uplink_item/uplink_item = new taken_item.type()

		var/batch_size = rand(4, 7)

		if(prob(15))
			batch_size = rand(11, 15)

		var/discount_size = TRAITOR_DISCOUNT_AVERAGE

		if(prob(20))
			discount_size = TRAITOR_DISCOUNT_BIG

		///We grab the item's discount value and add a multiplier, rather than just generating a random discount amount.
		///If something has a reduced discount value (such as the desword), the batch discount will respect this.
		var/discount = uplink_item.get_discount_value(discount_size)
		discount *= rand(110, 150) / 100

		discount = min(discount, 0.90) //But let's not get TOO crazy (like if we get a really high multiplier + big discount).

		uplink_item.limited_stock = limited_stock
		uplink_item.category = category
		uplink_item.cost = round((taken_item.cost * batch_size) * discount)
		uplink_item.name += " -- Buy [batch_size], get [round(discount * 100)]% off!"
		uplink_item.desc = "A [pick("bargain", "batch", "marked-down", "discounted", "cheap", "surplus", "budget", "affordable", "economy")] order of [taken_item.name]s. Must be purchased in a batch of [batch_size] units. Original unit price: [taken_item.cost] TC. Discounted unit price: [round(uplink_item.cost / batch_size)] TC. This surplus package will save you [(taken_item.cost * batch_size) - (uplink_item.cost)] TC! "
		uplink_item.desc += pick(
			"Why pass up this incredible deal?",
			"BUY NOW!!!!!",
			"An absolute firesale!",
			"You'd have to be a real MORON not to buy this one!",
			"This one's special, buy it now!",
			"Those idiots won't know what hit them!",
			"Show 'em who's boss!",
			"You ain't gonna see a deal like this again!",
			"Buy now or SUFFER THE CONSEQUENCES.",
			"Buy now and get ABSOLUTELY NOTHING extra!",
			"If you don't buy this, you'll lose!",
			"This deal is extra special, don't miss it!",
		)
		uplink_item.item = taken_item.item
		uplink_item.item_count = batch_size

		sales += uplink_item
	return sales

/obj/item/covert_market/update_overlays()
	. = ..()
	if(activated)
		. += "uplink_overlay_active"
	else
		if(GLOB.war_declared)
			. += "uplink_overlay_war"
		else
			. += "uplink_overlay_pending"
