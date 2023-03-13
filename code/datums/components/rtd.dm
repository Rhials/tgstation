/**
 * Attached to a living mob.
 * Performs a wide variety of wacky silly effects when the user says "rtd"
 */
/datum/component/rtd
	/// How long of a timer will be applied after rolling the dice
	var/cooldown_length
	COOLDOWN_DECLARE(rtd_cooldown)

/datum/component/rtd/Initialize(cooldown_length = 100 SECONDS)
	. = ..()

	src.cooldown_length = cooldown_length

/datum/component/rtd/RegisterWithParent()
	if(!istype(parent, /mob/living/carbon/human))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_SAY, PROC_REF(check_speech))

/datum/component/rtd/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_SAY)

/datum/component/rtd/proc/check_speech(mob/living/carbon/speaker, speech_args)
	SIGNAL_HANDLER

	var/spoken_text = speech_args[SPEECH_MESSAGE]

	if((speaker == parent) && ((spoken_text == "Rtd") || (spoken_text == "rtd") || spoken_text = "!rtd"))
		if(!COOLDOWN_FINISHED(src, rtd_cooldown))
			to_chat(span_notice("RTD is still on cooldown. Please try again in [COOLDOWN_TIMELEFT(src, rtd_cooldown)]."))
			return

		INVOKE_ASYNC(src, PROC_REF(roll_the_dice))

/datum/component/rtd/proc/roll_the_dice()
	if(prob(2))
		rare_roll()
		return

	var/mob/living/carbon/human/victim = parent
	var/roll = rand(1, 50)

	switch(roll) //One long-ass switch coming right up
		if(1)
			minor_announce("[victim] has just rolled 'blind'!", "RTD announcement:")
			var/obj/item/organ/internal/eyes/eyes_to_blind = victim.getorganslot(ORGAN_SLOT_EYES)
			if (!eyes_to_blind)
				return
			victim.adjust_eye_blur_up_to(1 MINUTES, 3 MINUTES)
			eyes_to_blind.applyOrganDamage(rand(90, 160))
		if(2)

		if(3)
			minor_announce("[victim] has just rolled 'toxic'! Stay away!", "RTD announcement:") //YKNOW THE ORIGINAL VERSION OF THIS JUST INSTAKILLED YOU IF YOU WERE NEARBY YOU SHOULD BE THANKING ME THIS ISNT ON THE RARE DROP TABLE
			for(var/mob/living/person_to_intoxicate in range(5, victim))
				to_chat(person_to_intoxicate, span_alert("You feel the toxcicity radiating from [victim] seep into your bones..."))
				person_to_intoxicate.adjustToxLoss(amount = 10, updating_health = TRUE, forced = TRUE)
			minor_announce("[victim] has just rolled 'vibrant'!", "RTD announcement:")
		if(5)
			minor_announce("[victim] has just rolled 'YOU WILL NOT MOVE FOR THREE MINUTES'!", "RTD announcement:")
			victim.AdjustParalyzed(3 MINUTES) //This one is a little bit mean spirited but also fuck you hahaha
		if(6)
			minor_announce("[victim] has just rolled 'bad luck'!", "RTD announcement:")
			victim.AddComponent(/datum/component/omen)
		if(7)
			minor_announce("[victim] has just rolled 'sleep' in [get_area(victim)]!", "RTD announcement:") //announces their area so someone else can come wake them up
			victim.SetSleeping(4 MINUTES)
		if(8)
			minor_announce("[victim] has just rolled 'big mode'!", "RTD announcement:")
			victim.reagents.add_reagent(/datum/reagent/consumable/red_queen, 100)
		if(9)
			minor_announce("[victim] has just rolled 'free handcuffs'!", "RTD announcement:")
		if(10)
			minor_announce("[victim] has just rolled 'burst into flames'!", "RTD announcement:")
			victim.reagents.add_reagent(/datum/reagent/pyrosium, 200)
		if(11)
			minor_announce("[victim] has just rolled 'new uniform!", "RTD announcement:") //generates a random uniform, gives them it
		if(12)
			minor_announce("[victim] has just rolled 'jump to random player'!", "RTD announcement:")
		if(13)
			minor_announce("[victim] has just rolled 'the meathook'!", "RTD announcement:") //spawn and force them onto a meathook
		if(14)
			minor_announce("[victim] has just rolled 'big heal'!", "RTD announcement:")
			victim.adjustBruteLoss(-25)
			victim.adjustFireLoss(-25)
			victim.fully_heal(HEAL_CC_STATUS)
		if(15)
			minor_announce("[victim] has just rolled 'random brain trauma'!", "RTD announcement:")
		if(16)
			minor_announce("[victim] has just rolled 'random reagent'!", "RTD announcement:")
			victim.reagents.add_reagent(get_random_reagent_id(), 40)
		if(17)
			minor_announce("[victim] has just rolled 'random hair'!", "RTD announcement:")
		if(18)
			minor_announce("[victim] has just rolled 'ignite'!", "RTD announcement:")
			victim.ignite_mob(TRUE)
		if(19)
			minor_announce("[victim] has just rolled 'double up'!", "RTD announcement:")
			addtimer(CALLBACK(src, PROC_REF(roll_the_dice)), 5 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(roll_the_dice)), 15 SECONDS)
		if(20)
			minor_announce("[victim] has just rolled 'cracked up'!", "RTD announcement:")
		if(21)
			minor_announce("[victim] has just rolled ''!", "RTD announcement:")
		if(22)
			minor_announce("[victim] has just rolled 'random dismemberment'!", "RTD announcement:")
		if(23)
			minor_announce("[victim] has just rolled 'lose a random organ'!", "RTD announcement:")
			victim.spew_organ(3, 1)
		if(24)
			minor_announce("[victim] has just rolled 'vendor catastrophe'!", "RTD announcement:") //spawn a random vendor, flatten their ass with it
		if(25)
			minor_announce("[victim] has just rolled 'Fortnite'!", "RTD announcement:") //surround them with glass or walls
		if(26)
			minor_announce("[victim] has just rolled 'haunted'!", "RTD announcement:")
			haunt_outburst(victim, 10, 100, 1 MINUTES)
		if(27)
			minor_announce("[victim] has just rolled 'electromagentic pulse'!", "RTD announcement:")
			empulse(victim, 10, 5)

	COOLDOWN_START(src, rtd_cooldown, cooldown_length)

/datum/component/rtd/proc/rare_roll()
	var/roll = rand(1, 50)
	var/mob/living/carbon/human/victim = parent

	switch(roll) //Congrats, if you've reached this table you are very lucky and probably about to die
		if(1)
			minor_announce("[victim] has just rolled 'gib'!", "RTD announcement:")
			victim.gib(no_brain = FALSE, no_organs = FALSE, no_bodyparts = FALSE, safe_gib = TRUE)
		if(2)
			minor_announce("Uh oh! [victim] has just rolled 'no more eyes'!", "RTD announcement:")
			var/obj/item/organ/internal/eyes/eyes_to_discard = victim.getorganslot(ORGAN_SLOT_EYES)
			eyes_to_discard.Remove(victim)
			eyes_to_discard.forceMove(get_turf(victim))
		if(3)
			minor_announce("Hoo boy, [victim] has just rolled 'lightning strike'!", "RTD announcement:") //use the smite
		if(4)
			minor_announce("Hah, [victim] has just rolled 'true roll of the dice'!", "RTD announcement:") //give them a free one time use wizard d20
		if(5)
			minor_announce("[victim] has just rolled 'timebomb'!", "RTD announcement:")
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), victim, 3, 5, 8, 11, 15, TRUE), 35 SECONDS)
			to_chat(victim, span_boldwarning("You will explode in THIRTY-FIVE (35) SECONDS. The explosion will be large enough to take out a small medbay. If you are a kind and reputative individual, you will distance yourself from anything that wouldn't respond well to an explosion."))
			playsound(src, 'sound/machines/alarm.ogg', 50, -1, TRUE)
			for(var/i in 1 to 100)
				addtimer(CALLBACK(victim, TYPE_PROC_REF(/atom, add_atom_colour), (i % 2)? "#00FF00" : "#FF0000", ADMIN_COLOUR_PRIORITY), i)
		if(6)
			minor_announce("[victim] has just rolled 'vines'! Get searching!", "RTD announcement:") //Spawn vines somewhere, lmao
		if(7)
			minor_announce("[victim] has just rolled 'plasma burst'!", "RTD announcement:")
		if(8)
			minor_announce("[victim] has just rolled 'random blood'!", "RTD announcement:")
		if(9)
			minor_announce("Oh my -- [victim] has just rolled 'something horrible'!", "RTD announcement:") //genetic meltdown
			victim.something_horrible(ignore_stability = TRUE)
		if(10)
			minor_announce("Oh! [victim] has just rolled 'random item'!", "RTD announcement:")
		if(11)
			minor_announce("[victim] has just rolled 'instant death'!", "RTD announcement:")
		if(12)
			minor_announce("[victim] has just rolled 'cat'!", "RTD announcement:")
		if(13)
			minor_announce("[victim] has just rolled 'free straightjacket'!", "RTD announcement:") //forcibly equip a straightjacket. Lol.
		if(14)
			minor_announce("[victim] has just rolled 'sudden case of SSD'! Bye Bye!", "RTD announcement:") //copy from kick landmine
		if(15)
			minor_announce("[victim] has just rolled 'puzzle cube'! Someone go help them!", "RTD announcement:")
			var/obj/structure/puzzgrid_effect/puzzgrid_effect = new(target.loc, target, puzzgrid, timer, gib_on_loss)
			target.forceMove(puzzgrid_effect)
		if(13)
			minor_announce("[victim] has just rolled 'prison time'!", "RTD announcement:") //deadass just make them a prisoner
		if(14)
			minor_announce("Cover your ears, [victim] has just rolled 'quadruple up'!", "RTD announcement:")
			addtimer(CALLBACK(src, PROC_REF(roll_the_dice)), 5 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(roll_the_dice)), 10 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(roll_the_dice)), 15 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(roll_the_dice)), 20 SECONDS)
		if(15)
			minor_announce("[victim] has just rolled 'suffering'!", "RTD announcement:")

	COOLDOWN_START(src, rtd_cooldown, cooldown_length)
