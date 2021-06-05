/obj/screen/splash
	name = "Baystation12"
	desc = "This shouldn't be read."
	screen_loc = "WEST,SOUTH"
	icon = 'maps/exodus/exodus_lobby.dmi'
	icon_state = "title"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	var/client/holder

/obj/screen/splash/New(client/C, visible) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()

	holder = C

	if(!visible)
		alpha = 0

	holder.screen += src
	icon_state = ""
	icon = config.current_lobbyscreen

/obj/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/obj/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()

/mob/new_player/Login()
	SHOULD_CALL_PARENT(FALSE)
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>")
	client.show_regular_announcement()
	to_chat(src, "<div class='info'>Game ID: <div class='danger'>[game_id]</div></div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	loc = null
	new /obj/screen/splash(client, TRUE)
	my_client = client
	set_sight(sight|SEE_TURFS)
	GLOB.player_list |= src
	new_player_panel()

	if(!SScharacter_setup.initialized)
		SScharacter_setup.newplayers_requiring_init += src
	else
		deferred_login()

// This is called when the charcter setup system has been sufficiently initialized and prefs are available.
// Do not make any calls in mob/Login which may require prefs having been loaded.
// It is safe to assume that any UI or sound related calls will fall into that category.
/mob/new_player/proc/deferred_login()
	if(client)
		client.playtitlemusic()

	var/decl/security_state/security_state = GLOB.using_map.security_state
	var/decl/security_level/SL = security_state.current_security_level
	to_chat(src, SPAN("notice", "The alert level on the [station_name()] is currently: <font color=[SL.light_color_alarm]><B>[SL.name]</B></font>."))
