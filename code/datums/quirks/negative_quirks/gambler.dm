///Rate per process() call we drain satisfaction by.
#define SATISFACTION_DECAY_RATE (1 SECONDS)

///The cap on how much satisfaction you can grind for with "lower level" means like coin flips or die.
#define SATISFACTION_MINOR_CAP (5 MINUTES)

///How much time is added to your satisfaction timer when
#define SATISFACTION_RESTORE_MINIMUM (8 SECONDS)
///How much time is added when meaninfully postponing urges.
#define SATISFACTION_RESTORE_MEDIUM (70 SECONDS)
///How much time is added upon winning a jackpot.
#define SATISFACTION_RESTORE_MAXIMUM (12 MINUTES)
///How much time added for rolling a Die of Fate, regardless of outcome.
#define SATISFACTION_RESTORE_FATE (30 MINUTES)

/datum/quirk/gambling_addict
	name = "Compulsive Gambler"
	desc = "Games of chance excite you like nothing else. You feel the need to constantly be rolling the slot machines. If you can't, you can stave off the urge by flipping coins or rolling die..."
	icon = FA_ICON_CIRCLE_DOLLAR_TO_SLOT
	value = -4
	mob_trait = TRAIT_GAMBLING_ADDICT
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_MOODLET_BASED | QUIRK_PROCESSES
	gain_text = span_notice("You feel like taking a few spins on a slot machine, or maybe just a roll of the dice...")
	lose_text = span_green("The compulsion to gamble seems to fade away...")
	medical_record_text = "Patient is hopelessly addicted to gambling and games of chance."
	hardcore_value = 5
	mail_goodies = list(/obj/item/coin/adamantine)
	///A value recording how "satisfied" the user is. Recorded and managed in time values to make tuning the reward values easier.
	var/satisfaction = (5 MINUTES)

/datum/quirk/gambling_addict/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MINOR_GAMBLE, PROC_REF(on_gamble_postpone))
	RegisterSignal(quirk_holder, COMSIG_MAJOR_GAMBLE, PROC_REF(on_gamble_satisfaction))
	RegisterSignal(quirk_holder, COMSIG_HUGE_GAMBLE, PROC_REF(on_gamble_winner))
	RegisterSignal(quirk_holder, COMSIG_GAMBLER_FATE, PROC_REF(on_die_of_fate))

/datum/quirk/gambling_addict/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_MINOR_GAMBLE, COMSIG_MAJOR_GAMBLE, COMSIG_HUGE_GAMBLE, COMSIG_GAMBLER_FATE))

/datum/quirk/gambling_addict/process(seconds_per_tick)
	if(quirk_holder.stat == DEAD)
		return

	satisfaction -= (SATISFACTION_DECAY_RATE * seconds_per_tick)

/datum/quirk/gambling_addict/proc/on_gamble_postpone(datum/source, gambling_object, modifier)
	SIGNAL_HANDLER
	if(satisfaction <= SATISFACTION_MINOR_CAP)
		satisfaction += SATISFACTION_RESTORE_MINIMUM + (modifier SECONDS) //This is kind of janky but for every extra side on your die, you get an extra second of postponement. Hit that d100!
		if(prob(40)) //You'll be doing this very frequently and we don't want chat getting spammed.
			to_chat(quirk_holder, span_notice("You look at the [gambling_object] in your hand and smirk slightly. You've won, but the feeling barely moves you..."))
	return

/datum/quirk/gambling_addict/proc/on_gamble_satisfaction(datum/source, gambling_object)
	SIGNAL_HANDLER
	if(satisfaction <= SATISFACTION_MINOR_CAP)
		satisfaction += SATISFACTION_RESTORE_MEDIUM
		if(prob(25))
			to_chat(quirk_holder, span_green("With another go at the [gambling_object], you feel a bit more engaged with your surroundings. You'll win eventually..."))
	return

/datum/quirk/gambling_addict/proc/on_gamble_winner(datum/source, gambling_object) //note to self, remove gambling_object arg if you end up not using it
	SIGNAL_HANDLER
	to_chat(quirk_holder, span_nicegreen("Success! All you had to do was keep gambling! Your brain reels as the ecstatic weight of your success crashes down on it."))
	satisfaction += SATISFACTION_RESTORE_MAXIMUM
	return

/datum/quirk/gambling_addict/proc/on_die_of_fate(datum/source, obj/item/dice/d20/fate/our_die)
	SIGNAL_HANDLER
	to_chat(quirk_holder, span_boldnicegreen("As you roll the [our_die], a surge of satisfaction passes through your mind. You realize you don't even care what the result is. \
		The outcome hardly matters, and for a moment you wish it would keep rolling forever, but then..."))
	satisfaction += SATISFACTION_RESTORE_FATE
	return

#undef SATISFACTION_DECAY_RATE
#undef SATISFACTION_MINOR_CAP
#undef SATISFACTION_RESTORE_MINIMUM
#undef SATISFACTION_RESTORE_MEDIUM
#undef SATISFACTION_RESTORE_MAXIMUM
#undef SATISFACTION_RESTORE_FATE
