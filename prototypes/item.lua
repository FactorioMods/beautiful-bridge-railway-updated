
local bbr_rail_pictures_internal = function(elems)
	local keys = {{"straight_rail", "horizontal", 64, 128, 0, 0, true},
                {"straight_rail", "vertical", 128, 64, 0, 0, true},
                {"straight_rail", "diagonal-left-top", 96, 96, 0.5, 0.5, true},
                {"straight_rail", "diagonal-right-top", 96, 96, -0.5, 0.5, true},
                {"straight_rail", "diagonal-right-bottom", 96, 96, -0.5, -0.5, true},
                {"straight_rail", "diagonal-left-bottom", 96, 96, 0.5, -0.5, true},
                {"curved_rail", "vertical-left-top", 192, 288, 0.5, 0.5},
                {"curved_rail", "vertical-right-top", 192, 288, -0.5, 0.5},
                {"curved_rail", "vertical-right-bottom", 192, 288, -0.5, -0.5},
                {"curved_rail", "vertical-left-bottom", 192, 288, 0.5, -0.5},
                {"curved_rail" ,"horizontal-left-top", 288, 192, 0.5, 0.5},
                {"curved_rail" ,"horizontal-right-top", 288, 192, -0.5, 0.5},
                {"curved_rail" ,"horizontal-right-bottom", 288, 192, -0.5, -0.5},
                {"curved_rail" ,"horizontal-left-bottom", 288, 192, 0.5, -0.5}}
	local res = {}
	local g_path
	for _ , key in ipairs(keys) do
		part = {}
		dashkey = key[1]:gsub("_", "-")
		for _ , elem in ipairs(elems) do
			if elem.id then
				g_path = "__beautiful-bridge-railway-updated__"
				footer = "-"..elem.id
			else
				g_path = "__base__"
				footer = ""
			end
			part[elem[1]] = {
				filename = string.format("%s/graphics/entity/%s/%s-%s-%s%s.png",g_path, dashkey, dashkey, key[2], elem[2], footer),
				priority = elem.priority or "extra-high",
				flags = elem.mipmap and { "icon" } or { "low-object" },
				width = key[3],
				height = key[4],
				shift = {key[5], key[6]},
				variation_count = (key[7] and elem.variations) or 1,
				hr_version = {
					filename = string.format("%s/graphics/entity/%s/hr-%s-%s-%s%s.png",g_path, dashkey, dashkey, key[2], elem[2], footer),
					priority = elem.priority or "extra-high",
					flags = elem.mipmap and { "icon" } or { "low-object" },
					width = key[3]*2,
					height = key[4]*2,
					shift = {key[5], key[6]},
					scale = 0.5,
					variation_count = (key[7] and elem.variations) or 1,
				}
			}
		end
		dashkey2 = key[2]:gsub("-", "_")
		res[key[1] .. "_" .. dashkey2] = part
	end

	res["rail_endings"] = { sheets = {
		{
			filename = "__base__/graphics/entity/rail-endings/rail-endings-background.png",
			priority = "high",
			flags = { "low-object" },
			width = 128,
			height = 128,
			hr_version = {
				filename = "__base__/graphics/entity/rail-endings/hr-rail-endings-background.png",
				priority = "high",
				flags = { "low-object" },
				width = 256,
				height = 256,
				scale = 0.5
			}
		},
		{
			filename = "__base__/graphics/entity/rail-endings/rail-endings-metals.png",
			priority = "high",
			flags = { "icon" },
			width = 128,
			height = 128,
			hr_version = {
				filename = "__base__/graphics/entity/rail-endings/hr-rail-endings-metals.png",
				priority = "high",
				flags = { "icon" },
				width = 256,
				height = 256,
				scale = 0.5
			}
		}
	}}
	return res
end

local bbr_rail_pictures = function(id)
	return bbr_rail_pictures_internal({{"metals", "metals", mipmap = true},
									{"backplates", "backplates", mipmap = true},
									{"ties", "ties", variations = 3},
									{"stone_path", "stone-path", variations = 3, id = id},
									{"stone_path_background", "stone-path-background", variations = 3, id = id},
									{"segment_visualisation_middle", "segment-visualisation-middle"},
									{"segment_visualisation_ending_front", "segment-visualisation-ending-1"},
									{"segment_visualisation_ending_back", "segment-visualisation-ending-2"},
									{"segment_visualisation_continuing_front", "segment-visualisation-continuing-1"},
									{"segment_visualisation_continuing_back", "segment-visualisation-continuing-2"}
									})
end

-- Preserve legacy rail geometry and custom bridge beds in the 2.x picture schema.
local old_bridge_pictures = bbr_rail_pictures
bbr_rail_pictures = function(id, rail_type)
 local old=old_bridge_pictures(id)
 local result=table.deepcopy(data.raw[rail_type][rail_type].pictures)
 local straight={north="vertical",northeast="diagonal_right_top",east="horizontal",southeast="diagonal_right_bottom",south="vertical",southwest="diagonal_left_bottom",west="horizontal",northwest="diagonal_left_top"}
 local curved={north="vertical_left_bottom",northeast="vertical_right_bottom",east="horizontal_left_top",southeast="horizontal_left_bottom",south="vertical_right_top",southwest="vertical_left_top",west="horizontal_right_bottom",northwest="horizontal_right_top"}
 local kind=rail_type=="legacy-straight-rail" and "straight_rail" or "curved_rail"
 for direction,key in pairs(kind=="straight_rail" and straight or curved) do
  local original=old[kind.."_"..key]
  for _,layer in pairs({"stone_path","stone_path_background"}) do
   local sprite=original[layer]
   result[direction][layer]=sprite.hr_version or sprite
   result[direction][layer].hr_version=nil
  end
 end
 return result
end

-- add fast_replaceable_group to vanilla rail
-- data.raw["legacy-straight-rail"]["legacy-straight-rail"].fast_replaceable_group = "straight-rail"
-- data.raw["legacy-curved-rail"]["legacy-curved-rail"].fast_replaceable_group = "curved-rail"

local ptype
local holder = {}
local bridges = {
	wood = {
		order = "a[train-system]-az-a",
		ingredients = {
			{"wood", 1}, {"iron-stick", 1}, {"steel-plate", 1}
		},
		overlay_icon = "wood.png"
	},
	iron = {
		order = "a[train-system]-az-b",
		ingredients = {
			{"iron-plate", 1}, {"iron-stick", 1}, {"steel-plate", 1}
		},
		overlay_icon = "steel-plate.png",
		tint = {r=0.7, g=0.3, b=0.3, a=1}
	},
	brick = {
		order = "a[train-system]-az-c",
		ingredients = {
			{"stone-brick", 1}, {"iron-stick", 1}, {"steel-plate", 1}
		},
		overlay_icon = "stone-brick.png"
	}
}

for id, param in pairs(bridges) do

-- recipe
	ptype = table.deepcopy(data.raw["recipe"]["rail"])
	ptype.name = "bbr-rail-"..id
	ptype.ingredients = param.ingredients
	ptype.result = "bbr-rail-"..id
	table.insert(holder, ptype)

-- item
	ptype = table.deepcopy(data.raw["rail-planner"]["rail"])
	ptype.name = "bbr-rail-"..id
	ptype.localised_name = {"entity-name."..ptype.name}
	ptype.icons = {
		{ icon = ptype.icon },
		{
			icon = "__base__/graphics/icons/"..param.overlay_icon ,
			scale = 0.4,
			shift = {6, -6},
			tint = param.tint
		}
	}
	ptype.order = string.format("%s[%s]", param.order, ptype.name)
	ptype.place_result = "bbr-straight-rail-"..id
	ptype.straight_rail = "bbr-straight-rail-"..id
	ptype.rails = {"bbr-straight-rail-"..id,"bbr-curved-rail-"..id}
	table.insert(holder, ptype)

-- straight-rail
	ptype = table.deepcopy(data.raw["legacy-straight-rail"]["legacy-straight-rail"])
	ptype.name = "bbr-straight-rail-"..id
	ptype.collision_mask = {layers={object=true}}
	ptype.minable.result = "bbr-rail-"..id
	ptype.pictures = bbr_rail_pictures(id, ptype.type)
	ptype.icons = {
		{ icon = ptype.icon },
		{
			icon = "__base__/graphics/icons/"..param.overlay_icon ,
			scale = 0.4,
			shift = {6, -6},
			tint = param.tint
		}
	}
	table.insert(holder, ptype)

-- curved-rail
	ptype = table.deepcopy(data.raw["legacy-curved-rail"]["legacy-curved-rail"])
	ptype.name = "bbr-curved-rail-"..id
	ptype.collision_mask = {layers={object=true}}
	ptype.minable.result = "bbr-rail-"..id
	ptype.placeable_by.item="bbr-rail-"..id
	ptype.pictures = bbr_rail_pictures(id, ptype.type)
	ptype.icons = {
		{ icon = ptype.icon },
		{
			icon = "__base__/graphics/icons/"..param.overlay_icon ,
			scale = 0.4,
			shift = {6, -6},
			tint = param.tint
		}
	}
	table.insert(holder, ptype)
end

data:extend(holder)


-- move to data-updates.lua because will not be overwritten by other mods
--[[
-- change default entity to placeable on water
data.raw["rail-signal"]["rail-signal"].collision_mask = {layers={rail=true}}
data.raw["rail-chain-signal"]["rail-chain-signal"].collision_mask = {layers={rail=true}}

-- data.raw["electric-pole"]["small-electric-pole"].collision_mask = {layers={object=true}}
-- data.raw["electric-pole"]["medium-electric-pole"].collision_mask = {layers={object=true}}
data.raw["electric-pole"]["big-electric-pole"].collision_mask = {layers={object=true}}
]]--

for _,recipe in pairs(data.raw.recipe) do
 if string.sub(recipe.name,1,4)=="bbr-" then
  for _,i in pairs(recipe.ingredients or {}) do if i[1] then i.type="item";i.name=i[1];i.amount=i[2];i[1]=nil;i[2]=nil end end
  recipe.results={{type="item",name=recipe.result,amount=recipe.result_count or 1}};recipe.result=nil;recipe.result_count=nil
 end
end
