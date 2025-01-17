/**
 * A reagent with the Light Eater component, generated when a light eater is used on a reagent holder.
*/

/datum/reagent/coalesced_shadow
	name = "Coalesced Shadow"
	description = "Pure, condenced darkness. Will instantly absorb and extinguish out any light it is exposed to."
	taste_description = "ink"
	taste_mult = 5 //Like licking a ballpoint pen.
	color = "#131313"

/datum/reagent/coalesced_shadow/New()
	. = ..()
	AddElement(/datum/element/light_eater)

/datum/reagent/consumable/coalesced_shadow/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!ishuman(exposed_mob) || isnightmare(exposed_mob))
		return

	var/mob/living/carbon/victim = exposed_mob
	if(methods & (VAPOR) && prob(40))
		to_chat(victim, span_alert("You blink. Your eyelids open, but the darkness remains for a moment."))
		victim.adjust_temp_blindness(1 SECONDS)
	if(methods & INGEST && isethereal(victim))
		to_chat(victim, span_warning("You accidentally ingest some of the coalesced shadow. Deep down, it feels like something important inside of you has just died."))
		victim.vomit(0, FALSE, FALSE, 2, FALSE, FALSE)
