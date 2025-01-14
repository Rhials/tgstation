///Invokes a "prophetic" dream, but only onto other sleeping players. These dreams will reveal upcoming random events, and possibly other info.
/datum/religion_rites/prophetic_dream //glob signals like death
	name = "Invoke Dream" //Come up with a WAY cooler name than this dude
	desc = "Imbues a dreaming person with the gift of prophecy, granting visions of future tribulations the crew may face. \
		Cannot be used on oneself, as you must be awake to cast it!" //I can come up with something WAY more creative than "dream realm" im just so tired
	ritual_length = 8 SECONDS
	ritual_invocations = list(
		"Close your eyes...",
		"Open your mind...",
		"Dream of what has passed...",
	)
	invoke_msg = "And dream of what's to come..."

/datum/religion_rites/prophetic_dream/perform_rite(mob/living/user, atom/religious_tool)
	return ..()

/datum/religion_rites/prophetic_dream/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()

///Allows the chaplain to commune with a dreaming player. Useful for extracting prophecies if the player wishes to remain asleep.
/datum/religion_rites/dream_commune
	name = "Dream Commune"
	desc = "Allows for you to send one message to the mind of a dreaming person nearby, and for them to respond back in kind."
	ritual_length = 10 SECONDS
	ritual_invocations = list(
		"Correspondence with the dreaming mind...",
		"Reveal the secrets you may find...",
		"Rest well, breathe slow...",
	)
	invoke_msg = "Reveal all you've come to know..."

/datum/religion_rites/dream_commune/perform_rite(mob/living/user, atom/religious_tool)
	return ..()

/datum/religion_rites/dream_commune/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()

///Picks one item under the dreaming player, and finds another item of the same path somewhere on the station, giving a vague area of where it is.
/datum/religion_rites/dream_hunt
	name = "Oneric Pursuit"
	desc = ""
	ritual_length = 10 SECONDS
	ritual_invocations = list(
		"Close your eyes...",
		"Open your mind...",
		"Dream of what has passed...",
	)
	invoke_msg = "And dream of what's to come..."

/datum/religion_rites/dream/perform_rite(mob/living/user, atom/religious_tool)
	return ..()

/datum/religion_rites/dream/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()

///While dreaming, allows you to select from a list of other dreamers and initiate dialogue.
/datum/religion_rites/astral_projection
	name = "Astral Projection"
	desc = "Allows you to commune with other sleeping individuals nearby as you sleep. Must be casted BEFORE you fall asleep!"
	ritual_length = 10 SECONDS
	ritual_invocations = list(
		"Close your eyes...",
		"Open your mind...",
		"Dream of what has passed...",
	)
	invoke_msg = "And dream of what's to come..."

/datum/religion_rites/astral_projection/perform_rite(mob/living/user, atom/religious_tool)
	return ..()

/datum/religion_rites/astral_projection/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	..()
