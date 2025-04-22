/// A component added to a piece of clothing that, when loading a magazine, will send extra bullets into it per click.
/datum/component/magazine_quickloader

/datum/component/magazine_quickloader/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/component/magazine_quickloader/Destroy(force)
	return ..()

/datum/component/magazine_quickloader/proc/on_equip(atom/movable/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(~ITEM_SLOT_BACKPACK & slot)) //Check that the slot is valid for antimagic
		UnregisterSignal(equipper, COMSIG_LOADING_MAGAZINE)
		return

	RegisterSignal(equipper, COMSIG_LOADING_MAGAZINE, PROC_REF(on_load))

/datum/component/magazine_quickloader/proc/on_drop(atom/movable/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_LOADING_MAGAZINE)

/datum/component/magazine_quickloader/proc/on_load()
	SIGNAL_HANDLER
