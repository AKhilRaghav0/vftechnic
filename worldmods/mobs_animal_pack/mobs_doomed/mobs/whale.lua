mobs:register_mob("mobs_doomed:whale", {
	type = "animal",
	passive = false,
	reach = 1,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 52,
	hp_max = 82,
	armor = 230,
	collisionbox = {-0.9, -1.2, -0.9, 0.9, 0.9, 0.9},
	visual = "mesh",
	mesh = "whale.b3d",
	textures = {
		{"mobs_doomed_whale.png"},
	},
	blood_texture = "mobs_blood.png",
	visual_size = {x=2.5, y=2.5},
	makes_footstep_sound = true,
	walk_velocity = 0.5,
	run_velocity = 1,
	jump = false,
	stepheight = 1.5,
	fall_damage = 0,
	fall_speed = -6,
	fly = true,
	fly_in = "default:water_source",
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"fishing:fish_cooked"},
	view_range = 14,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 15, max = 30},
		{name = "basic_materials:oil_extract", chance = 1, min = 15, max = 30},
		{name = "bonemeal:bone", chance = 1, min = 10, max = 20},
	},
	sounds = {
      random = "whale_1",
      death = "whale_1",
      distance = 128,
	},
	animation = {
		speed_normal = 5,
		speed_run = 10,
		walk_start = 2,
		walk_end = 39,
		stand_start = 2,
		stand_end = 39,
		run_start = 2,
		run_end = 39,
	},
})

mobs:register_egg("mobs_doomed:whale", "Whale", "wool_blue.png", 1)

if mobs_doomed.config.whale.spawn.enabled then
	mobs:spawn_specific(
		"mobs_doomed:whale",
		mobs_doomed.config.whale.spawn.on,
		mobs_doomed.config.whale.spawn.near,
		mobs_doomed.config.whale.spawn.min_light,
		mobs_doomed.config.whale.spawn.max_light,
		mobs_doomed.config.whale.spawn.interval,
		mobs_doomed.config.whale.spawn.chance,
		mobs_doomed.config.whale.spawn.active_object_count,
		mobs_doomed.config.whale.spawn.min_height,
		mobs_doomed.config.whale.spawn.max_height,
		true
	)
end
