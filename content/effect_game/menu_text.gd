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
		StratagemHeroEffect_EffectGame.SpecialEffectMode.TERMINAL:
			text += "\n[color=yellow][b]" + tr(&"effect_mode.terminal") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 1) else "\n" + tr(&"effect_mode.terminal")
	text += "\n[color=yellow][b]" + tr(&"effect_option.edit_stratagems") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 2) else "\n" + tr(&"effect_option.edit_stratagems")
	if (StratagemHeroEffect_EffectGame.one_heart):
		text += "\n[color=yellow][b]" + tr(&"effect_option.oneheart") + " ON[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 3) else "\n" + tr(&"effect_option.oneheart") + " ON"
	else:
		text += "\n[color=yellow][b]" + tr(&"effect_option.oneheart") + " OFF[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 3) else "\n" + tr(&"effect_option.oneheart") + " OFF"
	if (StratagemHeroEffect_EffectGame.instance.check_is_able_to_start_core()):
		text += "\n[color=yellow][b]" + tr(&"effect_start") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n" + tr(&"effect_start")
	else:
		text += "\n[color=red][b]" + tr(&"effect_cannot_start") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n[color=dark_gray]" + tr(&"effect_cannot_start") + "[/color]"

func update_text_online() -> void:
	text = ""
	text += "[color=yellow][b]" + tr(&"menu_general_text_back") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 0) else tr(&"menu_general_text_back")
	match (StratagemHeroEffect_EffectGame.online_side):
		StratagemHeroEffect_EffectGame.OnlineSide.HOST:
			text += "\n[color=yellow][b]" + tr(&"effect_online.as_host") + " >>[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 1) else "\n" + tr(&"effect_online.as_host") + " >>"
			text += "\n[color=yellow][b]" + tr(&"effect_online.port") + " " + StratagemHeroEffect_EffectGame.online_port + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 2) else "\n" + tr(&"effect_online.port") + " " + StratagemHeroEffect_EffectGame.online_port
			match (StratagemHeroEffect_EffectGame.online_special_effect_mode):
				StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.RACING:
					text += "\n[color=yellow][b]" + tr(&"effect_mode_online.racing") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 3) else "\n" + tr(&"effect_mode_online.racing")
				StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.DICTATION_RACING:
					text += "\n[color=yellow][b]" + tr(&"effect_mode_online.dictation_racing") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 3) else "\n" + tr(&"effect_mode_online.dictation_racing")
				StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.CAPTUING:
					text += "\n[color=yellow][b]" + tr(&"effect_mode_online.capturing") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 3) else "\n" + tr(&"effect_mode_online.capturing")
			if (multiplayer.is_server()):
				if (StratagemHeroEffect_EffectGame.instance.check_is_able_to_start_core()):
					text += "\n[color=yellow][b]" + tr(&"effect_start_online") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n" + tr(&"effect_start_online")
				else:
					text += "\n[color=red][b]" + tr(&"effect_cannot_start_online") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n[color=dark_gray]" + tr(&"effect_cannot_start_online") + "[/color]"
			else:
				text += "\n[color=yellow][b]" + tr(&"effect_online.start_server") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n" + tr(&"effect_online.start_server")
		StratagemHeroEffect_EffectGame.OnlineSide.CLIENT:
			text += "\n[color=yellow][b]" + tr(&"effect_online.as_client") + " >>[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 1) else "\n" + tr(&"effect_online.as_client") + " >>"
			text += "\n[color=yellow][b]" + tr(&"effect_online.address") + " " + StratagemHeroEffect_EffectGame.online_address + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 2) else "\n" + tr(&"effect_online.address") + " " + StratagemHeroEffect_EffectGame.online_address
			text += "\n[color=yellow][b]" + tr(&"effect_online.port") + " " + StratagemHeroEffect_EffectGame.online_port + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 3) else "\n" + tr(&"effect_online.port") + " " + StratagemHeroEffect_EffectGame.online_port
			match (StratagemHeroEffect_EffectGame.online_client_connecting_state):
				StratagemHeroEffect_EffectGame.OnlineClientConnectingState.IDLE:
					text += "\n[color=yellow][b]" + tr(&"effect_online.connect_to_server") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n" + tr(&"effect_online.connect_to_server")
				StratagemHeroEffect_EffectGame.OnlineClientConnectingState.CONNECTING:
					text += "\n[color=yellow][b]" + tr(&"effect_online.connecting_to_server") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n" + tr(&"effect_online.connecting_to_server")
				StratagemHeroEffect_EffectGame.OnlineClientConnectingState.CONNECTED:
					text += "\n[color=yellow][b]" + tr(&"effect_online.disconnect_with_host") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n" + tr(&"effect_online.disconnect_with_host")
				StratagemHeroEffect_EffectGame.OnlineClientConnectingState.CONNECT_FAILED:
					text += "\n[color=red][b]" + tr(&"effect_online.connect_failed") + "[/b][/color]" if (StratagemHeroEffect_EffectGame.menu_option_focus == 4) else "\n" + tr(&"effect_online.connect_failed")
