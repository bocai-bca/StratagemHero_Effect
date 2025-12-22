extends RichTextLabel
class_name MainMenu_Text

func _ready() -> void:
	_physics_process(0.0)

func update_text() -> void:
	text = ""
	match (StratagemHeroEffect.instance.game_state):
		StratagemHeroEffect.GameState.MainMenu:
			text += "[color=yellow][b]" + tr(&"main_menu_text_classic") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 0) else tr(&"main_menu_text_classic")
			text += "\n[color=yellow][b]" + tr(&"main_menu_text_effects") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 1) else "\n" + tr(&"main_menu_text_effects")
			text += "\n[color=yellow][b]" + tr(&"main_menu_text_settings") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 2) else "\n" + tr(&"main_menu_text_settings")
			text += "\n[color=yellow][b]" + tr(&"main_menu_text_statistic") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 3) else "\n" + tr(&"main_menu_text_statistic")
			text += "\n[color=yellow][b]" + tr(&"main_menu_text_about") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 4) else "\n" + tr(&"main_menu_text_about")
		StratagemHeroEffect.GameState.Settings:
			text += "[color=yellow][b]" + tr(&"menu_general_text_back") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 0) else tr(&"menu_general_text_back")
			text += "\n[color=yellow][b]" + tr(&"settings_text_language") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 1) else "\n" + tr(&"settings_text_language")

func _process(_delta: float) -> void:
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Classic):
		return
	var window: Window = get_window()
	size = Vector2(window.size)
	var title_pos: Vector2 = Vector2(0.0, size.y)
	var menu_pos: Vector2 = Vector2(0.0, 0.0)
	var percent: float = StratagemHeroEffect.transfer_timers[0].percent
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Title):
		position = menu_pos.lerp(title_pos, percent)
	else:
		position = title_pos.lerp(menu_pos, percent)

func _physics_process(_delta: float) -> void:
	add_theme_font_size_override(&"normal_font_size", int(StratagemHeroEffect.instance.get_font_size(64.0)))
	add_theme_font_size_override(&"bold_font_size", int(StratagemHeroEffect.instance.get_font_size(72.0)))
