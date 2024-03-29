extends Crafting

func _blueprints():
	return Data.ships
	
func _get_icon_texture(blueprint):
	return blueprint.icon

func _get_product_description(blueprint):
	return blueprint.desc

func _get_product_name(blueprint):
	return blueprint.name

func _do_craft():
	Client.switch_ship(current_blueprint.id)

func _get_codex_path(current_blueprint):
	return current_blueprint.derive_codex_path()
	
func _has_codex_path(current_blueprint):
	var path = _get_codex_path(current_blueprint)
	var has_entry = Data.has_codex_entry(_get_codex_path(current_blueprint))
	return has_entry
