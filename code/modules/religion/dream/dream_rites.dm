///Invokes an "enlightened" dream, but only onto other sleeping players.
/datum/religion_rites/dream
	name = "Invoke Dream" //Come up with a WAY cooler name than this dude
	desc = "Attunes a target to the Dream Realm, invoking their dreams with prophetic knowledge. \
		Cannot be used on oneself, as you must be awake to cast it!" //I can come up with something WAY more creative than "dream realm" im just so tired
	ritual_length = 10 SECONDS
	ritual_invocations = list(
		"A good, honorable crusade against evil is required.",
		"We need the righteous ...",
		"... the unflinching ...",
		"... and the just.",
		"Sinners must be silenced ...",
	)
	invoke_msg = "... And the code must be upheld!"

/datum/religion_rites/dream/perform_rite(mob/living/user, atom/religious_tool)
	return ..()

/datum/religion_rites/dream/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()

///Invokes an enlightened dream in an area, allowing for multiple dreamers as long as the chaplain is casting.
/datum/religion_rites/area_dream
	name = "Area Dream" //better name, now
	desc = "Attunes anyone dreaming nearby to the dream realm blah blah fill this in later"
	ritual_length = 60 SECONDS //Idea is, if you can get a bunch of shmucks dreaming at once or coming to you for help then.. idk?
	ritual_invocations = list( //Maybe it can help bolster other peoples dreams? There might be some sort of like, dream weight to stuff? Maybe this is
		"Go to sleep...", //Too early for the dream meme rush. COMMIT TO MAKING MORE DREAM STUFF SO THIS WILL BE USEFUL? idk.
		"Go to sleep...",
		"Close your big bloodshot eyes...",
	)
	invoke_msg = "... And the code must be upheld!"

/datum/religion_rites/area_dream/perform_rite(mob/living/user, atom/religious_tool)
	return ..()

/datum/religion_rites/area_dream/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()
