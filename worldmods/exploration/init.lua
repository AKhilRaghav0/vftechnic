local isui = minetest.get_modpath("unified_inventory")

--[[
local jailpos = {x=-704.5, y=19.5, z=-812};
local jailradius = 10;
--]]

local freepos = {x=-900, y=24, z=-1189};
local jailpos = {x=28435, y=-30909, z=1866};
local jailradius = 200;

spawn_command = {}
spawn_command.pos = {-900,24,-1189}
-- local freepos = {x=spawn_command.pos[0], y=spawn_command.pos[1], z=spawn_command.pos[2]};


-- https://forum.minetest.net/viewtopic.php?t=18808
-- local LAVA_PLACE_DEPTH = -50
-- minetest.register_privilege("lava", "Allows placing lava")
-- function allow_place_lava( pos, player )
--         if pos.y > LAVA_PLACE_DEPTH and not minetest.check_player_privs( player, "lava" ) then
--                 minetest.chat_send_player( player:get_player_name( ), "You are not allowed to place lava above " .. LAVA_PLACE_DEPTH .. "!" )
--                 minetest.log( "action", player:get_player_name( ) .. " tried to place default:lava_source above " .. LAVA_PLACE_DEPTH )
--                 return false
--         end
--         return true
-- end
-- minetest.override_item( "bucket:bucket_lava", {
--         allow_place = allow_place_lava
-- } )
-- minetest.override_item( "default:lava_source", {
--         allow_place = allow_place_lava
-- } )

-- https://forum.minetest.net/viewtopic.php?t=16862
minetest.register_chatcommand("whatisthis", {
	description = "Prints the item string of the object you are currently holding.",
	func=function(name)
	return true,"You are holding:"..
	minetest.get_player_by_name(name):get_wielded_item():get_name()
	end,
})

-- bls rollback check
minetest.register_privilege("rollback_check", "Allows use of /rollback_check")
minetest.override_chatcommand("rollback_check", {
    privs = {rollback_check=true}
})
-- allow regular players access to limited rollback checking
minetest.register_chatcommand("grief_check", {
    description = "Check who last touched a node or a node near it",
    func = function(name)
        return minetest.registered_chatcommands["rollback_check"].func(
            name,
            "1 1209600 10"
        )
    end
})

function writeLog(text)
	if string.len(text) > 256 then
		return
	end
	
	local file = io.open(minetest.get_worldpath().."/chat_record.txt", "a")
	local time = os.date('%Y-%m-%d %H:%M:%S')
	local text = string.format("%s: %s",tostring(time),text)
	file:write(text.."\n")
	file:close()
end

-- log player login position
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	local pp = player:getpos()
	writeLog("[LOGIN] " .. player_name .. " at " .. string.format("%.2f", pp.x) .. ", " .. string.format("%.2f", pp.y) .. ", " .. string.format("%.2f", pp.z));
end)
minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	local pp = player:getpos()
	writeLog("[LEAVE] " .. player_name .. " at " .. string.format("%.2f", pp.x) .. ", " .. string.format("%.2f", pp.y) .. ", " .. string.format("%.2f", pp.z));
end)

-- show bones
minetest.register_on_dieplayer(function(player)

	local player_name = player:get_player_name()

	if minetest.setting_getbool("creative_mode") then -- in creative, no chance of bones, bail
		return
	end

	local pp = player:getpos()
	local pos = pp
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)

	minetest.chat_send_player(player_name, "You Died at: " .. pos.x .. ", " .. pos.y .. ", " .. pos.z);
	writeLog("[BONES] " .. player_name .. " died at " .. string.format("%.2f", pp.x) .. ", " .. string.format("%.2f", pp.y) .. ", " .. string.format("%.2f", pp.z));

end)

-- market
minetest.register_chatcommand("market",
{
	params = "<market>",
	description = "Opens the commodity market.",
	func = function (name, param)
		local market_name = "under";
		if param ~= "" then
			market_name = param;
		end
		local market = commoditymarket.registered_markets[market_name]
		if market == nil then return end
		local formspec = market:get_formspec(market:get_account(name))
		minetest.show_formspec(name, "commoditymarket:"..market_name..":"..name, formspec)
	end
})

-- mypos
minetest.register_chatcommand("mp",
{
	description = "Prints your position in chat",
	func = function (name, param)
		if name ~= nil and name ~= "" then
			local player = minetest.get_player_by_name(name);
			if player ~= nil then
				local pp = player:get_pos();
				minetest.chat_send_player(name, "POS: " .. string.format("%.2f", pp.x) .. ", " .. string.format("%.2f", pp.y) .. ", " .. string.format("%.2f", pp.z));
			end
		end
	end
})
minetest.register_chatcommand("mpx",
{
	description = "Prints your position in chat",
	func = function (name, param)
		if name ~= nil and name ~= "" then
			local player = minetest.get_player_by_name(name);
			if player ~= nil then
				local pp = player:get_pos();
				minetest.chat_send_player(name, "POS: " .. math.floor(pp.x) .. ", " .. math.floor(pp.y) .. ", " .. math.floor(pp.z));
			end
		end
	end
})
minetest.register_chatcommand("pmp",
{
	description = "Prints your position in public chat",
	func = function (name, param)
		if name ~= nil and name ~= "" then
			local player = minetest.get_player_by_name(name);
			if player ~= nil then
				local pp = player:get_pos();
				minetest.chat_send_all(name .. " POS: " .. string.format("%.2f", pp.x) .. ", " .. string.format("%.2f", pp.y) .. ", " .. string.format("%.2f", pp.z));
			end
		end
	end
})

-- getpos
minetest.register_chatcommand("gp",
{
	privs = {teleport = true},
	params = "<player name>",
	description = "Prints player position",
	func = function (name, param)
		if name ~= nil and name ~= "" and param ~= nil and param ~= "" then
			local player = minetest.get_player_by_name(param);
			if player ~= nil then
				local pp = player:get_pos();
				minetest.chat_send_player(name, param .. " POS: " .. string.format("%.2f", pp.x) .. ", " .. string.format("%.2f", pp.y) .. ", " .. string.format("%.2f", pp.z));
			end
		end
	end
})

-- biome explorer
minetest.register_chatcommand("rp",
{
	privs = {teleport = true},
	params = "<yelevation>",
	description = "Teleports player to random biome",
	func = function (name, param)
		local pcg = PcgRandom(minetest.get_gametime());
		local vx = pcg:next(-30000, 30000);

		local vy = 30;
		if param ~= "" then
			vy = tonumber(param);
		end
		if vy == nil then
			vy = pcg:next(-30000, 30000);
		end
		
		local vz = pcg:next(-30000, 30000);
		local player = minetest.get_player_by_name(name);
		player:set_pos({x=vx, y=vy, z=vz});
		minetest.chat_send_player(name, "POS: " .. vx .. ", " .. vy .. ", " .. vz);
	end
})

minetest.register_chatcommand("rb",
{
	privs = {teleport = true},
	params = "",
	description = "Teleports player to random biome",
	func = function (name, param)
		local pcg = PcgRandom(minetest.get_gametime());
		local vx = pcg:next(-30000, 30000);
		local vz = pcg:next(-30000, 30000);
		local player = minetest.get_player_by_name(name);
		player:set_pos({x=vx, y=30, z=vz});
		minetest.chat_send_player(name, "POS: " .. vx .. ", 30, " .. vz);
	end
})


-- admin shop teleporter
minetest.register_chatcommand("as",
{
	privs = {teleport = true},
	params = "<player name>",
	description = "Undefined",
	func = function (name, param)
		if param ~= nil and param ~= "" then
			local player = minetest.get_player_by_name(param);
			if player ~= nil then
				player:set_pos({x=187.7, y=-10882.5, z=-29.8});
			end
		end
	end
})


-- jailing players
minetest.register_privilege("jail", "Required to jail players.");

minetest.register_chatcommand("jail",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Jails player",
	func = function (name, param)
		if name ~= nil and name ~= "" and param ~= nil and param ~= "" then
			local player = minetest.get_player_by_name(param);
			if player ~= nil then
				player:set_pos(jailpos);

				local privs = minetest.get_player_privs(param);
				privs.home = nil;
				privs.tp = nil;
				minetest.set_player_privs(param, privs);

				local hp = sethome.get(param);
				if hp ~= nil then
					minetest.chat_send_player(name, param .. " home1 is at " .. hp.x .. "," .. hp.y .. "," .. hp.z);
				end

				local hp2 = unified_inventory.home_pos[param];
				if hp2 ~= nil then
					minetest.chat_send_player(name, param .. " home2 is at " .. hp2.x .. "," .. hp2.y .. "," .. hp2.z);
				end

				player:set_nametag_attributes({text = minetest.colorize("red", "[Jailed]") .. " " .. player:get_player_name()})

				minetest.chat_send_all(param .. " has been jailed.");
				writeLog("[JAILD] " .. name .. " sent " .. param .. " to jail.");
			end
		end
	end
})

minetest.register_chatcommand("prison",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Jails & Gags player",
	func = function (name, param)
		if name ~= nil and name ~= "" and param ~= nil and param ~= "" then
			local player = minetest.get_player_by_name(param);
			if player ~= nil then
				player:set_pos(jailpos);

				local privs = minetest.get_player_privs(param);
				privs.shout = nil;
				privs.home = nil;
				privs.tp = nil;
				minetest.set_player_privs(param, privs);

				local hp = sethome.get(param);
				if hp ~= nil then
					minetest.chat_send_player(name, param .. " home1 is at " .. hp.x .. "," .. hp.y .. "," .. hp.z);
				end

				local hp2 = unified_inventory.home_pos[param];
				if hp2 ~= nil then
					minetest.chat_send_player(name, param .. " home2 is at " .. hp2.x .. "," .. hp2.y .. "," .. hp2.z);
				end

				player:set_nametag_attributes({text = minetest.colorize("red", "[Prisoner]") .. " " .. player:get_player_name()})

				minetest.chat_send_all(param .. " has been imprisoned.");
				writeLog("[PRISN] " .. name .. " sent " .. param .. " to prison.");
			end
		end
	end
})

minetest.register_chatcommand("resethome",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Resets players home positions",
	func = function (name, param)
		if name ~= nil and name ~= "" and param ~= nil and param ~= "" then
			local player = minetest.get_player_by_name(param);
			if player ~= nil then

				if isui then
					unified_inventory.set_home(player, spawn_command.pos)
				end
				sethome.set(param, spawn_command.pos)

				minetest.chat_send_all(param .. " has had his home points reset.");
				writeLog("[RESET] " .. name .. " reset " .. param .. " home positions.");

			end
		end
	end
})

minetest.register_chatcommand("tellhome",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Makes player blurt out home position to public chat",
	func = function (name, param)
		if param ~= nil and param ~= "" then
			local player = minetest.get_player_by_name(param)
			if player ~= nil then

				local hp = sethome.get(param);
				if hp ~= nil then
					minetest.chat_send_all(param .. " first home is at " .. hp.x .. "," .. hp.y .. "," .. hp.z);
				end

				local hp2 = unified_inventory.home_pos[param];
				if hp2 ~= nil then
					minetest.chat_send_all(param .. " second home is at " .. hp2.x .. "," .. hp2.y .. "," .. hp2.z);
				end
			
			end
		end
	end
})

minetest.register_chatcommand("tellhomepriv",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Tells only you the players home positions",
	func = function (name, param)
		if name ~= nil and name ~= "" and param ~= nil and param ~= "" then	
			local player = minetest.get_player_by_name(param)
			if player ~= nil then

				local hp = sethome.get(param);
				if hp ~= nil then
					minetest.chat_send_player(name, param .. " first home is at " .. hp.x .. "," .. hp.y .. "," .. hp.z);
				end

				local hp2 = unified_inventory.home_pos[param];
				if hp2 ~= nil then
					minetest.chat_send_player(name, param .. " second home is at " .. hp2.x .. "," .. hp2.y .. "," .. hp2.z);
				end

			end
		end
	end
})

minetest.register_chatcommand("telehome1",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Teleports you to a players first home",
	func = function (name, param)
		if name ~= nil and name ~= "" and param ~= nil and param ~= "" then
			local executioner = minetest.get_player_by_name(name)
			local player = minetest.get_player_by_name(param)
			if player ~= nil and executioner ~= nil then

				local hp = sethome.get(param);
				if hp ~= nil then
					executioner:set_pos(hp);
				end

			end
		end
	end
})

minetest.register_chatcommand("telehome2",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Teleports you to a players second home",
	func = function (name, param)
		if param ~= nil and param ~= "" then
			local executioner = minetest.get_player_by_name(name)
			local player = minetest.get_player_by_name(param)
			if player ~= nil and executioner ~= nil then

				local hp2 = unified_inventory.home_pos[param];
				if hp2 ~= nil then
					executioner:set_pos(hp2);
				end

			end
		end
	end
})

minetest.register_chatcommand("free",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Free player from jail",
	func = function (name, param)
		if name ~= nil and name ~= "" and param ~= nil and param ~= "" then
			local player = minetest.get_player_by_name(param);
			if player ~= nil then
				player:set_pos(freepos);

				local privs = minetest.get_player_privs(param);
				privs.shout = true;
				privs.home = true;
				privs.tp = true;
				minetest.set_player_privs(param, privs);

				player:set_nametag_attributes({text = player:get_player_name()})

				minetest.chat_send_all(param .. " has been freed from jail.");
				writeLog("[FREED] " .. name .. " free'd " .. param .. " from jail.");
			end
		end
	end
})

minetest.register_chatcommand("respawn",
{
	privs = {jail = true},
	params = "<player name>",
	description = "Trigger respawn on player [test func]",
	func = function (name, param)
		local player = minetest.get_player_by_name(param);
		if player ~= nil then
			local p1 = player:get_pos()
			local dist = vector.distance(p1, jailpos);

			if dist < jailradius then
				return player:set_pos(jailpos);
			end

			return player:set_pos(freepos);
		end
	end
})

minetest.register_on_respawnplayer(function(player)

	local p1 = player:get_pos()
	local dist = vector.distance(p1, jailpos);

	if dist < jailradius then
		player:set_pos(jailpos);
		return true
	end

	return player:set_pos(freepos);

end)


if minetest.setting_get_pos("static_spawnpoint") then
    spawn_command.pos = minetest.setting_get_pos("static_spawnpoint")
end

function teleport_to_spawn(name)
    local player = minetest.get_player_by_name(name)
    if player == nil then
        -- just a check to prevent the server crashing
        return false
    end
    local pos = player:get_pos()

	local dist = vector.distance(pos, jailpos);

	if dist < jailradius then
		player:set_pos(jailpos);
		return true
	end

    if _G['cursed_world'] ~= nil and    --check global table for cursed_world mod
        cursed_world.location_y and cursed_world.dimension_y and
        pos.y < (cursed_world.location_y + cursed_world.dimension_y) and    --if player is in cursed world, stay in cursed world
        pos.y > (cursed_world.location_y - cursed_world.dimension_y)
    then   --check global table for cursed_world mod
        --minetest.chat_send_player(name, "T"..(cursed_world.location_y + cursed_world.dimension_y).." "..(cursed_world.location_y - cursed_world.dimension_y))
        local spawn_pos = vector.round(spawn_command.pos);
        spawn_pos.y = spawn_pos.y + cursed_world.location_y;
        player:set_pos(spawn_pos)
        minetest.chat_send_player(name, "Teleported to spawn!")
    else
        player:set_pos(spawn_command.pos)
        minetest.chat_send_player(name, "Teleported to spawn!")
    end
end

minetest.register_chatcommand("spawn", {
    description = "Teleport you to spawn point.",
    func = teleport_to_spawn,
})


-- chat logger
minetest.register_on_chat_message(function(name, message)
	file = io.open(minetest.get_worldpath().."/chat_record.txt", "a")
	local time = os.date('%Y-%m-%d %H:%M:%S')
	local text = string.format("%s: <%s> %s",tostring(time),name,message)
	file:write(text.."\n")
	file:close()
end)


