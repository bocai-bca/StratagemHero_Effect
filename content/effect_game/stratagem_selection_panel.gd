extends PanelContainer
class_name StratagemHeroEffect_EffectGame_StratagemSelectionPanel
## 效果模式战备选择面板

@onready var n_title_tip: Label = $VBC/TitleTip as Label
@onready var n_support_class_name: Label = $VBC/HBC/SupportClass/Name as Label
@onready var n_support_class_icons_container: HFlowContainer = $VBC/HBC/SupportClass/HFC as HFlowContainer
@onready var n_attack_class_icons_container: HFlowContainer = $VBC/HBC/AttackClass/HFC as HFlowContainer
@onready var n_defence_class_icons_container: HFlowContainer = $VBC/HBC/DefenceClass/HFC as HFlowContainer
@onready var n_common_class_icons_container: HFlowContainer = $VBC/HBC/CommonClass/HFC as HFlowContainer
@onready var n_buttons_container: VBoxContainer = $VBC/HBC/Buttons as VBoxContainer
@onready var n_cancel_button: Button = $VBC/HBC/Buttons/Cancel as Button

## 记录所有已启用的战备
static var stratagems_enabled: Array[StringName] = []
## 暂存调整之前的已启用的战备，用于在取消时还原
static var stratagems_enabled_original: Array[StringName]
## 记录面板隐藏时的坐标Y
var position_y_when_hidden: float = 720.0

func _enter_tree() -> void:
	stratagems_enabled = StratagemData.list.keys() as Array[StringName]

func process() -> void:
	if (StratagemHeroEffect_EffectGame.instance.game_state == StratagemHeroEffect_EffectGame.GameState.STRATAGEM_EDIT):
		position.y = lerpf(position_y_when_hidden, 0.0, ease(StratagemHeroEffect_EffectGame.transfer_timers[0].percent, 0.3))
		return
	position.y = lerpf(0.0, position_y_when_hidden, ease(StratagemHeroEffect_EffectGame.transfer_timers[0].percent, 0.3))

func physics_process() -> void:
	var window: Window = get_window()
	size = Vector2(window.size)
	position_y_when_hidden = window.size.y
	n_title_tip.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(48.0))
	n_support_class_name.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(36.0))
	theme.set_font_size(&"font_size", &"Button", int(StratagemHeroEffect.instance.get_font_size(32.0)))
	var border_width: int = int(StratagemHeroEffect.instance.get_font_size(4.0))
	StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.icon_frame_stylebox_normal.border_width_left = border_width
	StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.icon_frame_stylebox_normal.border_width_right = border_width
	StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.icon_frame_stylebox_normal.border_width_top = border_width
	StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.icon_frame_stylebox_normal.border_width_bottom = border_width
	StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.icon_frame_stylebox_focus.border_width_left = border_width
	StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.icon_frame_stylebox_focus.border_width_right = border_width
	StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.icon_frame_stylebox_focus.border_width_top = border_width
	StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.icon_frame_stylebox_focus.border_width_bottom = border_width

## 放置图标
func place_icons() -> void:
	for stratagem_data_name in (StratagemData.list.keys() as Array[StringName]):
		var stratagem_data: StratagemData = StratagemData.list[stratagem_data_name]
		match (stratagem_data.stratagem_class):
			StratagemData.StratagemClass.SUPPORT:
				n_support_class_icons_container.add_child(StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.create(stratagem_data_name, stratagem_data.icon))
			StratagemData.StratagemClass.ATTACK:
				n_attack_class_icons_container.add_child(StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.create(stratagem_data_name, stratagem_data.icon))
			StratagemData.StratagemClass.DEFENCE:
				n_defence_class_icons_container.add_child(StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.create(stratagem_data_name, stratagem_data.icon))
			StratagemData.StratagemClass.COMMON:
				n_common_class_icons_container.add_child(StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton.create(stratagem_data_name, stratagem_data.icon))

## 移除图标
func remove_icons() -> void:
	for node in n_common_class_icons_container.get_children() + n_support_class_icons_container.get_children() + n_attack_class_icons_container.get_children() + n_defence_class_icons_container.get_children():
		node.queue_free()

func open_panel() -> void:
	place_icons()
	stratagems_enabled_original = stratagems_enabled.duplicate()
	for button in (n_buttons_container.get_children() as Array[Button]):
		button.focus_mode = Control.FOCUS_ALL
	n_cancel_button.grab_focus()

func close_panel(is_cancel: bool) -> void:
	remove_icons()
	StratagemHeroEffect.instance.audio_menu_click.play()
	for button in (n_buttons_container.get_children() as Array[Button]):
		button.focus_mode = Control.FOCUS_NONE
	if (is_cancel):
		stratagems_enabled = stratagems_enabled_original
	StratagemHeroEffect_EffectGame.instance.game_state = StratagemHeroEffect_EffectGame.GameState.MENU

func on_button_focus_entered() -> void:
	StratagemHeroEffect.instance.audio_press.play()

func on_switch_all_pressed() -> void:
	StratagemHeroEffect.instance.audio_menu_click.play()
	if (stratagems_enabled.size() == 0): # 如果一个都没有启用，就开启全部
		stratagems_enabled = StratagemData.list.keys() as Array[StringName]
	else:
		stratagems_enabled.clear() # 否则关闭全部
	update_all_icons_lightness()

func on_switch_class_pressed(target_class: StratagemData.StratagemClass) -> void:
	StratagemHeroEffect.instance.audio_menu_click.play()
	var remove_index: Array[int] = []
	for stratagem_index in stratagems_enabled.size():
		var stratagem: StratagemData = StratagemData.list[stratagems_enabled[stratagem_index]]
		if (stratagem.stratagem_class == target_class): # 如果存在哪怕一个，就关闭全部
			remove_index.insert(0, stratagem_index)
	if (remove_index.size() != 0):
		for index in remove_index:
			stratagems_enabled.remove_at(index)
		update_all_icons_lightness()
		return
	for stratagem_name in (StratagemData.list.keys() as Array[StringName]):
		var stratagem: StratagemData = StratagemData.list[stratagem_name]
		if (stratagem.stratagem_class == target_class):
			stratagems_enabled.append(stratagem_name)
	update_all_icons_lightness()

func on_switch_warbonds_pressed() -> void:
	StratagemHeroEffect.instance.audio_menu_click.play()
	var remove_index: Array[int] = []
	for stratagem_index in stratagems_enabled.size():
		var stratagem: StratagemData = StratagemData.list[stratagems_enabled[stratagem_index]]
		if (stratagem.is_in_warbonds): # 如果存在哪怕一个，就关闭全部
			remove_index.insert(0, stratagem_index)
	if (remove_index.size() != 0):
		for index in remove_index:
			stratagems_enabled.remove_at(index)
		update_all_icons_lightness()
		return
	for stratagem_name in (StratagemData.list.keys() as Array[StringName]):
		var stratagem: StratagemData = StratagemData.list[stratagem_name]
		if (stratagem.is_in_warbonds):
			stratagems_enabled.append(stratagem_name)
	update_all_icons_lightness()

func update_all_icons_lightness() -> void:
	for icon in ((n_common_class_icons_container.get_children() + n_support_class_icons_container.get_children() + n_attack_class_icons_container.get_children() + n_defence_class_icons_container.get_children()) as Array[StratagemHeroEffect_EffectGame_StratagemSelectionPanel_IconButton]):
		icon.update_lightness()
