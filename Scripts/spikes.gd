extends Node3D


func _on_spike_area_body_entered(body: Node3D) -> void:
	if body is MainCharacter:
		body.die()
