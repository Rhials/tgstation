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
	if(user.client?.ckey == chosen_hero)
		to_chat(user, span_alert("The sword budges a little bit. You feel nothing."))
	else
		to_chat(user, span_alert("The sword doesn't move. You feel suicidal."))

/obj/structure/excalibur_mount/proc/select_hero()
	var/list/candidate_list = list()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list))
		if(!candidate.client || !candidate.client.ckey)
			continue
		if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		candidate_list += candidate.client.ckey
