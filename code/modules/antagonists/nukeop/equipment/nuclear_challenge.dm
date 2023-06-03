#define CHALLENGE_TELECRYSTALS 280
#define CHALLENGE_TIME_LIMIT (5 MINUTES)
#define CHALLENGE_MIN_PLAYERS 1 //DEBUG PLS FIX
#define CHALLENGE_SHUTTLE_DELAY (25 MINUTES) // 25 minutes, so the ops have at least 5 minutes before the shuttle is callable.
///How many batch discounts do we give if we choose not to go to war.
#define COVERT_BATCH_QUANTITY 6
///The minimum cost of an item to be put into a discount batch.
#define COVERT_ORIGINAL_PRICE_MINIMUM 7
///The maximum cost of an item to be put into a discount batch, to prevent things from being prohibitively expensive (affordable on a non-war budget).
#define COVERT_ORIGINAL_PRICE_MAXIMUM 55

GLOBAL_LIST_EMPTY(jam_on_wardec)

/obj/item/nuclear_challenge
	name = "Declaration of War (Challenge Mode)"
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	desc = "Use to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
			Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
			Must be used within five minutes, or your benefactors will lose interest."
	var/declaring_war = FALSE
	var/uplink_type = /obj/item/uplink/nuclear
	///This war declaration device's associated team.
	var/datum/team/nuclear/nukie_team

/obj/item/nuclear_challenge/Initialize(mapload, our_team)
	. = ..()
	nukie_team = our_team
	if(world.time - SSticker.round_start_time > CHALLENGE_TIME_LIMIT)
		on_war_rejection() ///Instantly opens the bargain market for midround nukies.
	else
		addtimer(CALLBACK(src, PROC_REF(on_war_rejection)), CHALLENGE_TIME_LIMIT) //We open up the discount batch market automatically if not done so deliberately.

/obj/item/nuclear_challenge/attack_self(mob/living/user)
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = tgui_alert(user, "Consult your team carefully before you declare war on [station_name()]. Are you sure you want to alert the enemy crew? You have [DisplayTimeText(CHALLENGE_TIME_LIMIT - world.time - SSticker.round_start_time)] to decide.", "Declare war?", list("Yes", "No"))
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure != "Yes")
		to_chat(user, span_notice("On second thought, the element of surprise isn't so bad after all."))
		return

	var/war_declaration = "A syndicate fringe group has declared their intent to utterly destroy [station_name()] with a nuclear device, and dares the crew to try and stop them."

	declaring_war = TRUE
	var/custom_threat = tgui_alert(user, "Do you want to customize your declaration?", "Customize?", list("Yes", "No"))
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(custom_threat == "Yes")
		declaring_war = TRUE
		war_declaration = tgui_input_text(user, "Insert your custom declaration", "Declaration", multiline = TRUE, encode = FALSE)
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return

	war_was_declared(user, memo = war_declaration)

///Admin only proc to bypass checks and force a war declaration. Button on antag panel.
/obj/item/nuclear_challenge/proc/force_war()
	var/are_you_sure = tgui_alert(usr, "Are you sure you wish to force a war declaration?", "Declare war?", list("Yes", "No"))

	if(are_you_sure != "Yes")
		return

	var/war_declaration = "A syndicate fringe group has declared their intent to utterly destroy [station_name()] with a nuclear device, and dares the crew to try and stop them."

	var/custom_threat = tgui_alert(usr, "Do you want to customize the declaration?", "Customize?", list("Yes", "No"))

	if(custom_threat == "Yes")
		war_declaration = tgui_input_text(usr, "Insert your custom declaration", "Declaration", multiline = TRUE, encode = FALSE)

	if(!war_declaration)
		to_chat(usr, span_warning("Invalid war declaration."))
		return

	war_was_declared(memo = war_declaration)

/obj/item/nuclear_challenge/proc/war_was_declared(mob/living/user, memo)
	priority_announce(memo, title = "Declaration of War", sound = 'sound/machines/alarm.ogg', has_important_message = TRUE)
	if(user)
		to_chat(user, "You've attracted the attention of powerful forces within the syndicate. \
			A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")

	distribute_tc()
	CONFIG_SET(number/shuttle_refuel_delay, max(CONFIG_GET(number/shuttle_refuel_delay), CHALLENGE_SHUTTLE_DELAY))
	SSblackbox.record_feedback("amount", "nuclear_challenge_mode", 1)

	for(var/obj/item/circuitboard/computer/syndicate_shuttle/board as anything in GLOB.syndicate_shuttle_boards)
		board.challenge = TRUE

	for(var/obj/machinery/computer/camera_advanced/shuttle_docker/dock as anything in GLOB.jam_on_wardec)
		dock.jammed = TRUE

	qdel(src)

/obj/item/nuclear_challenge/proc/distribute_tc()
	var/list/orphans = list()
	var/list/uplinks = list()

	for (var/datum/mind/M in get_antag_minds(/datum/antagonist/nukeop))
		if (iscyborg(M.current))
			continue
		var/datum/component/uplink/uplink = M.find_syndicate_uplink()
		if (!uplink)
			orphans += M.current
			continue
		uplinks += uplink

	var/tc_to_distribute = CHALLENGE_TELECRYSTALS
	var/tc_per_nukie = round(tc_to_distribute / (length(orphans)+length(uplinks)))

	for (var/datum/component/uplink/uplink in uplinks)
		uplink.add_telecrystals(tc_per_nukie)
		tc_to_distribute -= tc_per_nukie

	for (var/mob/living/L in orphans)
		var/TC = new /obj/item/stack/telecrystal(L.drop_location(), tc_per_nukie)
		to_chat(L, span_warning("Your uplink could not be found so your share of the team's bonus telecrystals has been bluespaced to your [L.put_in_hands(TC) ? "hands" : "feet"]."))
		tc_to_distribute -= tc_per_nukie

	if (tc_to_distribute > 0) // What shall we do with the remainder...
		for (var/mob/living/basic/carp/pet/cayenne/C in GLOB.mob_living_list)
			if (C.stat != DEAD)
				var/obj/item/stack/telecrystal/TC = new(C.drop_location(), tc_to_distribute)
				TC.throw_at(get_step(C, C.dir), 3, 3)
				C.visible_message(span_notice("[C] coughs up a half-digested telecrystal"),span_notice("You cough up a half-digested telecrystal!"))
				break


/obj/item/nuclear_challenge/proc/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, span_boldwarning("You are already in the process of declaring war! Make your mind up."))
		return FALSE
	if(GLOB.player_list.len < CHALLENGE_MIN_PLAYERS)
		to_chat(user, span_boldwarning("The enemy crew is too small to be worth declaring war on."))
		return FALSE
	if(!user.onSyndieBase())
		to_chat(user, span_boldwarning("You have to be at your base to use this."))
		return FALSE
	if(world.time - SSticker.round_start_time > CHALLENGE_TIME_LIMIT)
		to_chat(user, span_boldwarning("It's too late to declare hostilities. Your benefactors are already busy with other schemes. You'll have to make do with what you have on hand."))
		return FALSE
	for(var/obj/item/circuitboard/computer/syndicate_shuttle/board as anything in GLOB.syndicate_shuttle_boards)
		if(board.moved)
			to_chat(user, span_boldwarning("The shuttle has already been moved! You have forfeit the right to declare war."))
			return FALSE
	return TRUE

/obj/item/nuclear_challenge/proc/on_war_rejection()
	if(QDELETED(src))
		return

	var/list/batch_uplink_offers = list()
	for(var/datum/uplink_item/item as anything in SStraitor.uplink_items)
		if(item.item && !item.cant_discount && (item.purchasable_from & (UPLINK_NUKE_OPS|UPLINK_TRAITORS) && item.cost > COVERT_ORIGINAL_PRICE_MINIMUM && item.cost < COVERT_ORIGINAL_PRICE_MAXIMUM))
			batch_uplink_offers += item

	nukie_team.team_discounts += create_batch_sales(COVERT_BATCH_QUANTITY, /datum/uplink_category/batch_discounts, 1, batch_uplink_offers)

	say("War Benefactors have been notified of your unwillingness to fight, and have moved on to more important matters. Access to the covert discount market has been authorized.")

/// Creates "batch sales" of nukie items, wherein a large discount is offered, however a high minimum of the item MUST be purchased, all at once.
/// Takes an average discount (sometimes a big discount) and adds a 1.1-1.5x multiplier to it, capped at 90% off.
/// Given as an option when nukies specifically opt OUT of war.
/obj/item/nuclear_challenge/proc/create_batch_sales(sale_count, datum/uplink_category/category, limited_stock, list/sale_items)
	var/list/sales = list()
	var/list/sale_items_copy = sale_items.Copy()
	for (var/i in 1 to sale_count)
		var/datum/uplink_item/taken_item = pick_n_take(sale_items_copy)
		var/datum/uplink_item/uplink_item = new taken_item.type()

		var/batch_size = rand(4, 7)

		if(prob(20))
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
		uplink_item.desc = "A [pick("bargain", "batch", "marked-down", "discounted", "cheap", "surplus", "budget", "affordable")] order of [taken_item.name]. Must be purchased in a batch of [batch_size] units. Original unit price: [taken_item.cost] TC. Discounted unit price: [uplink_item.cost / batch_size] TC. This surplus package will save you [(taken_item.cost * batch_size) - (uplink_item.cost)] TC! "
		uplink_item.desc += pick(
			"Why pass up this incredible deal?",
			"BUY NOW!!!!!",
			"An absolute firesale!",
			"You'd have to be a MORON not to buy this one!",
			"This one's special, buy it now!",
			"Those idiots won't know what hit them!",
			"Show 'em who's boss!",
			"You ain't gonna see a deal like this again!",
			"Buy now or SUFFER THE CONSEQUENCES.",
			"Buy now and get ABSOLUTELY NOTHING extra!",
			"If you don't buy this, you'll lose!",
		)
		uplink_item.item = taken_item.item
		uplink_item.item_count = batch_size

		sales += uplink_item
	return sales

/obj/item/nuclear_challenge/clownops
	uplink_type = /obj/item/uplink/clownop

/// Subtype that does nothing but plays the war op message. Intended for debugging
/obj/item/nuclear_challenge/literally_just_does_the_message
	name = "\"Declaration of War\""
	desc = "It's a Syndicate Declaration of War thing-a-majig, but it only plays the loud sound and message. Nothing else."
	var/admin_only = TRUE

/obj/item/nuclear_challenge/literally_just_does_the_message/check_allowed(mob/living/user)
	if(admin_only && !check_rights_for(user.client, R_SPAWN|R_FUN|R_DEBUG))
		to_chat(user, span_hypnophrase("You shouldn't have this!"))
		return FALSE

	return TRUE

/obj/item/nuclear_challenge/literally_just_does_the_message/war_was_declared(mob/living/user, memo)
#ifndef TESTING
	// Reminder for our friends the admins
	var/are_you_sure = tgui_alert(user, "Last second reminder that fake war declarations is a horrible idea and yes, \
		this does the whole shebang, so be careful what you're doing.", "Don't do it", list("I'm sure", "You're right"))
	if(are_you_sure != "I'm sure")
		return
#endif

	priority_announce(memo, title = "Declaration of War", sound = 'sound/machines/alarm.ogg', has_important_message = TRUE)

/obj/item/nuclear_challenge/literally_just_does_the_message/distribute_tc()
	return

#undef CHALLENGE_TELECRYSTALS
#undef CHALLENGE_TIME_LIMIT
#undef CHALLENGE_MIN_PLAYERS
#undef CHALLENGE_SHUTTLE_DELAY
