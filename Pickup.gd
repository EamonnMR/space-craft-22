extends RigidBody3D

@export var type: String
var picked_up = false
var initial_vel = 0.5

func initial_velocity():
	rotate_y(randf_range(0, PI*2))
	apply_central_impulse(
		initial_vel * transform.basis.x
	)

func _ready():
	# TODO: Set texture properly
	$Sprite3D.texture = Data.items[type].icon
	$AudioStreamPlayer3D.finished.connect(queue_free)
	call_deferred("initial_velocity")

func serialize() -> Dictionary:
	var position = Util.flatten_25d(global_transform.origin)
	return {
		"type": type,
		"position": [position.x, position.y],
		"scene_file_path": scene_file_path
	}

func deserialize(data):
		type = data["type"]
		global_transform.origin = Util.raise_25d(
			Vector2(data["position"][0], data["position"][1])
		)

func _on_pickup_range_body_entered(body):
	if body == Client.player:
		body.get_node("Inventory").add(type, 1)
		$AudioStreamPlayer3D.play()
		hide()

