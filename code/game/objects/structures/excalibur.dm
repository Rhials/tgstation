///Sword-in-a-stone. Can only be removed by one active crewmember on the server. The "hero" is selected on the first attempt at removing it, so a proper list of candidates can be used instead of whoever was alive when the ruin generated.
/obj/structure/excalibur_mount
	name = "mysterious sword"
	desc = "Only one of you fools may pull my sword. FOOLS."
	icon_state = "excalibur_mounted"
	///The ckey of whom have we selected as the guy who can pull the sword out.
	var/chosen_hero

/obj/structure/excalibur_mount/interact(mob/user)
	. = ..()
	if(!chosen_hero)
		select_hero()
	user.apply_damage(20, STAMINA)
	to_chat(user, span_notice("You begin yanking at the sword with all of your might..."))
	if(!do_after(user, 10 SECONDS, src))
		return
	user.apply_damage(40, STAMINA)
	if(user.ckey == chosen_hero)
		to_chat(user, span_alert("The sword doesn't budge. Perhaps you are unworthy of wielding such a blade?"))
	else
		to_chat(user, span_alert("With a final tug, the sword slides out of the rock encasing it. You are worthy of wielding the mighty... Excalibur!"))

/obj/structure/excalibur_mount/proc/select_hero()
	var/list/candidate_list = list()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list))
		//if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER)) ///uncomment after testing
		//	continue
		candidate_list += candidate.client.ckey





///Note to self. If you can't think of any sauce to give this idea, make it a toolbox sword. work from there.
