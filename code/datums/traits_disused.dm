//UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW//


/*
/datum/trait/lizard
	desc = "You spawn as a lizard. Remember; you have no rights as a human if you choose this trait!"
	name = "Lizard"
	id = "lizard"
	points = -1
	isPositive = 1
	category = "race"

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_mutantrace(/datum/mutantrace/lizard)
		return
*/

/datum/trait/color_shift
	name = "Color Shift"
	desc = "You are more depressing on the outside but more colorful on the inside."
	id = "color_shift"
	unselectable = TRUE
	points = 0

	onAdd(var/mob/owner) //Not enforcing any of them with onLife because Hemochromia is a multi-mutation thing while Achromia would darken the skin color every tick until it's pitch black.
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("achromia", 0, 0, 0, 1)
			owner.bioHolder.AddEffect("hemochromia_unknown", 0, 0, 0, 1)

// Phobias - Undetermined Border

/datum/trait/phobia
	name = "Phobias suck"
	desc = "Wow, phobias are no fun! Report this to a coder please."
	unselectable = TRUE

/datum/trait/phobia/space
	name = "Spacephobia"
	desc = "Being in space scares you. A lot. While in space you might panic or faint."
	id = "spacephobia"
	points = 1

	onLife(var/mob/owner)
		if(!owner.stat && can_act(owner) && istype(owner.loc, /turf/space))
			if(prob(2))
				owner.emote("faint")
				owner.changeStatus("paralysis", 8 SECONDS)
			else if (prob(8))
				owner.emote("scream")
				owner.changeStatus("stunned", 2 SECONDS)


// People use this to identify changelings and people wearing disguises and I can't be bothered
// to rewrite a whole bunch of stuff for what is essentially something very specific and minor.
/datum/trait/observant
	name = "Observant"
	desc = "Examining people will show you their traits."
	id = "observant"
	points = -1
	unselectable = 1

/datum/trait/roboears
	name = "Robotic ears"
	desc = "You can hear, understand and speak robotic languages."
	id = "roboears"
	category = "body"
	points = -4
	unselectable = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.robot_talk_understand = 1
		return

	onLife(var/mob/owner) //Just to be safe.
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.robot_talk_understand = 1
		return
/*
	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.organHolder != null)
				H.organHolder.receive_organ(var/obj/item/I, var/type, var/op_stage = 0.0)
		return
*/

/datum/trait/deathwish
	name = "Death wish"
	desc = "You take double damage from most things and have half your normal health."
	id = "deathwish"
	category = "stats"
	points = 8
	unselectable = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health = 50
			H.health = 50
		return

	onLife(var/mob/owner) //Just to be safe.
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health = 50
		return

/datum/trait/glasscannon
	name = "Glass cannon"
	desc = "You have 1 stamina max. Attacks no longer cost you stamina and\nyou deal double the normal damage with most melee weapons."
	id = "glasscannon"
	category = "stats"
	points = -2
	unselectable = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.add_stam_mod_max("trait", -(STAMINA_MAX - 1))
		return

/datum/trait/soggy
	name = "Overly soggy"
	desc = "When you die you explode into gibs and drop everything you were carrying."
	id = "soggy"
	points = -1
	unselectable = 1

/datum/trait/reversal
	name = "Damage Reversal"
	desc = "You are now healed by things that would otherwise cause brute, burn, toxin, or brain damage. On the flipside, you are harmed by medicines."
	id = "reversal" //We can't have oxydamage in there, otherwise they'd immediately start suffocating.
	points = -1
	unselectable = 1

/datum/trait/badgenes
	name = "Bad Genes"
	desc = "You spawn with 2 random, permanent, bad mutations."
	id = "badgenes"
	points = 2
	category = "genetics"
	unselectable = 1

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			var/str = "I have the following bad mutations: "

			var/curr_id = owner.bioHolder.RandomEffect("bad", 1)
			var/datum/bioEffect/curr = owner.bioHolder.effects[curr_id]
			curr.curable_by_mutadone = 0
			curr.can_reclaim = 0
			curr.can_scramble = 0
			str += " [curr.name],"
			curr_id = owner.bioHolder.RandomEffect("bad", 1)
			curr = owner.bioHolder.effects[curr_id]
			curr.curable_by_mutadone = 0
			curr.can_reclaim = 0
			curr.can_scramble = 0
			str += " [curr.name]"

			SPAWN(4 SECONDS) owner.add_memory(str) //FUCK THIS SPAWN FUCK FUUUCK
		return

/datum/trait/goodgenes
	name = "Good Genes"
	desc = "You spawn with 2 random good mutations."
	id = "goodgenes"
	points = -3
	category = "genetics"
	unselectable = 1

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			var/str = "I have the following good mutations: "

			var/curr_id = owner.bioHolder.RandomEffect("good", 1)
			var/datum/bioEffect/curr = owner.bioHolder.effects[curr_id]
			str += " [curr.name],"
			curr_id = owner.bioHolder.RandomEffect("good", 1)
			curr = owner.bioHolder.effects[curr_id]
			str += " [curr.name]"

			SPAWN(4 SECONDS) owner.add_memory(str) //FUCK THIS SPAWN FUCK FUUUCK
		return

// Languages - Yellow Border

/datum/trait/swedish
	name = "Swedish"
	desc = "You are from sweden. Meat balls and so on."
	id = "swedish"
	icon_state = "swedenY"
	points = 0
	category = list("language")
	unselectable = TRUE

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_swedish", 0, 0, 0, 1)

/datum/trait/french
	name = "French"
	desc = "You are from Quebec. y'know, the other Canada."
	id = "french"
	icon_state = "frY"
	points = 0
	category = list("language")
	unselectable = TRUE

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_french", 0, 0, 0, 1)

/datum/trait/scots
	name = "Scottish"
	desc = "Hear the pipes are calling, down thro' the glen. Och aye!"
	id = "scottish"
	icon_state = "scott"
	points = 0
	category = list("language")
	unselectable = TRUE

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_scots", 0, 0, 0, 1)

/datum/trait/chav
	name = "Chav"
	desc = "U wot m8? I sware i'll fite u."
	id = "chav"
	icon_state = "ukY"
	points = 0
	category = list("language")
	unselectable = TRUE

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_chav", 0, 0, 0, 1)

/datum/trait/elvis
	name = "Funky Accent"
	desc = "Give a man a banana and he will clown for a day. Teach a man to clown and he will live in a cold dark corner of a space station for the rest of his days. - Elvis, probably."
	id = "elvis"
	icon_state = "elvis"
	points = 0
	category = list("language")
	unselectable = TRUE

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_elvis", 0, 0, 0, 1)

/datum/trait/tommy // please do not re-enable this without talking to spy tia
	name = "New Jersey Accent"
	desc = "Ha ha ha. What a story, Mark."
	id = "tommy"
	icon_state = "whatY"
	points = 0
	category = list("language")
	unselectable = TRUE // this was not supposed to be a common thing!!
/*
	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_tommy")
		return
*/

/datum/trait/finnish
	name = "Finnish Accent"
	desc = "...and you thought space didn't have Finns?"
	id = "finnish"
	icon_state = "finnish"
	points = 0
	category = list("language")
	unselectable = TRUE

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_finnish", 0, 0, 0, 1)

/datum/trait/tyke
	name = "Tyke"
	desc = "You're from Oop North in Yorkshire, and don't let anyone forget it!"
	id = "tyke"
	icon_state = "yorkshire"
	points = 0
	category = list("language")
	unselectable = TRUE

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_tyke")
