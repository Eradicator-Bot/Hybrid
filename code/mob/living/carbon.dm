
/mob/living/carbon/
	gender = MALE // WOW RUDE
	var/last_eating = 0

	var/oxyloss = 0
	var/toxloss = 0
	var/brainloss = 0
	//var/brain_op_stage = 0
	//var/heart_op_stage = 0

	infra_luminosity = 4

/mob/living/carbon/New()
	START_TRACKING
	. = ..()

/mob/living/carbon/disposing()
	STOP_TRACKING
	stomach_contents = null
	..()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		//SLIP handling
		if (!src.throwing && !src.lying && isturf(NewLoc))
			var/turf/T = NewLoc
			if (T.turf_flags & MOB_SLIP)
				var/wet_adjusted = T.wet
				if (traitHolder?.hasTrait("super_slips") && T.wet) //non-zero wet
					wet_adjusted = max(wet_adjusted, 2) //whee

				switch (wet_adjusted)
					if (1) //ATM only the ancient mop does this
						if (locate(/obj/item/clothing/under/towel) in T)
							src.inertia_dir = 0
							T.wet = 0
							return
						if (src.slip())
							boutput(src, "<span class='notice'>You slipped on the wet floor!</span>")
							src.unlock_medal("I just cleaned that!", 1)
						else
							src.inertia_dir = 0
							return
					if (2) //lube
						src.remove_pulling()
						src.changeStatus("weakened", 3.5 SECONDS)
						boutput(src, "<span class='notice'>You slipped on the floor!</span>")
						playsound(T, 'sound/misc/slip.ogg', 50, 1, -3)
						var/atom/target = get_edge_target_turf(src, src.dir)
						src.throw_at(target, 12, 1, throw_type = THROW_SLIP)
					if (3) // superlube
						src.remove_pulling()
						src.changeStatus("weakened", 6 SECONDS)
						playsound(T, 'sound/misc/slip.ogg', 50, 1, -3)
						boutput(src, "<span class='notice'>You slipped on the floor!</span>")
						var/atom/target = get_edge_target_turf(src, src.dir)
						src.throw_at(target, 30, 1, throw_type = THROW_SLIP)
						random_brute_damage(src, 10)

		var/turf/T = NewLoc
		if(T.sticky)
			if(src.getStatusDuration("slowed")<1)
				boutput(src, "<span class='notice'>You get slowed down by the sticky floor!</span>")
			if(src.getStatusDuration("slowed")< 10 SECONDS)
				src.changeStatus("slowed", 2 SECONDS)

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='alert'>You hear something rumbling inside [src]'s stomach...</span>"), 2)
			var/obj/item/I = user.equipped()
			if(I?.force)
				var/d = rand(round(I.force / 4), I.force)
				src.TakeDamage("chest", d, 0)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='alert'><B>[user] attacks [src]'s stomach wall with the [I.name]!</span>"), 2)
				playsound(user.loc, 'sound/impact_sounds/Slimy_Hit_3.ogg', 50, 1)

				if(prob(get_brute_damage() - 50))
					logTheThing(LOG_COMBAT, user, "gibs [constructTarget(src,"combat")] breaking out of their stomach at [log_loc(src)].")
					src.gib()

/mob/living/carbon/gib(give_medal, include_ejectables)
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		if (!isobserver(M))
			src.visible_message("<span class='alert'><B>[M] bursts out of [src]!</B></span>")
		else if (istype(M, /mob/dead/target_observer))
			M.cancel_camera()

		M.set_loc(src.loc)
	. = ..(give_medal, include_ejectables)

/mob/living/carbon/swap_hand()
	var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
	if(B)
		qdel(B)
	src.hand = !src.hand

/mob/living/carbon/lastgasp(allow_dead=FALSE)
	..(allow_dead, grunt=pick("NGGH","OOF","UGH","ARGH","BLARGH","BLUH","URK") )


/mob/living/carbon/full_heal()
	src.take_toxin_damage(-INFINITY)
	src.take_oxygen_deprivation(-INFINITY)
	..()

/mob/living/carbon/take_brain_damage(var/amount)
	if (..())
		return

	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		amount *= -1

	src.brainloss = clamp(src.brainloss + amount, 0, 120)

	if (src.brainloss >= 120 && isalive(src))
		// instant death, we can assume a brain this damaged is no longer able to support life
		src.visible_message("<span class='alert'><b>[src.name]</b> goes limp, their facial expression utterly blank.</span>")
		src.death()
		return

	return

/mob/living/carbon/take_toxin_damage(var/amount)
	if (!toxloss && amount < 0)
		amount = 0
	if (..())
		return 1

	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		amount *= -1

	var/resist_toxic = src.bioHolder?.HasEffect("resist_toxic")

	if(resist_toxic && amount > 0)
		if(resist_toxic > 1)
			src.toxloss = 0
			return 1 //prevent organ damage
		else
			amount *= 0.33

	src.toxloss = max(0,src.toxloss + amount)
	return

/mob/living/carbon/take_oxygen_deprivation(var/amount)
	if (!oxyloss && amount < 0)
		return
	if (..())
		return

	if (HAS_ATOM_PROPERTY(src, PROP_MOB_BREATHLESS))
		src.oxyloss = 0
		return

	if (ispug(src))
		var/mob/living/carbon/human/H = src
		amount *= 2
		H.emote(pick("wheeze", "cough", "sputter"))

	src.oxyloss = max(0,src.oxyloss + amount)
	return

/mob/living/carbon/get_brain_damage()
	return src.brainloss

/mob/living/carbon/get_toxin_damage()
	return src.toxloss

/mob/living/carbon/get_oxygen_deprivation()
	return src.oxyloss

