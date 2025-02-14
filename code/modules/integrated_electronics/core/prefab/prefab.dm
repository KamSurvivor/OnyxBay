/decl/prefab/proc/create(atom/location)
	if(!location)
		CRASH("Invalid location supplied: [log_info_line(location)]")
	return TRUE

/decl/prefab/ic_assembly
	var/assembly_name
	var/data
	var/power_cell_type
	var/assembly_icon
	var/assembly_icon_state
	var/assembly_w_class

/decl/prefab/ic_assembly/create(atom/location)
	if(..())
		var/result = SScircuit.validate_electronic_assembly(data)
		if(istext(result))
			CRASH("Invalid prefab [type]: [result]")
		else
			var/obj/item/device/electronic_assembly/assembly = SScircuit.load_electronic_assembly(location, result)
			assembly.opened = FALSE
			if(assembly_icon)
				assembly.overlays.Cut()
				assembly.icon = assembly_icon
				assembly.icon_state = assembly_icon_state
			else
				assembly.update_icon()
			if(assembly_w_class)
				assembly.w_class = assembly_w_class
			if(power_cell_type)
				var/obj/item/weapon/cell/cell = new power_cell_type(assembly)
				assembly.battery = cell

			return assembly
	return null

/obj/prefab
	name = "prefab spawn"
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "landmark_circuit"
	var/prefab_type

/obj/prefab/Initialize()
	..()
	var/decl/prefab/prefab = decls_repository.get_decl(prefab_type)
	prefab.create(loc)
	return INITIALIZE_HINT_QDEL
