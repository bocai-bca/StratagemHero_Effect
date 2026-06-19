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
				StratagemHeroEffect_EffectGame.SpecialEffectMode.TERMINAL:
					text = tr(&"effect_description.effect_mode.terminal")
		2: #编辑战备
			text = tr(&"effect_description.effect_option.edit_stratagems")
		3: #一命模式
			text = tr(&"effect_description.effect_option.oneheart")
		4: #开始游戏
			text = tr(&"effect_description.effect_start")

func update_text_online_host() -> void:
	match (StratagemHeroEffect_EffectGame.menu_option_focus):
		0: #返回
			text = tr(&"effect_description.back_to_title")
		1: #切换侧
			text = tr(&"effect_online_description.as_host")
		2: #端口
			text = tr(&"effect_online_description.set_port_host")
		3: #联机特殊效果模式
			match (StratagemHeroEffect_EffectGame.online_special_effect_mode):
				StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.RACING:
					text = tr(&"effect_online_description.racing")
				StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.DICTATION_RACING:
					text = tr(&"effect_online_description.dictation_racing")
				StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.CAPTUING:
					text = tr(&"effect_online_description.capturing")
		4: #开启服务器/开始游戏
			if (multiplayer.is_server()):
				text = tr(&"effect_online_description.effect_start")
			else:
				text = tr(&"effect_online_description.start_server")

func update_text_online_client() -> void:
	match (StratagemHeroEffect_EffectGame.menu_option_focus):
		0: #返回
			text = tr(&"effect_description.back_to_title")
		1: #切换侧
			text = tr(&"effect_online_description.as_client")
		2: #主机地址
			text = tr(&"effect_online_description.set_address")
		3: #主机端口
			text = tr(&"effect_online_description.set_port_client")
		4: #连接
			match (StratagemHeroEffect_EffectGame.online_client_connecting_state):
				StratagemHeroEffect_EffectGame.OnlineClientConnectingState.IDLE:
					text = tr(&"effect_online_description.connect_to_server")
				StratagemHeroEffect_EffectGame.OnlineClientConnectingState.CONNECTING:
					text = tr(&"effect_online_description.connecting_to_server")
				StratagemHeroEffect_EffectGame.OnlineClientConnectingState.CONNECTED:
					text = tr(&"effect_online_description.disconnect_with_host")
				StratagemHeroEffect_EffectGame.OnlineClientConnectingState.CONNECT_FAILED:
					text = tr(&"effect_online_description.connect_failed")
