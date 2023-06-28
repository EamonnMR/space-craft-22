extends Node

var explore_all = false
var max_craft_level = false

var CHEATS = [
	{
		"hash": "d10ba5f768ac9db04b8419a2590bce54",
		"callback": func explore_all_now(args):
						explore_all = true
						for i in Procgen.systems:
							Client.get_ui().get_node("Map").update_for_explore(i)
						return true},
	{
		"hash": "eba4a7a2f23a106e01e1380deac5190d",
		"callback": func free_resources(args):
						if not(len(args) == 2):
							Client.display_message("Please enter an item type and quantity")
							return false
						var type = args[0]
						var amount = int(args[1])
						if not (type in Data.items):
							Client.display_message("Unknown item type: " + type)
							return
						Client.player.get_node("Inventory").add(type, amount)
						return true},
	{
		"hash": "8f1120f13067fb18ca2ee5bf7b57f9b8",
		"callback": func(_args): set_var("max_craft_level")
	},
	{
		"hash": "21a8297be0a2e4a39ec56a65015c0451",
		"callback": func make_player_invincible(args):
						var health = Client.player.get_node("Health")
						health.invulnerable = not health.invulnerable
						return health.invulnerable}
]

func set_var(variable_name):
	set(variable_name, not get(variable_name))
	return get(variable_name)

func hash_code(code):
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(code.to_utf8_buffer())
	var res = ctx.finish()
	var encoded = res.hex_encode()
	return encoded

func attempt_cheat(input):
	if input.is_empty():
		return
	
	var split = input.split(":")
	var code = split[0].to_lower()
	var args = split[1].trim_prefix(" ").split(" ") if split.size() > 1 else []
	var hash = hash_code(code)
	var valence: bool
	for cheat in CHEATS:
		if cheat.hash == hash:
			valence = cheat.callback.call(args)
			if valence:
				Client.display_message("Cheat Enabled")
			else:
				Client.display_message("Cheat Disabled")
			return
