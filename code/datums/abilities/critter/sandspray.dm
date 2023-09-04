//Sand spray attack for the sand stalker mob
/datum/targetable/critter/sandspray
	name = "Sand Spray"
	icon_state = "fire_e_flamethrower"
	desc = "Throw sand towards a target location up to three squares away."
	cooldown = 30
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1
		if (target && !isturf(target))
			target = get_turf(target)
		if (!target)
			return 1
		var/turf/OT = get_turf(holder.owner)
		var/it = 7
		while (GET_DIST(OT, target) > 3)
			target = get_step(target, get_dir(target, OT))
			it--
			if (it <= 0)
				return 1
		while (GET_DIST(OT, target) < 3)
			target = get_step(target, get_dir(OT, target))
			it--
			if (it <= 0)
				return 1
		if (target == holder.owner || target == OT)
			return 1
		playsound(target, 'sound/effects/spray.ogg', 50, 1, -1,1.5)
		var/list/L = getline(OT, target)
		for (var/turf/T in L)
			if (T == OT)
				continue
			for (var/mob/living/M in T)
				if (M.bioHolder?.HasEffect("blind") || M.isBlindImmune()) //check for blindness and blindness immunity
					return
				else if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.glasses && istype(H.glasses, /obj/item/clothing/glasses/)) //check for eye protection
						H.visible_message("[H]'s eyes are protected from the sand attack by the [H.glasses]!")
						return
					else
						continue
				M.take_eye_damage(pick(5, 10), 1)
				usr.visible_message("The [usr] kicks sand into [M]'s eyes!")
				logTheThing(LOG_COMBAT, usr, "used their [src.name] ability on [M] at [log_loc(usr)]")

		return 0
