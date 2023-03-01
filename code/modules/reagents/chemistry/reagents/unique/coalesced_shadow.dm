/**
 * A reagent with the Light Eater component, found in the bloodstream of Nightmares.
 *
 * A reagent that generates with the Light Eater element attached.
 *
 *
 */

/datum/reagent/coalesced_shadow
	name = "Coalesced Shadow"
	description = "Pure, condenced darkness. Will instantly absorb and extinguish out any light it is exposed to."
	taste_description = "ink"
	taste_mult = 5
	reagent_state = GAS
	color = "#131313"

/datum/reagent/coalesced_shadow/New()
	. = ..()

	AddElement(/datum/element/light_eater)

/datum/reagent/coalesced_shadow/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!ishuman(exposed_mob) || isnightmare(exposed_mob))
		return

	var/mob/living/carbon/victim = exposed_mob
	if(methods & (VAPOR) && !victim.get_eye_protection() && prob(40))
		to_chat(victim, span_alert("You blink. Your eyelids open, but the darkness remains for a moment."))
		victim.adjust_temp_blindness(3 SECONDS)
	if(methods & INGEST)
		if(isethereal(victim)) //Does a little extra alongside shutting off their light.
			to_chat(victim, span_warning("You accidentally ingest some of the shadows. It feels like something inside of you has just died."))
			victim.vomit(0, FALSE, FALSE, 2, FALSE, FALSE)
			var/obj/item/organ/internal/heart/victim_heart = victim.getorganslot(ORGAN_SLOT_HEART)
			victim_heart.applyOrganDamage(2, 90, /obj/item/organ/internal/heart/ethereal)
