/datum/quirk/gambling_addict
	name = "Compulsive Gambler"
	desc = "Games of chance excite you like nothing else. You feel the need to constantly be rolling the slot machines. If you can't, you can stave off the urge by flipping coins or rolling die..."
	icon = FA_ICON_CIRCLE_DOLLAR_TO_SLOT
	value = -3
	mob_trait = TRAIT_GAMBLING_ADDICT
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	gain_text = span_notice("You feel like taking a few spins on a slot machine, or ")
	lose_text = span_green("The compulsion to gamble seems to fade away...")
	medical_record_text = "Patient has a compulsive need to spend any excess money on gambling"
	hardcore_value = 5
	mail_goodies = list(/obj/item/coin/adamantine)

/datum/quirk/gambling_addict/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MINOR_GAMBLE, PROC_REF(on_gamble_postpone))
	RegisterSignal(quirk_holder, COMSIG_MAJOR_GAMBLE, PROC_REF(on_gamble_satisfaction))

datum/quirk/gambling_addict/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_MAJOR_GAMBLE, COMSIG_MINOR_GAMBLE, COMSIG_MOB_SAY))
