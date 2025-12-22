extends TextureRect

func _physics_process(_delta: float) -> void:
	var window: Window = get_window()
	size = Vector2(window.size)
	position = size / 8.0
