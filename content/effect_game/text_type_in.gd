extends PanelContainer
class_name StratagemHeroEffect_EffectGame_TextTypeIn
## 效果模式文本输入框

signal edit_exited()

func _unhandled_input(event: InputEvent) -> void:
	if (visible):
		if (event.is_action_released(&"space")):
				get_viewport().set_input_as_handled()
				emit_signal(&"edit_exited")
		get_viewport().set_input_as_handled()
