
local has_monitoring_mod = minetest.get_modpath("monitoring")

local active_switching_stations_metric, switching_stations_usage_metric

if has_monitoring_mod then
	active_switching_stations_metric = monitoring.gauge(
		"technic_active_switching_stations",
		"Number of active switching stations"
	)

	switching_stations_usage_metric = monitoring.counter(
		"technic_switching_stations_usage",
		"usage in microseconds cpu time"
	)
end

-- the interval between technic_run calls
local technic_run_interval = 1.0
local set_default_timeout = technic.set_default_timeout

-- iterate over all collected switching stations and execute the technic_run function
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < technic_run_interval or not technic.powerctrl_state then
		return
	end
	timer = 0
	set_default_timeout(2)

	local now = minetest.get_us_time()
	local active_switches = 0

	for network_id, network in pairs(technic.active_networks) do

		local pos = technic.network2sw_pos(network_id)
		local node = technic.get_or_load_node(pos) or minetest.get_node(pos)

		if node.name ~= "technic:switching_station" then
			-- station vanished
			technic.remove_network(network_id)
		elseif network.timeout > now and not technic.is_overloaded(network_id) then
			-- station active
			active_switches = active_switches + 1
			technic.network_run(network_id)
		else
			-- station timed out
			technic.active_networks[network_id] = nil
		end

	end

	if has_monitoring_mod then
		local time_usage = minetest.get_us_time() - now
		active_switching_stations_metric.set(active_switches)
		switching_stations_usage_metric.inc(time_usage)
	end

end)

minetest.register_chatcommand("technic_flush_switch_cache", {
	description = "removes all loaded networks from the cache",
	privs = { server = true },
	func = function()
		technic.active_networks = {}
	end
})
