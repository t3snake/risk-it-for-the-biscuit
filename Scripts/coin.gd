extends Node3D

func _on_coin_entered(body: Node3D) -> void:
	if body is MainCharacter:
		GlobalState.set_level_cleared()
