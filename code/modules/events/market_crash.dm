/**
 * An event which decreases the station target temporarily, causing the inflation var to increase heavily.
 *
 * Done by decreasing the station_target by a high value per crew member, resulting in the station total being much higher than the target, and causing artificial inflation.
 */
/datum/round_event_control/market_crash
	name = "Market Crash"
	typepath = /datum/round_event/market_crash
	weight = 10
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Temporarily increases the prices of vending machines."

/datum/round_event/market_crash
	var/market_dip = 0

/datum/round_event/market_crash/setup()
	start_when = 1
	end_when = rand(25, 50)
	announce_when = 2

/datum/round_event/market_crash/announce(fake)
	var/list/poss_reasons = list("the alignment of the moon and the sun",\
		"some risky housing market outcomes",\
		"The B.E.P.I.S. team's untimely downfall",\
		"speculative Terragov grants backfiring",\
		"greatly exaggerated reports of Nanotrasen accountancy personnel committing mass suicide")
	var/reason = pick(poss_reasons)
	priority_announce("Due to [reason], prices for on-station vendors will be increased for a short period.", "Nanotrasen Accounting Division")

/datum/round_event/market_crash/start()
	. = ..()
	market_dip = rand(1000,10000) * length(SSeconomy.bank_accounts_by_id)
	SSeconomy.station_target = max(SSeconomy.station_target - market_dip, 1)
	SSeconomy.price_update()
	ADD_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, MARKET_CRASH_EVENT_TRAIT)

/datum/round_event/market_crash/end()
	. = ..()
	SSeconomy.station_target += market_dip
	REMOVE_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, MARKET_CRASH_EVENT_TRAIT)
	SSeconomy.price_update()
	priority_announce("Prices for on-station vendors have now stabilized.", "Nanotrasen Accounting Division")

/**
 * Selects a random vendor subtype (updating every single vendor price every tick would probably be laggy) and fluctuates the price wildly (think of how you buy stuff with kromer in Spamton's shop)
 *	Currently, none of this is implemented, I'm just banging out the framework for when I get smart enough to actually implement this.
 * This should give people the opportunity to scoop up stuff from the vendors at a cheap price if they're fast enough.
 */

/datum/round_event_control/market_crash/volatile_market()
	name = "Market Crash: Volatile Market"
	typepath = /datum/round_event/market_crash/volatile_market
	weight = 12
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Cause rapid fluctuations in price for a certain vendor type."

/datum/round_event/market_crash/volatile_market()

/datum/round_event/market_crash/setup()
	start_when = 1
	end_when = rand(25, 50)
	announce_when = 2

/datum/round_event/market_crash/volatile_market/announce(fake)
	var/list/poss_reasons = list("the alignment of the moon and the sun",\
		"some risky housing market outcomes",\
		"The B.E.P.I.S. team's untimely downfall",\
		"speculative Terragov grants backfiring",\
		"greatly exaggerated reports of Nanotrasen accountancy personnel committing mass suicide")
	var/reason = pick(poss_reasons)
	priority_announce("Due to [reason], prices for on-station vendors will be increased for a short period.", "Nanotrasen Accounting Division")

/datum/round_event/market_crash/volatile_market/start()
	. = ..()
	market_dip = rand(1000,10000) * length(SSeconomy.bank_accounts_by_id)
	SSeconomy.station_target = max(SSeconomy.station_target - market_dip, 1)
	SSeconomy.price_update()
	ADD_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, MARKET_CRASH_EVENT_TRAIT)

/datum/round_event/market_crash/volatile_market/tick()
	market_dip = rand(1000,10000) * length(SSeconomy.bank_accounts_by_id)
	SSeconomy.station_target = max(SSeconomy.station_target - market_dip, 1)
	SSeconomy.price_update(announce = FALSE)

/datum/round_event/market_crash/volatile_market/end()
	. = ..()
	SSeconomy.station_target += market_dip
	REMOVE_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING, MARKET_CRASH_EVENT_TRAIT)
	SSeconomy.price_update()
	priority_announce("Prices for on-station vendors have now stabilized.", "Nanotrasen Accounting Division")
