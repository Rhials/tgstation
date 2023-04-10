/obj/effect/anomaly/emp
	name = "electromagnetic anomaly"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bluespace"
	aSignal = /obj/item/assembly/signaler/anomaly/bluespace

/obj/effect/anomaly/emp/anomalyEffect()
	..()
	if(prob(3)) //Give off some smaller pulses before the big one
		empulse(epicenter = get_turf(src), heavy_range = 0, light_range = 8, log = TRUE)

/obj/effect/anomaly/emp/detonate()
	empulse(epicenter = get_turf(src), heavy_range = 9, light_range = 16, log = TRUE)

/obj/effect/anomaly/emp/emp_act(severity)
	. = ..()
	if(severity == EMP_HEAVY)
		visible_message(span_notice("The [name] hums for a moment, before abruptly dissapearing!"))
		anomalyNeutralize()

/obj/effect/anomaly/emp/attackby(obj/item/weapon, mob/user, params)
	. = ..()

	emp_act(severity = EMP_LIGHT)
	weapon.visible_message("The [weapon] hums deeply as you hold it against the [src]")
