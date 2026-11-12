local migration_state = require("migration-state")

runOnce = false

script.on_event(defines.events.on_tick, function(event)
	if runOnce then return end
	runOnce = true
	if remote.interfaces.RailPowerSystem and remote.interfaces.RailPowerSystem.addRail then
		local bridges = { "wood", "iron", "brick" }
		for i, id in ipairs(bridges) do
			remote.call("RailPowerSystem", "addRail", "bbr-straight-rail-electric-"..id, "bbr-curved-rail-electric-"..id)
		end
	end
end)

local function cycle_blueprint(player)
	if player then
		local bprint = player.cursor_stack
		while bprint and bprint.valid and bprint.valid_for_read and bprint.is_blueprint_book do
            local inventory=bprint.get_inventory(defines.inventory.item_main)
            local active=bprint.active_index
            bprint=inventory and active and active>=1 and active<=#inventory and inventory[active] or nil
        end
        if bprint and bprint.valid and bprint.valid_for_read and bprint.is_blueprint and bprint.is_blueprint_setup() then
			replace_blueprint_rails(player, bprint)
		end
	end
end
script.on_event("kap-bbr-cycle-key", function(event) cycle_blueprint(game.players[event.player_index]) end)

function get_replace_list(entities)
 local index={}
 local s_rails,c_rails,rail_counts,rail_nums={},{},{},{}
 local function add_pair(name,straight,curved,local_name)
  table.insert(index,{name=name,straight_rail=straight,curved_rail=curved,local_name=local_name})
  s_rails[straight]=true;c_rails[curved]=true;rail_counts[name]=0
  rail_nums[straight]={name=name,num=1};rail_nums[curved]={name=name,num=4}
 end
 -- Preserve legacy blueprint geometry; modern 2.x curves have different geometry.
 if prototypes.entity["legacy-straight-rail"] and prototypes.entity["legacy-curved-rail"] then
  add_pair("rail","legacy-straight-rail","legacy-curved-rail",prototypes.item.rail.localised_name)
 end
 for name,item in pairs(prototypes.item) do
  if item.type=="rail-planner" then
   local straight,curved
   for _,rail in pairs(item.rails or {}) do
    if rail.type=="legacy-straight-rail" then straight=rail.name
    elseif rail.type=="legacy-curved-rail" then curved=rail.name end
   end
   if straight and curved then add_pair(name,straight,curved,item.localised_name) end
  end
 end
 table.sort(index,function(a,b) return a.name<b.name end)
 for _,entity in pairs(entities) do
  local rail=rail_nums[entity.name]
  if rail then rail_counts[rail.name]=rail_counts[rail.name]+rail.num end
 end
 local selected,maximum
 for _,entry in ipairs(index) do
  local count=rail_counts[entry.name]
  if count>0 and (not maximum or count>maximum) then selected=entry.name;maximum=count end
 end
 if not selected then return end
 for i,entry in ipairs(index) do
  if entry.name==selected then
   local next_entry=index[i % #index+1]
   return {[next_entry.straight_rail]=s_rails,[next_entry.curved_rail]=c_rails},next_entry.local_name
  end
 end
end


function replace_blueprint_rails(player, bprint)
	local entities = bprint.get_blueprint_entities()
	if entities then
		local is_replace = false
		local lists, replace_name = get_replace_list(entities)
		if lists then
			for r_to, r_from in pairs(lists) do
			    for k, entity in pairs (entities) do
					if r_from[entity.name] then
						is_replace = true
						entities[k].name = r_to
					end
				end
			end
			bprint.set_blueprint_entities(entities)
		end
		if is_replace then
			player.print(replace_name)
		end
	end
end


script.on_init(function() migration_state.adopt() end)
script.on_configuration_changed(function() migration_state.adopt() end)
