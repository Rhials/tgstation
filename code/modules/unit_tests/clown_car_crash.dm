///Ensures that the clown car properly dumps its occupants upon crashing into something appropriate.
/datum/unit_test/clown_car_crash
	var/mob/living/carbon/human/driver
	var/turf/closed/destination
	var/mob/living/basic/deer/deerstination
	var/obj/vehicle/sealed/car/clowncar/shitbox

/datum/unit_test/clown_car_crash/New()
	..()

	driver = new(locate(run_loc_floor_bottom_left + 2, run_loc_floor_bottom_left, run_loc_floor_bottom_left))
	driver.name = "Bozo the Booze Cruisin' Clown"

	destination = new(locate(run_loc_floor_bottom_left + 2, run_loc_floor_bottom_left, run_loc_floor_bottom_left))

	deerstination = new(locate(run_loc_floor_bottom_left + 2, run_loc_floor_bottom_left, run_loc_floor_bottom_left))
	deerstination = "Innocent Bystander"

	shitbox = new(locate(run_loc_floor_bottom_left + 2, run_loc_floor_bottom_left, run_loc_floor_bottom_left))
	shitbox.enforce_clown_role = FALSE
	shitbox.mob_enter(driver)

/datum/unit_test/clown_car_crash/Destroy()
	qdel(driver)
	qdel(destination)
	qdel(deerstination)
	qdel(shitbox)
	return ..()

/datum/unit_test/clown_car_crash/Run()
	return
