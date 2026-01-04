extends Label
class_name StratagemHeroEffect_EffectGame_DescriptionText

func update_text() -> void:
	match (StratagemHeroEffect_EffectGame.menu_option_focus):
		0: #返回
			text = tr(&"effect_description.back_to_title")
		1: #特殊效果模式
			match (StratagemHeroEffect_EffectGame.special_effect_mode):
				StratagemHeroEffect_EffectGame.SpecialEffectMode.NONE:
					text = tr(&"effect_description.effect_mode.normal")
				StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION:
					text = tr(&"effect_description.effect_mode.dictation")
				StratagemHeroEffect_EffectGame.SpecialEffectMode.GREATWALL:
					text = tr(&"effect_description.effect_mode.greatwall")
				StratagemHeroEffect_EffectGame.SpecialEffectMode.MULTILINES:
					text = tr(&"effect_description.effect_mode.multilines")
		2: #编辑战备
			text = tr(&"effect_description.effect_option.edit_stratagems")
		3: #一命模式
			text = tr(&"effect_description.effect_option.oneheart")
		4: #开始游戏
			text = tr(&"effect_description.effect_start")
