/// Boons. Like smites, but beneficial. For the
/datum/boon
	/// The name of the boon
	var/name
	/// Flags which modify how the boon fires. Still uses the smite flags.
	var/boon_flags = NONE
	/// Should this smite write to logs?
	var/should_log = TRUE

/// Called once after either choosing the option to smite a player, or when selected in smite build mode.
/// Use this to prompt the user configuration options.
/// Return FALSE if the smite should not be used.
/datum/boon/proc/configure(client/user)

/// Invoked externally to actually perform the smite
/datum/boon/proc/do_effect(client/user, mob/living/target)
	if(boon_flags & SMITE_DIVINE)
		playsound(target, 'sound/effects/pray.ogg', 50, FALSE, -1)
		target.apply_status_effect(
			/datum/status_effect/spotlight_light/divine,
			3 SECONDS,
			mutable_appearance('icons/mob/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER),
		)

	if(boon_flags & SMITE_DELAY)
		addtimer(CALLBACK(src, PROC_REF(delayed_effect), user, target), 2 SECONDS, TIMER_UNIQUE)
	else
		effect(user, target)

/// Called after a delay if the boon has the SMITE_DELAY flag
/datum/boon/proc/delayed_effect(client/user, mob/living/target)
	if(QDELETED(target))
		return
	effect(user, target)

/// The effect of the smite, make sure to call this in your own smites
/datum/boon/proc/effect(client/user, mob/living/target)
	if (should_log)
		user.boon_log(target, name)
