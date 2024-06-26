extends Node

class_name Equipment


enum CATEGORY {
	ANY,
	CONSUMABLE,
	SHIELD,
	HYPERDRIVE,
	REACTOR,
	ARMOR,
	WEAPON
}

# This is populated by the weapon slot nodes in ../Weapons/
var weapons = {}

var max_armors = 1
var armors = {}
var max_shields = 1
var shields = {}
var max_hyperdrives = 1
var hyperdrives = {}
var max_reactors = 1
var reactors = {}
var max_consumables = 3
var consumables = {}

var slot_keys = {
	CATEGORY.ARMOR: armors,
	CATEGORY.SHIELD: shields,
	CATEGORY.HYPERDRIVE: hyperdrives,
	CATEGORY.REACTOR: reactors,
	CATEGORY.WEAPON: weapons,
	CATEGORY.CONSUMABLE: consumables
}

func _ready():
	# Determine weapon slots by the ship
	var parent = get_node("../")
	for weapon_slot in parent.get_weapon_slots():
			if not weapon_slot.name in weapons:
				weapons[weapon_slot.name] = null
		
	#max_armors = Data.ships[parent.type].armor_slots
	max_armors = 1
	for i in [
		[max_armors, armors],
		[max_shields, shields],
		[max_hyperdrives, hyperdrives],
		[max_reactors, reactors],
		[max_consumables, consumables]
	]:
		var slots = i[1]
		for j in range(i[0]):
			var key = str(j)
			if not(key in slots):
				slots[key] = null

func equip_item(item: Inventory.InvItem, key: String, category: CATEGORY):
	assert(item.data().equip_category == category)
	assert(key in slot_keys[category])
	assert(slot_keys[category][key] == null)
	slot_keys[category][key] = item
	
	_add(item, key, category)
	
func find_slot_for_item(item: Inventory.InvItem) -> String:
	var category = item.data().equip_category
	for key in slot_keys[item.data().equip_category]:
		if slot_keys[category][key] == null:
			return key
	
	return ""
	
func remove_item(key: String, category: CATEGORY) -> Inventory.InvItem:
	var item = slot_keys[category][key]
	assert(item)
	slot_keys[category][key] = null
	
	_remove(key, category, item)
	return item
	
func _add(item: Inventory.InvItem, key: String, category: CATEGORY):
	match category:
		CATEGORY.WEAPON:
			get_parent().get_node(key).add_weapon(WeaponData.instantiate(item.type))
		CATEGORY.ARMOR:
			_parent().get_node("Health").increase_max_health(item.data().consumable_magnitude)
		CATEGORY.SHIELD:
			_parent().get_node("Health").increase_max_shields(item.data().consumable_magnitude)

func _remove(key: String, category: CATEGORY, item: Inventory.InvItem):
	match category:
		CATEGORY.WEAPON:
			_parent().get_node(key).remove_weapon()
		CATEGORY.ARMOR:
			_parent().get_node("Health").decrease_max_health(item.data().consumable_magnitude)
		CATEGORY.SHIELD:
			_parent().get_node("Health").decrease_max_shields(item.data().consumable_magnitude)

func apply():
	# Use this if the data has been instantiated but _add hasn't been called for all items yet.
	for group_name in slot_keys:
		var group = slot_keys[group_name]
		for key in group:
			_add(group[key], key, group_name)
			
func _parent():
	return get_node("../")

func serialize() -> Dictionary:
	var slots = {}
	for group_name in slot_keys:
		var group = slot_keys[group_name]
		var slot_data = {}
		for key in group:
			if group[key]:
				slot_data[key] = {
					"type": group[key].type,
					"count": group[key].count
				}
		slots[group_name] = slot_data
		
	return slots
		
func deserialize(data):
	for group_key in slot_keys:
		var group = slot_keys[group_key]
		for key in data[str(group_key)]:
			var item_data = data[str(group_key)][key]
			group[key] = Inventory.InvItem.new(
				item_data.type,
				int(item_data.count)
			)
	apply()

func can_hyperjump():
	return hyperdrives.size() > 0 and hyperdrives[hyperdrives.keys()[0]] != null

func use_consumable_by_slot(slot):
	slot = str(slot)
	print("use consumable by slot: ", slot)
	if consumables[slot]:
		var item = remove_item(slot, CATEGORY.CONSUMABLE)
		apply_consumable(item)

# TODO: This could probably be its own class, esp. if it gets big
func apply_consumable(item: Inventory.InvItem):
	# TODO: Add sound effects
	var effect = item.data().consumable_effect
	var mag = item.data().consumable_effect_magnitude
	var parent = _parent()
	if effect == "air":
		parent.air += mag
		if parent.air > parent.max_air:
			parent.air = parent.max_air
	if effect == "health":
		var health = parent.get_node("health")
		health.gain_health(mag)
	if effect == "shields":
		var health = parent.get_node("health")
		health.gain_shields(mag)
	if effect == "energy":
		parent.energy += mag
		if parent.energy > parent.max_energy:
			parent.energy = parent.max_energy
