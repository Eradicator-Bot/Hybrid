//Based on brullbar, sounds need replacing, directional sprites need making, fadeout needs reimplementing with mob appropriate sprites
/mob/living/critter/sand_stalker
	name = "sand stalker"
	real_name = "sand stalker"
	desc = "Oh god."
	density = 1
	icon_state = "sand_stalker"
	icon_state_dead = "sand_stalker-dead"
	custom_gib_handler = /proc/gibs
	hand_count = 2
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	blood_id = "LSD" //to really screw with people
	health_brute = 50
	health_brute_vuln = 0.6
	health_burn = 50
	health_burn_vuln = 1.3
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/brullbar
	is_npc = TRUE
	add_abilities = list(/datum/targetable/critter/tackle, /datum/targetable/critter/frenzy, /datum/targetable/critter/blood_bite, /datum/targetable/critter/sandspray)
	no_stamina_stuns = TRUE
	var/frenzypath = /datum/targetable/critter/frenzy

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (!isdead(src))
			return ..()

	on_pet()
		if (..())
			return TRUE
		if (prob(20) && !ON_COOLDOWN(src, "playsound", 3 SECONDS))
			playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 60, 1)
			src.visible_message("<span class='alert'><b>[src] squeals!</b></span>", 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/brullbar_roar.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b><span class='alert'>[src] screeches!</span></b>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_hands()
		..()

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		src.add_stam_mod_max("sand_stalker", 40)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "sand_stalker", 20)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "sand_stalker", 20)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/sand_stalker)) return FALSE //don't kill other sand stalkers
		if (ishuman(C))
			var/mob/living/carbon/human/H = C
			if(iswerewolf(H))
				src.visible_message("<span class='alert'><b>[src] backs away in fear!</b></span>")
				step_away(src, H, 15)
				src.set_dir(get_dir(src, H))
				return FALSE
		return ..()

	seek_target(var/range = 9)
		. = ..()

		if (length(.) && prob(10))
			playsound(src.loc, 'sound/voice/animal/brullbar_roar.ogg', 75, 1)
			src.visible_message("<span class='alert'><B>[src]</B> screeches!</span>")

	seek_scavenge_target(var/range = 9)
		. = list()
		for (var/mob/living/M in view(range, get_turf(src)))
			if (!isdead(M)) continue // eat everything yum
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.decomp_stage >= 3 || H.bioHolder?.HasEffect("husk")) continue //is dead, isn't a skeleton, isn't a grody husk
			. += M

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(src.frenzypath)
		var/datum/targetable/critter/tackle = src.abilityHolder.getAbility(/datum/targetable/critter/tackle)
		if (!tackle.disabled && tackle.cooldowncheck() && !is_incapacitated(target) && prob(30))
			tackle.handleCast(target) // no return to wack people with the frenzy after the tackle sometimes
			src.ai_attack_count = src.ai_attacks_per_ability //brullbars get to be evil and frenzy right away
			. = TRUE
		if (!frenzy.disabled && frenzy.cooldowncheck() && is_incapacitated(target) && prob(30))
			frenzy.handleCast(target)
			. = TRUE

	critter_basic_attack(mob/target)
		if (issilicon(target))
			fuck_up_silicons(target)
			return TRUE
		else
			return ..()

	critter_scavenge(var/mob/target)
		if (prob(30))
			src.visible_message("<span class='alert'><b>[src] devours [target]! Holy shit!</b></span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			if (ishuman(target)) new /obj/decal/fakeobjects/skeleton(target.loc)
			target.ghostize()
			target.gib()
			return
		else
			src.visible_message("<span class='alert'<b>[src] bites a chunk out of [target]!</b></span>")
			playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1)
			src.HealDamage("All", 8, 4)
			return

	can_critter_attack()
		var/datum/targetable/critter/frenzy = src.abilityHolder.getAbility(src.frenzypath)
		//var/datum/targetable/critter/fadeout = src.abilityHolder.getAbility(/datum/targetable/critter/fadeout/brullbar)
		return ..() && (!frenzy.disabled/* && !fadeout.disabled*/) // so they can't attack you while frenzying or while invisible (kinda)

	proc/fuck_up_silicons(var/mob/living/silicon/silicon) // modified orginal object critter behaviour scream
		if (isrobot(silicon) && !ON_COOLDOWN(src, "brullbar_messup_cyborg", 30 SECONDS))
			var/mob/living/silicon/robot/cyborg = silicon
			if (cyborg.part_head.ropart_get_damage_percentage() >= 85)
				src.visible_message("<span class='alert'><B>[src] grabs [cyborg.name]'s head and wrenches it right off!</B></span>")
				playsound(src.loc, 'sound/voice/animal/brullbar_laugh.ogg', 50, 1)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
				cyborg.compborg_lose_limb(cyborg.part_head)
			else
				src.visible_message("<span class='alert'><B>[src] pounds on [cyborg.name]'s head furiously!</B></span>")
				playsound(src.loc, 'sound/voice/animal/brullbar_scream.ogg', 60, 1)
				playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
				cyborg.part_head.ropart_take_damage(rand(20,40),0)
		else
			src.visible_message("<span class='alert'><B>[src] smashes [silicon] furiously!</B></span>")
			playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
			random_brute_damage(silicon, 15, 0)

	/*proc/go_invis()
		var/datum/targetable/critter/fadeout = src.abilityHolder.getAbility(/datum/targetable/critter/fadeout/brullbar)
		if (!fadeout.disabled && fadeout.cooldowncheck())
			fadeout.handleCast(src)*/

	death()
		..()
		playsound(src.loc, 'sound/voice/animal/brullbar_cry.ogg', 50, 1)
