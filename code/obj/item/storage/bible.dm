// rest in peace the_very_holy_global_bible_list_amen (??? - 2020)

/obj/item/bible
	name = "bible"
	desc = "A holy scripture of some sort or another. Someone seems to have hollowed it out for hiding things in."
	icon = 'icons/obj/items/storage.dmi'
	icon_state ="bible"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | NOSPLASH
	event_handler_flags = USE_FLUID_ENTER
	var/mob/affecting = null
	var/heal_amt = 10

	New()
		..()
		src.create_storage(/datum/storage/bible, max_wclass = W_CLASS_SMALL)
		START_TRACKING
		#ifdef SECRETS_ENABLED
		ritualComponent = new/datum/ritualComponent/sanctus(src)
		ritualComponent.autoActive = 1
		#endif
		BLOCK_SETUP(BLOCK_BOOK)

	disposing()
		..()
		STOP_TRACKING

	proc/bless(mob/M as mob, var/mob/user)
		if (isvampire(M) || isvampiricthrall(M) || iswraith(M) || M.bioHolder.HasEffect("revenant"))
			M.visible_message("<span class='alert'><B>[M] burns!</span>", 1)
			var/zone = "chest"
			if (user.zone_sel)
				zone = user.zone_sel.selecting
			M.TakeDamage(zone, 0, heal_amt)
			JOB_XP(user, "Chaplain", 2)
		else
			var/mob/living/H = M
			if( istype(H) )
				if( prob(25) )
					H.delStatus("bloodcurse")
					H.cure_disease_by_path(/datum/ailment/disease/cluwneing_around/cluwne)
				if(prob(25))
					H.cure_disease_by_path(/datum/ailment/disability/clumsy/cluwne)
				//Wraith curses
				if(prob(75) && ishuman(H))
					var/mob/living/carbon/human/target = H
					if(target.bioHolder?.HasEffect("blood_curse") || target.bioHolder?.HasEffect("blind_curse") || target.bioHolder?.HasEffect("weak_curse") || target.bioHolder?.HasEffect("rot_curse") || target.bioHolder?.HasEffect("death_curse"))
						target.bioHolder.RemoveEffect("blood_curse")
						target.bioHolder.RemoveEffect("blind_curse")
						target.bioHolder.RemoveEffect("weak_curse")
						target.bioHolder.RemoveEffect("rot_curse")
						target.bioHolder.RemoveEffect("death_curse")
						target.visible_message("[target] screams as some black smoke exits their body.")
						target.emote("scream")
						var/turf/T = get_turf(target)
						if (T && isturf(T))
							var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(T)
							if (S)
								S.set_up(5, 0, T, null, "#000000")
								S.start()
			M.HealDamage("All", heal_amt, heal_amt)
			if(prob(40))
				JOB_XP(user, "Chaplain", 1)

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/bible))
			user.show_text("You try to put \the [W] in \the [src]. It doesn't work. You feel dumber.", "red")
		else
			..()

	attack(mob/M, mob/user)
		var/chaplain = 0
		if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain"))
			chaplain = 1
		if (!chaplain)
			boutput(user, "<span class='alert'>The book sizzles in your hands.</span>")
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, 10)
			return
		if (user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles and drops [src] on [his_or_her(user)] foot.</span>")
			random_brute_damage(user, 10)
			user.changeStatus("stunned", 3 SECONDS)
			JOB_XP(user, "Clown", 1)
			return

		if (iswraith(M) || (M.bioHolder && M.bioHolder.HasEffect("revenant")))
			M.visible_message("<span class='alert'><B>[user] smites [M] with the [src]!</B></span>")
			bless(M, user)
			boutput(M, "<span_class='alert'><B>IT BURNS!</B></span>")
			logTheThing(LOG_COMBAT, user, "biblically smote [constructTarget(M,"combat")]")

		else if (!isdead(M))
			// ******* Check
			var/is_undead = isvampire(M) || iswraith(M) || M.bioHolder.HasEffect("revenant")
			var/is_atheist = M.traitHolder?.hasTrait("atheist")
			if (ishuman(M) && prob(60) && !(is_atheist && !is_undead))
				bless(M, user)
				M.visible_message("<span class='alert'><B>[user] heals [M] with the power of Christ!</B></span>")
				var/deity = is_atheist ? "a god you don't believe in" : "Christ"
				boutput(M, "<span class='alert'>May the power of [deity] compel you to be healed!</span>")
				var/healed = is_undead ? "damaged undead" : "healed"
				logTheThing(LOG_COMBAT, user, "biblically [healed] [constructTarget(M,"combat")]")

			else
				var/damage = 10 - clamp(M.get_melee_protection("head", DAMAGE_BLUNT) - 1, 0, 10)
				if (is_atheist)
					damage /= 2

				M.take_brain_damage(damage)
				boutput(M, "<span class='alert'>You feel dazed from the blow to the head.</span>")
				logTheThing(LOG_COMBAT, user, "biblically injured [constructTarget(M,"combat")]")
				M.visible_message("<span class='alert'><B>[user] beats [M] over the head with [src]!</B></span>")

		else if (isdead(M))
			M.visible_message("<span class='alert'><B>[user] smacks [M]'s lifeless corpse with [src].</B></span>")

		if (narrator_mode)
			playsound(src.loc, 'sound/vox/hit.ogg', 25, 1, -1)
		else
			playsound(src.loc, "punch", 25, 1, -1)

		return

	attack_hand(var/mob/user)
		if (isvampire(user) || user.bioHolder.HasEffect("revenant"))
			user.visible_message("<span class='alert'><B>[user] tries to take the [src], but their hand bursts into flames!</B></span>", "<span class='alert'><b>Your hand bursts into flames as you try to take the [src]! It burns!</b></span>")
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, 25)
			user.changeStatus("stunned", 15 SECONDS)
			user.changeStatus("weakened", 15 SECONDS)
			return
		return ..()

/obj/item/bible/mini
	//Grif
	name = "O.C. Bible"
	desc = "For when you don't want the good book to take up too much space in your life."
	icon_state = "minibible"
	item_state = null
	w_class = W_CLASS_SMALL

/obj/item/bible/loaded

	New()
		..()
		new /obj/item/gun/kinetic/faith(src)
		desc += " This is the chaplain's personal copy."

	get_desc()
		. = ..()
		if (locate(/obj/item/gun/kinetic/faith) in src.contents)
			. += " It feels a bit heavier than it should."

	attack_hand(mob/user)
		if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain") && user.is_in_hands(src))
			var/obj/item/gun/kinetic/faith/F = locate() in src.contents
			if(F)
				user.put_in_hand_or_drop(F)
				return
		..()

	attackby(var/obj/item/W, var/mob/user)
		if(istype(W,/obj/item/gun/kinetic/faith))
			if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain"))
				user.u_equip(W)
				W.set_loc(src)
				user.show_text("You hide [W] in \the [src].", "blue")
				return
		..()
