///Ensures that the clown car properly dumps its occupants upon crashing into something appropriate.
/datum/unit_test/clown_car_crash
	var/mob/living/carbon/human/driver
	var/turf/closed/destination
	var/mob/living/basic/deer/deerstination
	var/obj/vehicle/sealed/car/clowncar/shitbox

/datum/unit_test/clown_car_crash/New()
	..()

	driver = new(locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z))

	destination = new(locate(run_loc_floor_bottom_left.x, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	deerstination = new(locate(run_loc_floor_top_right.x, run_loc_floor_top_right.y, run_loc_floor_top_right.z))

	shitbox = new(locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z))
	shitbox.enforce_clown_role = FALSE
	shitbox.mob_enter(driver)

/datum/unit_test/clown_car_crash/Destroy()
	qdel(driver)
	destination.ChangeTurf(/turf/open/floor/iron)
	qdel(deerstination)
	qdel(shitbox)
	return ..()

/datum/unit_test/clown_car_crash/Run()
	TEST_ASSERT_EQUAL(length(shitbox.occupants), 1, "Clown Car failed to get a driver!")

	//First test, see if slamming into a wall properly ends with dump_occupants
	driver.forceMove(destination)
	TEST_ASSERT_EQUAL(length(shitbox.occupants), 0, "Clown Car failed to eject occupants after bumping a wall!")

	//Do it again with the deer
	shitbox.mob_enter(driver)
	driver.forceMove(deerstination)
	TEST_ASSERT_EQUAL(length(shitbox.occupants), 0, "Clown Car failed to eject occupants after bumping a deer!")
