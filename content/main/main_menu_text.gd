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
			text += "\n[color=yellow][b]" + tr(&"main_menu_text_helps") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 3) else "\n" + tr(&"main_menu_text_helps")
			text += "\n[color=yellow][b]" + tr(&"main_menu_text_high_scores") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 4) else "\n" + tr(&"main_menu_text_high_scores")
			text += "\n[color=yellow][b]" + tr(&"main_menu_text_about") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 5) else "\n" + tr(&"main_menu_text_about")
		StratagemHeroEffect.GameState.Settings:
			text += "[color=yellow][b]" + tr(&"menu_general_text_back") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 0) else tr(&"menu_general_text_back")
			var music_volume_text: String = tr(&"settings_text.music_volume") + " " + str(int(StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music * 100.0)) + "%"
			var sfx_volume_text: String = tr(&"settings_text.sfx_volume") + " " + str(int(StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx * 100.0)) + "%"
			text += "\n[color=yellow][b]- " + music_volume_text + " +[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 1) else "\n" + music_volume_text
			text += "\n[color=yellow][b]- " + sfx_volume_text + " +[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 2) else "\n" + sfx_volume_text
			text += "\n[color=yellow][b]" + tr(&"settings_text.language") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 3) else "\n" + tr(&"settings_text.language")
			var score_clear_text: String
			if (StratagemHeroEffect.instance.score_clear_already):
				score_clear_text = tr(&"settings_text.clear_score_already")
			elif (StratagemHeroEffect.instance.score_clear_comfirm):
				score_clear_text = tr(&"settings_text.clear_score_confirm")
			else:
				score_clear_text = tr(&"settings_text.clear_score")
			text += "\n[color=yellow][b]" + score_clear_text + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 4) else "\n" + score_clear_text
		StratagemHeroEffect.GameState.Helps:
			text += "[color=yellow][b]" + tr(&"menu_general_text_back") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 0) else tr(&"menu_general_text_back")
			text += "\n\n\n\n\n\n\n"
		StratagemHeroEffect.GameState.HighScores:
			text += "[color=yellow][b]" + tr(&"menu_general_text_back") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 0) else tr(&"menu_general_text_back")
			var type_line: String
			var type_context: String = "[table=3]" + tr(&"high_scores.number_name_line")
			match (StratagemHeroEffect.high_scores_showing_type):
				0:
					type_line = "<< " + tr(&"high_scores.type.classic") + " >>"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.classic_high_score.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.classic_high_score.score >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.classic_high_score.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.classic_high_score.reach_level >= 0 else "--") + "[/cell][cell]--[/cell]"
					type_context += "\n[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.classic_high_level.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.classic_high_level.score >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.classic_high_level.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.classic_high_level.reach_level >= 0 else "--") + "[/color][/cell][cell]--[/cell]\n[cell] [/cell][cell] [/cell][cell] [/cell][/table]"
				1:
					type_line = "<< " + tr(&"high_scores.type.effect_none") + " >>"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_score.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_score.score >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_score.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_score.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_score.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_score.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_level.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_level.score >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_level.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_level.reach_level >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_level.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_level.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_speed.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_speed.score >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_speed.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_speed.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_speed.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_none.high_speed.speed_per_minute >= 0.0 else "--") + "[/color][/cell]"
				2:
					type_line = "<< " + tr(&"high_scores.type.effect_dictation") + " >>"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_score.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_score.score >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_score.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_score.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_score.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_score.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_level.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_level.score >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_level.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_level.reach_level >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_level.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_level.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_speed.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_speed.score >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_speed.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_speed.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_speed.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_dictation.high_speed.speed_per_minute >= 0.0 else "--") + "[/color][/cell]"
				3:
					type_line = "<< " + tr(&"high_scores.type.effect_greatwall") + " >>"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_score.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_score.score >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_score.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_score.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_score.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_score.speed_per_minute >= 0.0 else "--") + "[/cell]\n[cell] [/cell][cell] [/cell][cell] [/cell]\n"
					#type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_level.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_level.score >= 0 else "--") + "[/cell]"
					#type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_level.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_level.reach_level >= 0 else "--") + "[/color][/cell]"
					#type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_level.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_level.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_speed.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_speed.score >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_speed.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_speed.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_speed.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_greatwall.high_speed.speed_per_minute >= 0.0 else "--") + "[/color][/cell]"
				4:
					type_line = "<< " + tr(&"high_scores.type.effect_multilines") + " >>"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_score.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_score.score >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_score.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_score.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_score.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_score.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_level.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_level.score >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_level.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_level.reach_level >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_level.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_level.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_speed.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_speed.score >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_speed.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_speed.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_speed.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_multilines.high_speed.speed_per_minute >= 0.0 else "--") + "[/color][/cell]"
				5:
					type_line = "<< " + tr(&"high_scores.type.effect_terminal") + " >>"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_score.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_score.score >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_score.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_score.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_score.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_score.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_level.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_level.score >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_level.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_level.reach_level >= 0 else "--") + "[/color][/cell]"
					type_context += "[cell]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_level.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_level.speed_per_minute >= 0.0 else "--") + "[/cell]\n"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_speed.score) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_speed.score >= 0 else "--") + "[/cell]"
					type_context += "[cell]" + (str(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_speed.reach_level) if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_speed.reach_level >= 0 else "--") + "[/cell]"
					type_context += "[cell][color=yellow]" + (str(snappedf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_speed.speed_per_minute, 0.1)) + "/min" if StratagemHeroEffect_SaveAccess.save_struct_in_memory.effect_high_score_terminal.high_speed.speed_per_minute >= 0.0 else "--") + "[/color][/cell]"
			text += "\n[color=yellow][b]" + type_line + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 1) else "\n" + type_line
			text += "\n" + type_context
		StratagemHeroEffect.GameState.About:
			text += "[color=yellow][b]" + tr(&"menu_general_text_back") + "[/b][/color]" if (StratagemHeroEffect.menu_option_focus == 0) else tr(&"menu_general_text_back")
			text += "\n\n\n\n\n\n\n"

func _process(_delta: float) -> void:
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Classic):
		return
	var window: Window = get_window()
	size = Vector2(window.size)
	var title_pos: Vector2 = Vector2(0.0, size.y)
	var menu_pos: Vector2 = Vector2(0.0, size.y * 0.05)
	var percent: float = StratagemHeroEffect.transfer_timers[0].percent
	if (StratagemHeroEffect.instance.game_state == StratagemHeroEffect.GameState.Title):
		position = menu_pos.lerp(title_pos, percent)
	else:
		position = title_pos.lerp(menu_pos, percent)

func _physics_process(_delta: float) -> void:
	add_theme_font_size_override(&"normal_font_size", int(StratagemHeroEffect.instance.get_font_size(64.0)))
	add_theme_font_size_override(&"bold_font_size", int(StratagemHeroEffect.instance.get_font_size(72.0)))
