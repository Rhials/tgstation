/**
 * Attached to a living mob.
 * Performs a wide variety of wacky silly effects when the user says "rtd"
 */
/datum/component/rtd

/datum/component/rtd/Initialize(open_chance = 100, force_wait = 10 SECONDS)
	. = ..()

/datum/component/rtd/RegisterWithParent()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_SAY, PROC_REF(check_speech))

/datum/component/rtd/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_SAY)

/datum/component/rtd/proc/check_speech(mob/living/speaker, speech_args)
	SIGNAL_HANDLER

	var/spoken_text = speech_args[SPEECH_MESSAGE]

	if((speaker == parent && spoken_text == "Rtd") || (speaker == parent && spoken_text == "rtd"))
		INVOKE_ASYNC(src, PROC_REF(roll_the_dice))

/datum/component/rtd/proc/roll_the_dice()
	var/rare_roll = rand(1, 25) //Chance to hit the RARE EFFECT TABLE (these ones are REALLY WACKY)
	if(rare_roll == 1)
		rare_roll()
		return

	var/roll = rand(1, 50)

	switch(roll) //THIS IS WHERE THE FUN BEGINS
		if(1)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(2)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(3)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(4)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(5)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(6)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(7)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(8)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(9)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(10)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(11)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(12)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(13)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(14)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(15)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")

/datum/component/rtd/proc/rare_roll()
	var/roll = rand(1, 50)

	switch(roll) //THIS IS WHERE THE FUN BEGINS
		if(1)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(2)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(3)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(4)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(5)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(6)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(7)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(8)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(9)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(10)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(11)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(12)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(13)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(14)
			minor_announce("[parent] has just rolled 'blind'!", "RTD announcement:")
		if(15)
