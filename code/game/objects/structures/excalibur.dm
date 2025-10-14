///Sword-in-a-stone. Can only be removed by one active crewmember on the server. The "hero" is selected on the first attempt at removing it, so a proper list of candidates can be used instead of whoever was alive when the ruin generated.
///It became a toolbox sword at some point in the design. Not sure if I should keep calling it a sword?? I dunno man just roll with it.
/obj/structure/excalibur_mount
	name = "mysterious rock"
	desc = "A boulder with a curious looking weapon sticking out of it. Legends say that it can only be freed by a single, chosen member of the crew. Maybe that single, chosen member of the crew is YOU!"
	icon_state = "excalibur_mounted"
	///The ckey of whom have we selected as the guy who can pull the sword out.
	var/chosen_hero
	///Have we released our sword yet?
	var/released_sword = FALSE

/obj/structure/excalibur_mount/interact(mob/user)
	. = ..()
	if(!chosen_hero)
		select_hero()
	if(released_sword)
		to_chat(user, span_notice("The sword has already b een freed from the stone. You peer into the hole the sword came out of and shrug. The hole smells faintly of motor oil."))
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	living_user.apply_damage(20, STAMINA)
	to_chat(living_user, span_notice("You begin yanking at the sword with all of your might..."))
	if(!do_after(living_user, 12 SECONDS, src))
		return
	living_user.apply_damage(40, STAMINA)
	if(living_user.ckey == chosen_hero)
		to_chat(living_user, span_alert("The sword doesn't budge. Perhaps someone <i>else<i/> on the station is worthy of wielding such a blade?"))
		living_user.mind?.adjust_experience(/datum/skill/athletics, 4)
	else
		to_chat(living_user, span_alert("With a final tug, the sword slides out of the rock encasing it. You are worthy of wielding the mighty-- Hang on, is that a toolbox?"))
		released_sword = TRUE
		icon_state = "excalibur_mountless"
		living_user.mind?.adjust_experience(/datum/skill/athletics, 40) //A weapon such as this deserves a MIGHTY hero to wield it.
		var/obj/item/toolboxcalibur/released_toolbox = new(get_turf(src))
		released_toolbox.change_owner(living_user)
		living_user.put_in_active_hand(released_toolbox)

/obj/structure/excalibur_mount/proc/select_hero()
	var/list/candidate_list = list()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list))
		//if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER)) ///uncomment after testing
		//	continue
		candidate_list += candidate.client.ckey

/obj/item/toolboxcalibur
	name = "Toolboxcalibur"
	desc = "The mythical <b>Toolboxcalibur</b>. Its completely absurd design makes it near impossible to wield or swing in a fight. Fortunately, it's also so incredibly heavy that even a glancing blow will obliterate its target. \
		Only a single chosen hero amongst the crew can lift this weapon."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "toolboxcalibur_lame"
	inhand_icon_state = "toolboxcalibur"
	worn_icon_state = "toolboxcalibur"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	attack_verb_simple = list("robust")
	attack_verb_continuous = list("robusts")
	force = 30
	throwforce = 45
	throw_range = 10
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/gold = SHEET_MATERIAL_AMOUNT)
	hitsound = 'sound/items/weapons/toolsword_slam.ogg'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	wound_bonus = 30
	armour_penetration = 30
	demolition_mod = 1.30
	///Who is our chosen hero, destined to wield us in glorious combat?
	var/mob/chosen_owner
	///Where were we last dropped by our hero?
	var/turf/anchor_spot

/obj/item/toolboxcalibur/Initialize(mapload)
	. = ..()
	anchor_spot = get_turf(src)
	create_storage(storage_type = /datum/storage/toolbox)
	AddElement(/datum/element/cuffable_item) //It's a sword you were chosen to wield, you should be able to bind it to yourself.

/obj/item/toolboxcalibur/dropped(mob/user, silent)
	. = ..()
	anchor_spot = get_turf(src)
	icon_state = "toolboxcalibur_lame"
	update_appearance(UPDATE_ICON_STATE)

/obj/item/toolboxcalibur/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()
	if(user != chosen_owner)
		to_chat(user, span_warning("You are UNWORTHY of wielding Toolboxcalibur!"))
		user.dropItemToGround(anchor_spot, TRUE)
		user.Paralyze(3 SECONDS)
	else
		icon_state = "toolboxcalibur"
		update_appearance(UPDATE_ICON_STATE)

/obj/item/toolboxcalibur/proc/change_owner(mob/new_owner)
	chosen_owner = new_owner
	desc = (initial(src.desc) + " That hero is... The mighty " + span_hypnophrase("[chosen_owner.real_name]!"))
