extends CanvasLayer

func get_default_children():
	return [
		$Equipment,
		$Crafting,
		$Inventory
	]

func get_all_inventory_children():
	return [
		$Equipment,
		$Crafting,
		$Inventory
#		$OtherInventory
	]

func toggle_map():
	if $Map.visible:
		$Map.visible = false
		get_tree().paused = false
	else:
		$Map.visible = true
		get_tree().paused = true

func toggle_inventory(elements: Array = []):
	if get_tree().paused:
		for i in get_all_inventory_children():
			i.hide()
			if i.has_method("unassign"):
				i.unassign()
		get_tree().paused = false
	else:
		var children = []
		if elements.size() == 0:
			children = get_default_children()
		else:
			for i in elements:
				children.push_back(get_node(i))
		
		for i in children:
			i.rebuild()
			i.show()
		get_tree().paused = true
