#define CHOICE_PICK_PLAYER "Pick player"
#define CHOICE_POLL_GHOSTS "Offer to ghosts"
#define CHOICE_END_THEM "Do it!"
#define CHOICE_CANCEL "Cancel"

/**
 * Custom selected split personality.
 *
 * Injects a player with a split personality that periodically takes control of them. Unlike imaginary friend, this one IS tied to the brain trauma, so your victim needs a brain.
 **/
/datum/smite/custom_split_personality
	name = "Split Personality (Special)"
	/// Are we polling for ghosts
	var/ghost_polling
	/// How many split personalities should be added when polling
	var/polled_personality_count

/datum/smite/custom_split_personality/configure(client/user)
	var/client_selection_choice = tgui_alert(user,
		"Do you want to pick a specific player, or poll for ghosts?",
		"Personality Selection?",
		list(CHOICE_PICK_PLAYER, CHOICE_POLL_GHOSTS, CHOICE_CANCEL))

	if(isnull(client_selection_choice) || client_selection_choice == CHOICE_CANCEL)
		return FALSE
	ghost_polling = client_selection_choice == CHOICE_POLL_GHOSTS

	if(ghost_polling)
		var/how_many = tgui_input_number(user, "How many personalities should be added?", "Split personality count", default = 1, min_value = 1)
		if(isnull(how_many) || how_many < 1)
			return FALSE
		polled_personality_count = how_many

	return TRUE


/// Try to offer the role to ghosts
/datum/smite/custom_split_personality/proc/poll_ghosts(client/user, mob/living/target)
	var/list/volunteers = SSpolling.poll_ghost_candidates(
		check_jobban = ROLE_PAI,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_SPLITPERSONALITY,
		jump_target = target,
		role_name_text = "a split personality of [target.real_name]",
	)
	var/volunteer_count = length(volunteers)
	if(volunteer_count == 0)
		to_chat(user, span_warning("No candidates volunteered, aborting."))
		return

	shuffle_inplace(volunteers)
	var/list/personality_candidates = list()
	while(polled_personality_count > 0 && length(volunteers) > 0)
		var/mob/dead/observer/lucky_ghost = pop(volunteers)
		if (!lucky_ghost.client)
			continue
		polled_personality_count--
		personality_candidates += lucky_ghost.client
	return personality_candidates

/// Pick client manually
/datum/smite/custom_split_personality/proc/pick_client(client/user)
	var/picked_client = tgui_input_list(user, "Pick the player to put in control", "New Personality", sort_list(GLOB.clients))
	if(isnull(picked_client))
		return

	var/client/friend_candidate_client = picked_client
	if(QDELETED(friend_candidate_client))
		to_chat(user, span_warning("Selected player no longer has a client, aborting."))
		return

	if(isliving(friend_candidate_client.mob))
		var/end_them_choice = tgui_alert(user,
			"This player already has a living mob ([friend_candidate_client.mob]). Do you still want to turn them into an Split Personality?",
			"Remove player from mob?",
			list(CHOICE_END_THEM, CHOICE_CANCEL))
		if(end_them_choice == CHOICE_CANCEL)
			return

	if(QDELETED(friend_candidate_client))
		to_chat(user, span_warning("Selected player no longer has a client, aborting."))
		return

	return list(friend_candidate_client)


/datum/smite/custom_split_personality/effect(client/user, mob/living/target)
	. = ..()

	// Run this check before and after polling, we don't wanna poll for something which already stopped existing
	if(QDELETED(target))
		to_chat(user, span_warning("The target mob no longer exists, aborting."))
		return

	var/list/personality_candidates
	if(ghost_polling)
		personality_candidates = poll_ghosts(user, target)
	else
		personality_candidates = pick_client(user)

	if(QDELETED(target))
		to_chat(user, span_warning("The target mob no longer exists, aborting."))
		return

	if(isnull(personality_candidates) || !length(personality_candidates))
		to_chat(user, span_warning("No provided personality candidates, aborting."))
		return

	var/list/final_clients = list()
	for(var/client/client as anything in personality_candidates)
		if(QDELETED(client))
			continue
		final_clients += client

	if(!length(final_clients))
		to_chat(user, span_warning("No provided personality candidates had clients, aborting."))
		return

	if(!iscarbon(target))
		to_chat(user, span_warning("The target mob doesn't have a brain to target!"))
		return FALSE

	var/mob/living/carbon/target_carbon = target
	var/datum/brain_trauma/severe/split_personality/new_personality_schism = target_carbon.gain_trauma(/datum/brain_trauma/severe/split_personality, TRAUMA_RESILIENCE_ABSOLUTE)
	new_personality_schism.make_backseats(personality_candidates)

#undef CHOICE_PICK_PLAYER
#undef CHOICE_POLL_GHOSTS
#undef CHOICE_END_THEM
#undef CHOICE_CANCEL
