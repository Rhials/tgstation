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
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	living_user.take_damage(20, STAMINA)
	to_chat(living_user, span_notice("You begin yanking at the sword with all of your might..."))
	if(!do_after(living_user, 12 SECONDS, src))
		return
	living_user.take_damage(40, STAMINA)
	if(living_user.ckey == chosen_hero)
		to_chat(living_user, span_alert("The sword doesn't budge. Perhaps someone <i>else<i/> on the station is worthy of wielding such a blade?"))
		living_user.mind?.adjust_experience(/datum/skill/athletics, 4)
	else
		to_chat(living_user, span_alert("With a final tug, the sword slides out of the rock encasing it. You are worthy of wielding the mighty-- Hang on, is that a toolbox?"))
		released_sword = TRUE
		icon_state = "excalibur_mountless"
		living_user.mind?.adjust_experience(/datum/skill/athletics, 40) //A weapon such as this deserves a MIGHTY hero to wield it.
		living_user.put_in_active_hand(new /obj/item/toolboxcalibur(get_turf(src)))

/obj/structure/excalibur_mount/proc/select_hero()
	var/list/candidate_list = list()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list))
		//if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER)) ///uncomment after testing
		//	continue
		candidate_list += candidate.client.ckey

/obj/item/toolboxcalibur
	name = "Toolboxcalibur"
	desc = "A holy weapon of mythical rapport. It looks like it doesn't have an owner..."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "carpenter_hammer"
	inhand_icon_state = "carpenter_hammer"
	worn_icon_state = "clawhammer"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	force = 30
	throwforce = 40
	throw_range = 10
	w_class = WEIGHT_CLASS_NORMAL
	wound_bonus = 30
	demolition_mod = 1.15
	slot_flags = ITEM_SLOT_BELT
	///Who is our chosen hero, destined to wield us in glorious combat?
	var/mob/chosen_owner

/obj/item/toolboxcalibur/Initialize(mapload)
	. = ..()
	//AddElement(/datum/element/cuffable_item) //It's a sword you were chosen to wield, you should be able to bind it to yourself. Note, include a loop in the sprite for cuffing.

/obj/item/toolboxcalibur/proc/change_owner(mob/new_owner)
	chosen_owner = new_owner
	desc = ("The legendary <b>Toolboxcalibur</b>. It has selected a hero worthy enough to wield it... The mighty " + span_hypnophrase("[chosen_owner.real_name]!"))
