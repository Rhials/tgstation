/datum/lazy_template/virtual_domain/explosive_lab
	name = "Explosive Lab"
	desc = ""
	help_text = "It looks like you'll have to blast your way to the goal crate, wherever it is... We don't have any professional explosives, but we do have \
		this state-of-the-art welding fuel tank dispenser!"
	key = "explosive_lab"
	map_name = "explosive_lab"
	reward_points = BITRUNNER_REWARD_LOW

///Copypasted from breeze bay, change this to be based on exploded fuel tanks maybe?? just a thought
/datum/lazy_template/virtual_domain/explosive_lab/setup_domain(list/created_atoms)
	. = ..()

	for(var/obj/item/fishing_rod/rod in created_atoms)
		RegisterSignal(rod, COMSIG_FISHING_ROD_CAUGHT_FISH, PROC_REF(on_fish_caught))

/datum/lazy_template/virtual_domain/explosive_lab/proc/on_fish_caught(datum/source, reward)
	SIGNAL_HANDLER

	if(isnull(reward))
		return

	add_points(2)
