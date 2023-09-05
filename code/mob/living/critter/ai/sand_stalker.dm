/datum/aiHolder/sand_stalker
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/sand_stalker, list(src))

/datum/aiTask/prioritizer/critter/sand_stalker/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/range_attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))
