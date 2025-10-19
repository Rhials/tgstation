#define TOOLBOXCALIBUR_WORTHY_FORCE 33
#define TOOLBOXCALIBUR_WORTHY_THROW_FORCE 45
#define TOOLBOXCALIBUR_WORTHY_WOUND_BONUS 30
#define TOOLBOXCALIBUR_WORTHY_ARMOR_PENETRATION 30
#define TOOLBOXCALIBUR_WORTHY_DEMOLITION_MOD 1.30
#define TOOLBOXCALIBUR_UNWORTHY_FORCE 10
#define TOOLBOXCALIBUR_UNWORTHY_THROW_FORCE 10
#define TOOLBOXCALIBUR_UNWORTHY_WOUND_BONUS 0
#define TOOLBOXCALIBUR_UNWORTHY_ARMOR_PENETRATION 0
#define TOOLBOXCALIBUR_UNWORTHY_DEMOLITION_MOD 0

///Sword-in-a-stone. Somehow ended up being a blunt weapon. Can only be removed by one active crewmember on the server. The "hero" is selected on the first attempt at removing it, so a proper list of candidates can be used instead of whoever was alive when the ruin generated.
///It became a toolbox sword at some point in the design. Not sure if I should keep calling it a sword?? I dunno man just roll with it.
/obj/structure/excalibur_mount
	name = "mysterious rock"
	desc = "A boulder with a curious looking weapon sticking out of it. Legends say that it can only be freed by a single, chosen member of the crew. Maybe that single, chosen member of the crew is YOU!"
	icon_state = "excalibur_mounted"
	resistance_flags = INDESTRUCTIBLE
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
		to_chat(living_user, span_alert("The sword doesn't budge. Perhaps someone <i>else</i> on the station is worthy of wielding such a blade?"))
		living_user.mind?.adjust_experience(/datum/skill/athletics, 4)
	else
		to_chat(living_user, span_alert("With a final tug, the sword slides out of the rock encasing it. You alone are worthy of wielding the mighty-- Hang on, is that a toolbox?"))
		released_sword = TRUE
		icon_state = "excalibur_mountless"
		living_user.mind?.adjust_experience(/datum/skill/athletics, 40) //A weapon such as this deserves a MIGHTY hero to wield it.
		var/obj/item/toolboxcalibur/released_toolbox = new(get_turf(src))
		released_toolbox.change_owner(living_user)
		living_user.put_in_active_hand(released_toolbox)
		resistance_flags = NONE //Now we can break the mount like normal.

/obj/structure/excalibur_mount/proc/select_hero()
	var/list/candidate_list = list()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list))
		//if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER)) ///Considering pirates/nukies/fugis/etc for being heros makes no sense. ///uncomment after testing
		//	continue
		candidate_list += candidate.client.ckey

/obj/item/toolboxcalibur
	name = "Toolboxcalibur"
	desc = "The mythical <b>Toolboxcalibur</b>. Its completely absurd design makes it near impossible to properly wield or swing in a fight. It is also so unfathomably heavy that even a glancing blow will obliterate its target. \
		Somehow, this evens it out to an above-average weapon. Only a single chosen hero amongst the crew can lift this weapon."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "toolboxcalibur_lame"
	inhand_icon_state = "toolboxcalibur"
	worn_icon = 'icons/obj/weapons/hammer.dmi'
	worn_icon_state = "toolboxcalibur_worn" //invert this //you made this even worse somehow?
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	attack_verb_simple = list("robust", "obliterate", "annihilate", "absolutely demolish")
	attack_verb_continuous = list("robusts", "obliterates", "annihilates", "absolutely demolishes")
	force = TOOLBOXCALIBUR_WORTHY_FORCE //start with the "worthy" values because in any possible intended case, the first pickup is always to its hero.
	throwforce = TOOLBOXCALIBUR_WORTHY_THROW_FORCE
	throw_range = 10
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/gold = SHEET_MATERIAL_AMOUNT)
	hitsound = 'sound/items/weapons/toolsword_slam.ogg'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_speed = CLICK_CD_VERY_SLOW
	wound_bonus = TOOLBOXCALIBUR_WORTHY_WOUND_BONUS
	armour_penetration = TOOLBOXCALIBUR_WORTHY_ARMOR_PENETRATION
	demolition_mod = TOOLBOXCALIBUR_WORTHY_DEMOLITION_MOD
	resistance_flags = INDESTRUCTIBLE
	///Who is our chosen hero, destined to wield us in glorious combat?
	var/mob/chosen_owner
	///Where were we last dropped by our hero?
	var/turf/anchor_spot

/obj/item/toolboxcalibur/Initialize(mapload)
	. = ..()
	name = span_holyflash("[name]")
	anchor_spot = get_turf(src)
	create_storage(storage_type = /datum/storage/toolbox)
	AddElement(/datum/element/cuffable_item) //It's a sword you were chosen to wield, why not let people bind it to themselves?

/obj/item/toolboxcalibur/dropped(mob/user, silent)
	. = ..()
	anchor_spot = get_turf(src)
	depower()

/obj/item/toolboxcalibur/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()
	if(!chosen_owner) //Well that shouldn't be happening. Maybe an admin spawned it in for someone?
		to_chat(user, span_warning("Suddenly binds itself to [user] as its chosen hero!"))
		change_owner(user)
	else
		if(user != chosen_owner)
			to_chat(user, span_warning("You are UNWORTHY of wielding [name]!"))
			user.dropItemToGround(newloc = anchor_spot, force = TRUE)
			user.Paralyze(3 SECONDS)

/obj/item/toolboxcalibur/proc/change_owner(mob/new_owner)
	chosen_owner = new_owner
	desc = (initial(src.desc) + " That hero is... The mighty " + span_holyflash("[chosen_owner.real_name]!"))
	empower()
	//do a mini empower here to update sprites

/obj/item/toolboxcalibur/proc/empower()
	visible_message(span_notice("[name] glows brightly as it is reunited with its chosen hero!"), blind_message = span_notice("The air fills with the smell of... [span_holyflash("heroism?")]"))
	icon_state = "toolboxcalibur"
	update_appearance(UPDATE_ICON_STATE)
	hitsound = 'sound/items/weapons/toolsword_slam.ogg'
	force = TOOLBOXCALIBUR_WORTHY_FORCE
	throwforce = TOOLBOXCALIBUR_WORTHY_THROW_FORCE //Do this after 1s delay so it can properly hit things at full power
	wound_bonus = TOOLBOXCALIBUR_WORTHY_WOUND_BONUS
	armour_penetration = TOOLBOXCALIBUR_WORTHY_ARMOR_PENETRATION
	demolition_mod = TOOLBOXCALIBUR_WORTHY_DEMOLITION_MOD

///Depowers the sword. Prevents unworthy from harnessing it's power through... unorthodox means...
/obj/item/toolboxcalibur/proc/depower()
	icon_state = "toolboxcalibur_lame"
	update_appearance(UPDATE_ICON_STATE)
	hitsound = 'sound/items/weapons/smash.ogg'
	force = TOOLBOXCALIBUR_UNWORTHY_FORCE
	throwforce = TOOLBOXCALIBUR_UNWORTHY_THROW_FORCE
	wound_bonus = TOOLBOXCALIBUR_UNWORTHY_WOUND_BONUS
	armour_penetration = TOOLBOXCALIBUR_UNWORTHY_ARMOR_PENETRATION
	demolition_mod = TOOLBOXCALIBUR_UNWORTHY_DEMOLITION_MOD

#undef TOOLBOXCALIBUR_WORTHY_FORCE
#undef TOOLBOXCALIBUR_WORTHY_THROW_FORCE
#undef TOOLBOXCALIBUR_WORTHY_WOUND_BONUS
#undef TOOLBOXCALIBUR_WORTHY_ARMOR_PENETRATION
#undef TOOLBOXCALIBUR_WORTHY_DEMOLITION_MOD
#undef TOOLBOXCALIBUR_UNWORTHY_FORCE
#undef TOOLBOXCALIBUR_UNWORTHY_THROW_FORCE
#undef TOOLBOXCALIBUR_UNWORTHY_WOUND_BONUS
#undef TOOLBOXCALIBUR_UNWORTHY_ARMOR_PENETRATION
#undef TOOLBOXCALIBUR_UNWORTHY_DEMOLITION_MOD
