/datum/antagonist/paradox_clone
	name = "\improper Paradox Clone"
	roundend_category = "Paradox Clone"
	job_rank = ROLE_PARADOX_CLONE
	antagpanel_category = ANTAG_GROUP_PARADOX
	antag_hud_name = "paradox_clone"
	show_to_ghosts = TRUE
	suicide_cry = "THERE CAN BE ONLY ONE!!"
	preview_outfit = /datum/outfit/paradox_clone

	///Weakref to the mind of the original, the clone's target.
	var/datum/weakref/original_ref

/datum/antagonist/paradox_clone/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)

	final_icon.Blend(make_background_clone_icon(preview_outfit), ICON_UNDERLAY, -8, 0)
	final_icon.Scale(64, 64)

	return finish_preview_icon(final_icon)

/datum/antagonist/paradox_clone/proc/make_background_clone_icon(datum/outfit/clone_fit)
	var/mob/living/carbon/human/dummy/consistent/clone = new

	var/icon/clone_icon = render_preview_outfit(clone_fit, clone)
	clone_icon.ChangeOpacity(0.5)
	qdel(clone)

	return clone_icon

/datum/antagonist/paradox_clone/on_gain()
	owner.special_role = ROLE_PARADOX_CLONE
	return ..()

/datum/antagonist/paradox_clone/on_removal()
	//don't null it if we got a different one added on top, somehow.
	if(owner.special_role == ROLE_PARADOX_CLONE)
		owner.special_role = null
	original_ref = null
	return ..()

/datum/antagonist/paradox_clone/Destroy()
	original_ref = null
	return ..()

/datum/antagonist/paradox_clone/proc/setup_clone()
	var/datum/mind/original_mind = original_ref?.resolve()

	var/datum/objective/assassinate/paradox_clone/kill = new
	kill.owner = owner
	kill.target = original_mind
	kill.update_explanation_text()
	objectives += kill

	owner.set_assigned_role(SSjob.GetJobType(/datum/job/paradox_clone))

	//clone doesnt show up on message lists
	var/obj/item/modular_computer/pda/messenger = locate() in owner.current
	if(messenger)
		var/datum/computer_file/program/messenger/message_app = locate() in messenger.stored_files
		if(message_app)
			message_app.invisible = TRUE

	//dont want anyone noticing there's two now
	var/mob/living/carbon/human/clone_human = owner.current
	var/obj/item/clothing/under/sensor_clothes = clone_human.w_uniform
	if(sensor_clothes)
		sensor_clothes.sensor_mode = SENSOR_OFF
		clone_human.update_suit_sensors()

	// Perform a quick copy of existing memories.
	// This may result in some minutely imperfect memories, but it'll do
	original_mind.quick_copy_all_memories(owner)

///Creates the clone body at the selected turf. Will not fire if the camera is viewing the clone target.
/datum/antagonist/paradox_clone/proc/make_clone(creation_turf)
	var/datum/mind/player_mind = new /datum/mind(owner.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/clone_victim = select_victim()
	var/mob/living/carbon/human/clone = clone_victim.make_full_human_copy(creation_turf)
	player_mind.transfer_to(clone)

	var/datum/antagonist/paradox_clone/new_datum = player_mind.add_antag_datum(/datum/antagonist/paradox_clone)
	new_datum.original_ref = WEAKREF(clone_victim.mind)
	new_datum.setup_clone()

	playsound(clone, 'sound/weapons/zapbang.ogg', 30, TRUE)
	new /obj/item/storage/toolbox/mechanical(clone.loc) //so they dont get stuck in maints

	message_admins("[ADMIN_LOOKUPFLW(clone)] has been made into a Paradox Clone by the midround ruleset.")
	clone.log_message("was spawned as a Paradox Clone of [key_name(clone)] by the midround ruleset.", LOG_GAME)

	return clone

/**
 * Trims through GLOB.player_list and finds a target
 * Returns a single human victim, if none is possible then returns null.
 */
/datum/antagonist/paradox_clone/proc/select_victim()
	var/list/possible_targets = list()

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.client || !player.mind || player.stat)
			continue
		if(!(player.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		possible_targets += player

	if(possible_targets.len)
		return pick(possible_targets)
	return FALSE

/datum/antagonist/paradox_clone/roundend_report_header()
	return "<span class='header'>A paradox clone appeared on the station!</span><br>"

/datum/outfit/paradox_clone
	name = "Paradox Clone (Preview only)"

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/soft/purple

/**
 * Paradox clone assassinate objective
 * Similar to the original, but with a different flavortext.
 */
/datum/objective/assassinate/paradox_clone
	name = "clone assassinate"

/datum/objective/assassinate/paradox_clone/update_explanation_text()
	. = ..()
	if(!target?.current)
		explanation_text = "Free Objective"
		CRASH("WARNING! [ADMIN_LOOKUPFLW(owner)] paradox clone objectives forged without an original!")
	explanation_text = "Murder and replace [target.name], the [!target_role_type ? target.assigned_role.title : target.special_role]. Remember, your mission is to blend in, do not kill anyone else unless you have to!"
