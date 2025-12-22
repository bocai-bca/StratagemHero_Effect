extends ColorRect

func _process(_delta: float) -> void:
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Classic):
		return
	var window: Window = get_window()
	size = Vector2(window.size.x, window.size.y / 45.0)
	var title_pos: Vector2 = Vector2(0.0, window.size.y / 11.25 - size.y / 2.0)
	var menu_pos: Vector2 = Vector2(0.0, -size.y)
	var percent: float = StratagemHeroEffect.transfer_timers[0].percent
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Title):
		position = menu_pos.lerp(title_pos, percent)
	else:
		position = title_pos.lerp(menu_pos, percent)
