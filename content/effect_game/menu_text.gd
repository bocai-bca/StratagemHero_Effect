extends RichTextLabel
class_name StratagemHeroEffect_EffectGame_MenuText

func update_text() -> void:
	text = ""
	text += "[color=yellow][b]" + tr(&"menu_general_text_back") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 0) else tr(&"menu_general_text_back")
	match (StratagemHeroEffect_EffectGame.special_effect_mode):
		StratagemHeroEffect_EffectGame.SpecialEffectMode.NONE:
			text += "\n[color=yellow][b]" + tr(&"effect_mode.normal") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 1) else "\n" + tr(&"effect_mode.normal")
		StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION:
			text += "\n[color=yellow][b]" + tr(&"effect_mode.dictation") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 1) else "\n" + tr(&"effect_mode.dictation")
		StratagemHeroEffect_EffectGame.SpecialEffectMode.GREATWALL:
			text += "\n[color=yellow][b]" + tr(&"effect_mode.greatwall") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 1) else "\n" + tr(&"effect_mode.greatwall")
		StratagemHeroEffect_EffectGame.SpecialEffectMode.MULTILINES:
			text += "\n[color=yellow][b]" + tr(&"effect_mode.multilines") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 1) else "\n" + tr(&"effect_mode.multilines")
	text += "\n[color=yellow][b]" + tr(&"effect_option.edit_stratagems") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 2) else "\n" + tr(&"effect_option.edit_stratagems")
	if (StratagemHeroEffect_EffectGame.one_heart):
		text += "\n[color=yellow][b]" + tr(&"effect_option.oneheart") + " ON[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 3) else "\n" + tr(&"effect_option.oneheart") + " ON"
	else:
		text += "\n[color=yellow][b]" + tr(&"effect_option.oneheart") + " OFF[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 3) else "\n" + tr(&"effect_option.oneheart") + " OFF"
	text += "\n[color=yellow][b]" + tr(&"effect_start") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n" + tr(&"effect_start")
