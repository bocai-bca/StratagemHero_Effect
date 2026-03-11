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
@onready var n_detail_bar: Node2D = $DetailBar as Node2D
@onready var n_detail_bar_panel: PanelContainer = $DetailBar/PC as PanelContainer
@onready var n_detail_bar_container: HBoxContainer = $DetailBar/PC/HBC as HBoxContainer
@onready var n_detail_bar_name: Label = $DetailBar/PC/HBC/Name as Label
var n_detail_bar_arrows: Array[TextureRect] = []

## 详细信息栏的动画时间
const DETAIL_BAR_ANIMATION_TIME: float = 0.6

static var instance: StratagemHeroEffect_EffectGame_StratagemSelectionPanel
## 记录所有已启用的战备
static var stratagems_enabled: Array[StringName] = []
## 暂存调整之前的已启用的战备，用于在取消时还原
static var stratagems_enabled_original: Array[StringName]
## 记录面板隐藏时的坐标Y
var position_y_when_hidden: float = 720.0
## 战备停留计时器
static var stratagem_stay_timer: float = 0.0
## 当前焦点所在的战备名称
static var focus_stratagem_name: StringName:
	get:
		return focus_stratagem_name
	set(new_value):
		if (focus_stratagem_name.is_empty() and new_value.is_empty()):
			pass
		elif (not focus_stratagem_name.is_empty() and not new_value.is_empty()):
			pass
		else:
			stratagem_stay_timer = 0.0
		focus_stratagem_name = new_value
		if (not new_value.is_empty()):
			instance.update_detail_bar_to_new_stratagem()

func _enter_tree() -> void:
	stratagems_enabled = StratagemData.list.keys() as Array[StringName]
	instance = self

func process(delta: float) -> void:
	stratagem_stay_timer += delta
	if (StratagemHeroEffect_EffectGame.instance.game_state == StratagemHeroEffect_EffectGame.GameState.STRATAGEM_EDIT):
		position.y = lerpf(position_y_when_hidden, 0.0, ease(StratagemHeroEffect_EffectGame.transfer_timers[0].percent, 0.3))
		if (focus_stratagem_name.is_empty()):
			n_detail_bar.position = Vector2(
				0.0,
				lerpf(0.0, -n_detail_bar_container.size.y, ease(clampf(stratagem_stay_timer / DETAIL_BAR_ANIMATION_TIME, 0.0, 1.0), 0.3))
			)
		else:
			n_detail_bar.position = Vector2(
				0.0,
				lerpf(-n_detail_bar_container.size.y, 0.0, ease(clampf(stratagem_stay_timer / DETAIL_BAR_ANIMATION_TIME, 0.0, 1.0), 0.3))
			)
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
	theme.set_font_size(&"font_size", &"Label", int(StratagemHeroEffect.instance.get_fit_size(32.0)))
	(n_detail_bar_panel.theme.get_stylebox(&"panel", &"PanelContainer") as StyleBoxFlat).border_width_bottom = int(StratagemHeroEffect.instance.get_fit_size(4.0))
	n_detail_bar_panel.theme.set_font_size(&"font_size", &"Label", int(StratagemHeroEffect.instance.get_fit_size(32.0)))

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
	n_cancel_button.call_deferred(&"grab_focus")

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
	focus_stratagem_name = &""

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

func update_detail_bar_to_new_stratagem() -> void:
	if (focus_stratagem_name.is_empty()):
		return
	var stratagem_data: StratagemData = StratagemData.list[focus_stratagem_name]
	n_detail_bar_name.text = tr(stratagem_data.name_key)
	while (n_detail_bar_arrows.size() < stratagem_data.codes.size()):
		var new_arrow: TextureRect = TextureRect.new()
		new_arrow.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		n_detail_bar_container.add_child(new_arrow)
		n_detail_bar_arrows.append(new_arrow)
	for i in n_detail_bar_arrows.size():
		var n_arrow: TextureRect = n_detail_bar_arrows[i]
		if (i >= stratagem_data.codes.size()):
			n_arrow.visible = false
			continue
		n_arrow.visible = true
		var this_code: StratagemData.CodeArrow = stratagem_data.codes[i]
		match (this_code):
			StratagemData.CodeArrow.UP:
				n_arrow.texture = preload("res://resources/images/arrow_v.svg")
				n_arrow.flip_h = false
				n_arrow.flip_v = false
			StratagemData.CodeArrow.DOWN:
				n_arrow.texture = preload("res://resources/images/arrow_v.svg")
				n_arrow.flip_h = false
				n_arrow.flip_v = true
			StratagemData.CodeArrow.LEFT:
				n_arrow.texture = preload("res://resources/images/arrow_h.svg")
				n_arrow.flip_h = false
				n_arrow.flip_v = false
			StratagemData.CodeArrow.RIGHT:
				n_arrow.texture = preload("res://resources/images/arrow_h.svg")
				n_arrow.flip_h = true
				n_arrow.flip_v = false
