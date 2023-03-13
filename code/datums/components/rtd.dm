/**
 * Attached to a living mob.
 * Performs a wide variety of wacky silly effects when the user says "rtd"
 */
/datum/component/rtd

/datum/component/rtd/Initialize(open_chance = 100, force_wait = 10 SECONDS)
	. = ..()

/datum/component/rtd/RegisterWithParent()
	if(!istype(parent, /mob/living/carbon/human))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_SAY, PROC_REF(check_speech))

/datum/component/rtd/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_SAY)

/datum/component/rtd/proc/check_speech(mob/living/carbon/speaker, speech_args)
	SIGNAL_HANDLER

	var/spoken_text = speech_args[SPEECH_MESSAGE]

	if((speaker == parent && spoken_text == "Rtd") || (speaker == parent && spoken_text == "rtd"))
		INVOKE_ASYNC(src, PROC_REF(roll_the_dice))

/datum/component/rtd/proc/roll_the_dice()
	var/rare_roll = rand(1, 25) //Chance to hit the RARE EFFECT TABLE (these ones are REALLY WACKY)
	if(rare_roll == 1)
		rare_roll()
		return

	var/mob/living/carbon/human/victim = parent
	var/roll = rand(1, 50)

	switch(roll) //THIS IS WHERE THE FUN BEGINS
		if(1)
			minor_announce("[victim] has just rolled 'blind'!", "RTD announcement:")
		if(2)
			minor_announce("[victim] has just rolled 'timebomb'!", "RTD announcement:")
		if(3)
			minor_announce("[victim] has just rolled 'toxic'!", "RTD announcement:")
		if(4)
			minor_announce("[victim] has just rolled 'vibrant'!", "RTD announcement:")
		if(5)
			minor_announce("[victim] has just rolled 'doped up'!", "RTD announcement:")
		if(6)
			minor_announce("[victim] has just rolled 'bad luck'!", "RTD announcement:")
		if(7)
			minor_announce("[victim] has just rolled 'sleep'!", "RTD announcement:")
			victim.SetSleeping(60 SECONDS)
		if(8)
			minor_announce("[victim] has just rolled 'booze'!", "RTD announcement:")
		if(9)
			minor_announce("[victim] has just rolled 'free handcuffs'!", "RTD announcement:")
		if(10)
			minor_announce("[victim] has just rolled 'burst into flames'!", "RTD announcement:")
		if(11)
			minor_announce("[victim] has just rolled 'new uniform!", "RTD announcement:") //generates a random uniform, gives them it
		if(12)
			minor_announce("[victim] has just rolled 'no more headset'!", "RTD announcement:")
		if(13)
			minor_announce("[victim] has just rolled 'the meathook'!", "RTD announcement:") //spawn and force them onto a meathook
		if(14)
			minor_announce("[victim] has just rolled 'random component'!", "RTD announcement:") //this one is going to be SO FUCKED
		if(15)
			minor_announce("[victim] has just rolled 'random brain trauma'!", "RTD announcement:")
		if(16)
			minor_announce("[victim] has just rolled 'torment'!", "RTD announcement:")
		if(17)
			minor_announce("[victim] has just rolled 'random hair'!", "RTD announcement:")
		if(18)
			minor_announce("[victim] has just rolled 'ignite'!", "RTD announcement:")
			victim.ignite_mob(TRUE)
		if(19)
			minor_announce("[victim] has just rolled 'vibrant'!", "RTD announcement:")
		if(20)
			minor_announce("[victim] has just rolled 'doped up'!", "RTD announcement:")
		if(21)
			minor_announce("[victim] has just rolled 'bad luck'!", "RTD announcement:")
		if(22)
			minor_announce("[victim] has just rolled 'random dismemberment'!", "RTD announcement:")
		if(23)
			minor_announce("[victim] has just rolled 'lose a random organ'!", "RTD announcement:")
		if(24)
			minor_announce("[victim] has just rolled 'vendor catastrophe'!", "RTD announcement:") //spawn a random vendor, flatten their ass with it
		if(25)
			minor_announce("[victim] has just rolled 'Fortnite'!", "RTD announcement:") //surround them with glass or walls
		if(26)
			minor_announce("[victim] has just rolled 'doped up'!", "RTD announcement:")
		if(27)
			minor_announce("[victim] has just rolled 'bad luck'!", "RTD announcement:")

/datum/component/rtd/proc/rare_roll()
	var/roll = rand(1, 50)
	var/mob/living/carbon/human/victim = parent

	switch(roll) //Congrats, if you've reached this table you are very lucky and probably about to die
		if(1)
			minor_announce("[victim] has just rolled 'gib'!", "RTD announcement:")
			victim.gib(no_brain = FALSE, no_organs = FALSE, no_bodyparts = FALSE, safe_gib = TRUE)
		if(2)
			minor_announce("Uh oh! [victim] has just rolled 'no more eyes'!", "RTD announcement:")
		if(3)
			minor_announce("Hoo boy, [victim] has just rolled 'lightning strike'!", "RTD announcement:") //use the smite
		if(4)
			minor_announce("Hah, [victim] has just rolled 'true roll of the dice'!", "RTD announcement:") //give them a free one time use wizard d20
		if(5)
			minor_announce("Get back, [victim] has just rolled 'thermonuclear timebomb'!", "RTD announcement:")
		if(6)
			minor_announce("[victim] has just rolled 'vines'! Get searching!", "RTD announcement:") //Spawn vines somewhere, lmao
		if(7)
			minor_announce("[victim] has just rolled 'plasma burst'!", "RTD announcement:")
		if(8)
			minor_announce("[victim] has just rolled 'random blood'!", "RTD announcement:")
		if(9)
			minor_announce("Oh my -- [victim] has just rolled 'something awful'!", "RTD announcement:") //genetic meltdown
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
		if(13)
			minor_announce("[victim] has just rolled 'prison time'!", "RTD announcement:") //deadass just make them a prisoner
		if(14)
			minor_announce("[victim] has just rolled 'torture'!", "RTD announcement:")
		if(15)
			minor_announce("[victim] has just rolled 'suffering'!", "RTD announcement:")
