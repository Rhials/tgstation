// 40mm (Grenade Launcher

/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 1, adminlog = FALSE, explosion_cause = src)
	return BULLET_ACT_HIT

// 3mm (Skullgun)

/obj/projectile/bullet/a3mm
	name = "3mm micro-caliber cartridge"
	desc = "small, but packs a punch."
	icon_state= "bolter"
	damage = 5
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 3, flame_range = 5, flash_range = 3, explosion_cause = src)
	return BULLET_ACT_HIT
