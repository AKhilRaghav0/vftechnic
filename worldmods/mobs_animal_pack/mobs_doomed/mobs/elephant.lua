mobs:register_mob("mobs_doomed:elephant", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 12,
	hp_max = 22,
	armor = 130,
	collisionbox = {-0.9, -1.2, -0.9, 0.9, 0.9, 0.9},
	visual = "mesh",
	mesh = "elephant.b3d",
	textures = {
		{"mobs_doomed_elephant.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=2.5, y=2.5},
	makes_footstep_sound = true,
	walk_velocity = 0.5,
	run_velocity = 1,
	jump = false,
	water_damage = 2,
	lava_damage = 2,
	light_damage = 0,
	fall_damage = 1,
	fall_speed = -20, -- extra heavy!
	fear_height = 2,
	replace_rate = 10,
	replace_what = {"default:grass_3", "default:grass_4", "default:grass_5", "ethereal:bamboo"},
	replace_with = "air",
	view_range = 14,
	drops = {
		{name = "mobs:meat_raw", chance=1, min = 4, max = 12},
		{name="mobs:leather", chance=1, min=4, max=12},
	},
	animation = {
		speed_normal = 5,
		speed_run = 10,
		walk_start = 3,
		walk_end = 19,
		stand_start = 20,
		stand_end = 30,
		run_start = 3,
		run_end = 19,
	},
	follow = {
		"cottages:hay",
		"cottages:straw_bale",
		"cottages:straw",
		"farming:straw",
	},
	on_rightclick = function(self, clicker)
		if mobs:feed_tame(self, clicker, 8, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 0, 10, false, nil) then return end
	end,
})

mobs:register_egg("mobs_doomed:elephant", "Elephant", "default_dry_grass.png", 1)

if mobs_doomed.config.elephant.spawn.enabled then
	mobs:spawn_specific(
		"mobs_doomed:elephant",
		mobs_doomed.config.elephant.spawn.on,
		mobs_doomed.config.elephant.spawn.near,
		mobs_doomed.config.elephant.spawn.min_light,
		mobs_doomed.config.elephant.spawn.max_light,
		mobs_doomed.config.elephant.spawn.interval,
		mobs_doomed.config.elephant.spawn.chance,
		mobs_doomed.config.elephant.spawn.active_object_count,
		mobs_doomed.config.elephant.spawn.min_height,
		mobs_doomed.config.elephant.spawn.max_height,
		true
	)
end
