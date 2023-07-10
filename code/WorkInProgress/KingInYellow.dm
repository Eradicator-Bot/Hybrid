/obj/item/book_kinginyellow
	name = "\"The King In Yellow\""
	desc = ""
	icon = 'icons/obj/writing.dmi'
	icon_state = "bookkiy"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER

	var/list/readers = list()

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

	get_desc(var/dist, mob/user)
		if (!lastTooltipContent)
			// Okay, so here's a gross hack for you:
			// This gets called when generating a tooltip, which effectively
			// adds the user to the reader list even if they didn't examine it.
			// There's no way to tell if a user is examining it legitimately or if
			// the game is generating a tooltip just in case they do, so
			// in the case of a tooltip not existing, just. pretend nothing happens
			// This may not work properly if you have tooltips off but whatever
			return "<br>?????"

		if (!issilicon(user))
			var/mob/living/carbon/reader = user
			if (!istype(reader))
				return

			. = list()
			if (readers.len && (reader in readers))
				. += "<br>You frantically read the play again..."
				. += "You feel as if you're about to faint."
				reader.changeStatus("drowsy", 15 SECONDS)
			else
				. += "<br>This appears to be an ancient book containing a play."
				. += "The first act tells of a city named Carcosa, and a mysterious \"King in Yellow\"."
				. += "The second act seems incomplete, but... it is horrifying."

			return jointext(., "<br>")
		else
			. = "This ancient data storage medium appears to contain data used for entertainment purposes."
