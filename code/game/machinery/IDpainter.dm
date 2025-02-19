/obj/machinery/idpainter
	name = "ID painter"
	desc = "An ID painting machine. To use, simply insert your ID card and choose the desired preset paint scheme."
	icon = 'icons/obj/machines/idpainter.dmi'
	icon_state = "idpainter"
	density = TRUE
	anchored = TRUE
	//ghost_must_be_admin = TRUE
	var/obj/item/weapon/card/id/storedcard = null
	var/list/radial_chooses



/obj/machinery/idpainter/update_icon()
	cut_overlays()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(storedcard)
		add_overlay("[initial(icon_state)]-closed")

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/idpainter/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/card/id))
		if(storedcard)
			to_chat(user, "There is already a card inside.")
			return
		else
			var/obj/item/weapon/card/id/C = usr.get_active_hand()
			if(istype(C))
				user.drop_from_inventory(C, src)
				storedcard = C
				C.add_fingerprint(usr)
				update_icon()
				if(ishuman(usr))
					var/mob/living/carbon/human/H = usr
					H.sec_hud_set_ID()
	else
		if(iswrenching(O))
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")


/obj/machinery/idpainter/attack_hand(mob/user)
	if(..())
		return

	if(storedcard)
		if(!radial_chooses)
			radial_chooses = list()
			for(var/P in typesof(/obj/item/weapon/card/id))
				var/obj/item/weapon/card/id/C = new P
				if(C.customizable_view == UNIVERSAL_VIEW)
					radial_chooses[C] = image(icon = C.icon, icon_state = initial(C.icon_state))

		var/obj/item/weapon/card/id/C = show_radial_menu(user, src, radial_chooses, require_near = TRUE)
		if(!C)
			return

		storedcard.icon = 'icons/obj/card.dmi'
		storedcard.item_state_inventory = initial(C.icon_state)
		storedcard.item_state_world = C.item_state_world
		storedcard.desc = C.desc
		storedcard.update_world_icon()

	else
		to_chat(user, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/idpainter/verb/ejectid()
	set name = "Eject ID"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return

	if(storedcard)
		storedcard.loc = get_turf(src.loc)
		storedcard = null
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/idpainter/power_change()
	..()
	update_icon()
