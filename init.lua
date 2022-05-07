--[[

mcl_quick_harvest_replant – Minetest mod to harvest & replant crops with one right-click.
Copyright © 2022  Nils Dagsson Moskopp (erlehmann)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

Dieses Programm hat das Ziel, die Medienkompetenz der Leser zu
steigern. Gelegentlich packe ich sogar einen handfesten Buffer
Overflow oder eine Format String Vulnerability zwischen die anderen
Codezeilen und schreibe das auch nicht dran.

]]--

local farmland_crops = {
	"mcl_farming:beetroot",
	"mcl_farming:carrot",
	"mcl_farming:potato",
	"mcl_farming:wheat",
}

local soulsand_crops = {
	"mcl_nether:nether_wart",
}

local crop_node_names_by_item_name = {
	["mcl_farming:beetroot_seeds"] = farmland_crops,
	["mcl_farming:carrot_item"] = farmland_crops,
	["mcl_farming:potato_item"] = farmland_crops,
	["mcl_farming:wheat_seeds"] = farmland_crops,
	["mcl_nether:nether_wart_item"] = soulsand_crops,
}

local get_harvest_and_replant_function = function(
	crop_node_names,
	old_on_place
)
	return function(itemstack, placer, pointed_thing)
		local pointed_node_is_crop = false
		if "node" == pointed_thing.type then
			local pointed_node = minetest.get_node(
				pointed_thing.under
			)
			for i = 1,#crop_node_names do
				if string.match(
					pointed_node.name,
					"^" .. crop_node_names[i] .. "$"
				) then
					pointed_node_is_crop = true
				end
			end
		end
		if pointed_node_is_crop then
			minetest.dig_node(pointed_thing.under)
			local pos_under_crop_node = {
				x = pointed_thing.under.x,
				y = pointed_thing.under.y - 1,
				z = pointed_thing.under.z,
			}
			local pointed_ground = {
				type = "node",
				above = pointed_thing.under,
				under = pos_under_crop_node,
			}
			old_on_place(itemstack, placer, pointed_ground)
		else
			old_on_place(itemstack, placer, pointed_thing)
		end
	end
end

local add_harvest_and_replant_function = function()
	for item_name, item_def in pairs(minetest.registered_items) do
		local crop_node_names = crop_node_names_by_item_name[item_name]
		if nil ~= crop_node_names then
			local old_on_place = item_def.on_place
			local new_on_place = get_harvest_and_replant_function(
				crop_node_names,
				old_on_place
			)
			minetest.override_item(
				item_name,
				{
					on_place = new_on_place,
				}
			)
		end
	end
end

minetest.register_on_mods_loaded(add_harvest_and_replant_function)
