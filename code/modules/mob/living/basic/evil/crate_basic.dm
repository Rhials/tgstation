/mob/living/basic/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "crate"
	icon_living = "crate"

	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	speed = 0
	maxHealth = 250
	health = 250
	gender = NEUTER
	mob_biotypes = NONE
	pass_flags = PASSFLAPS

	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_sound = 'sound/weapons/punch1.ogg'
	speak_emote = list("creaks")

	faction = list("mimic")
	///A cap for items in the mimic. Prevents the mimic from eating enough stuff to cause lag when opened.
	var/storage_capacity = 50
	///A cap for mobs. Mobs count towards the item cap. Same purpose as above.
	var/mob_storage_capacity = 10
	///The turf this mob was initialized on. Will return to this turf if nearby and without targets
	var/turf/home

// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/basic/mimic/crate
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	speak_emote = list("clatters")
	var/attempt_open = FALSE

/mob/living/basic/mimic/crate/Initialize(mapload)
	. = ..()

	home = get_turf(src)

	if(mapload) //eat shit
		for(var/obj/item/contents in loc)
			contents.forceMove(src)

/mob/living/basic/mimic/crate/death()
	var/obj/structure/closet/crate/corpse = new(get_turf(src))
	// Put loot in crate
	for(var/obj/loot in src)
		loot.forceMove(corpse)
	..()
