/*This file contains the special snowflake TESLA CANNON and its self chargy cheaty goodness
*/

/obj/item/weapon/gun/energy/tesla
	name = "Tesla Cannon"
	desc = "Cannon which uses electrical charge to damage multiple targets. Needs manual charging before using"
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "tesla"
	can_charge = 0
	var/charge = 0
	var/charging = 0
	var/cooldown = 0

/obj/item/weapon/gun/energy/tesla/proc/charge(mob/living/user as mob)
	spawn(1)
		if(do_after(user, 40))
			if(charging==1 && charge < 3)
				switch(charge)
					if(0)		icon_state="tesla_1"
					if(1)		icon_state="tesla_2"
					if(2)		icon_state="tesla_3"
				++charge
				playsound(loc, "sparks", 75, 1, -1)
				if(charging && charge < 3)
					charge(user)
				else
					charging=0
			else
				charging=0
		else
			user << "\red \italic Generator is too difficult to spin while moving! Charging aborted" // ITALIC GENERATOR ! Used for generating Italics
			charging=0



/obj/item/weapon/gun/energy/tesla/attack_self(mob/living/user as mob)
	if(charging==1)
		charging=0
		user << "\blue You stop charging Tesla Cannon..."
		cooldown = 1
		spawn(50)		cooldown = 0
		return
	if(cooldown)		return
	if(charge == 3)		return
	user.visible_message("\red \italic [user] starts spinning generator on Tesla Cannon!")
	user << "\blue You start charging Tesla Cannon..."
	charging=1
	charge(user)


/obj/item/weapon/gun/energy/tesla/process_fire(atom/pbtarget as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	if(!istype(pbtarget,/mob/living))
		user << "\red Tesla Cannon needs to be aimed directly at living target"
		return

	if(!charge)
		user << "\red Tesla Cannon is not charged!"
		return

	if(charging)
		user << "\red You can't shoot while charging!"
		return

	icon_state = "tesla"
	spawn(1)		user.Beam(pbtarget,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
	Bolt(user,pbtarget,user,charge)
	charge=0
	if(user)
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()
	feedback_add_details("gun_fired","[src.type]")

/obj/item/weapon/gun/energy/tesla/proc/los_check(mob/A,mob/B)
	for(var/atom/turf in getline(A,B))
		if(turf.density && !istype(turf,/obj/structure/table))
			return 0
	return 1

/obj/item/weapon/gun/energy/tesla/proc/Bolt(mob/origin,mob/target,mob/user = usr,jumps)
	spawn(1)		origin.Beam(target,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
	var/mob/living/carbon/current = target
	current.electrocute_act(15*(jumps+1),"electric bolt")
	playsound(get_turf(current), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	var/list/possible_targets = new
	for(var/mob/living/M in range(3,target))
		if(user == M || !los_check(current,M) || origin == M || current == M)
			continue
		possible_targets += M
	if(!possible_targets.len)
		return
	var/mob/living/next = pick(possible_targets)
	if(next && jumps > 0)
		Bolt(current,next,user,--jumps)
		--jumps