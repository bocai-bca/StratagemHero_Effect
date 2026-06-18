extends Control
class_name StratagemHeroEffect_EffectGame
## 效果模式主类

## 游戏结束时调用，用于广播本主类不再显示画面、转交焦点权
signal game_end()

static var instance: StratagemHeroEffect_EffectGame

@onready var n_title: Label = $Title as Label
@onready var n_title_line_top: ColorRect = $TitleLineTop as ColorRect
@onready var n_menu_text: StratagemHeroEffect_EffectGame_MenuText = $MenuText as StratagemHeroEffect_EffectGame_MenuText
@onready var n_stratagem_selection_panel: StratagemHeroEffect_EffectGame_StratagemSelectionPanel = $StratagemSelectionPanel as StratagemHeroEffect_EffectGame_StratagemSelectionPanel
@onready var n_description_text: StratagemHeroEffect_EffectGame_DescriptionText = $DescriptionText as StratagemHeroEffect_EffectGame_DescriptionText
@onready var n_game_core: StratagemHeroEffect_EffectGameCore = $EffectGameCore as StratagemHeroEffect_EffectGameCore
@onready var n_text_type_in: StratagemHeroEffect_EffectGame_TextTypeIn = $TextTypeIn as StratagemHeroEffect_EffectGame_TextTypeIn
@onready var n_text_type_in_line_edit: LineEdit = $TextTypeIn/LineEdit as LineEdit

## 游戏状态
enum GameState{
	IDLE, ## 闲置状态，相当于效果模式主类未开始
	MENU, ## 菜单界面
	STRATAGEM_EDIT, ## 编辑战备
	CORE, ## 核心(游戏运行中)
	MENU_ONLINE, ## 联机模式菜单界面
}
## 特殊效果模式
enum SpecialEffectMode{
	NONE, ## 无
	DICTATION, ## 默写
	GREATWALL, ## 长城
	MULTILINES, ## 多行
	TERMINAL, ## 终端
	DICTATION_MULTILINES, ## 多行默写
}
## 联机模式所属侧
enum OnlineSide{
	HOST, ## 作为主机
	CLIENT, ## 作为客机
}

## 菜单选项数量，值为实际数量-1
const MENU_OPTIONS_COUNT: int = 4
## 联机菜单选项数量-作为主机，值为实际数量-1
const ONLINE_MENU_OPTIONS_COUNT_HOST: int = 3
## 联机菜单选项数量-作为客机，值为实际数量-1
const ONLINE_MENU_OPTIONS_COUNT_CLIENT: int = 3
## 允许记录分数的最少战备启用数
const MINIMUM_STRATAGEMS_ENABLED_ABLE_TO_RECORD_HIGH_SCORE: int = 16

var game_state: GameState = GameState.IDLE:
	get:
		return game_state
	set(value):
		var from_state: GameState = game_state
		game_state = value
		match (value):
			GameState.IDLE:
				visible = false
				set_process(false)
				set_physics_process(false)
			GameState.MENU:
				match (from_state):
					GameState.IDLE:
						visible = true
						set_process(true)
						set_physics_process(true)
						n_title.text = "main_menu_text_effects"
						n_menu_text.update_text()
						n_description_text.update_text()
						StratagemHeroEffect.instance.audio_menu_click.play()
						_physics_process(0.0)
					GameState.STRATAGEM_EDIT:
						transfer_timers[0].current = 0.0
						n_menu_text.update_text()
						n_description_text.update_text()
					GameState.CORE:
						n_title.visible = true
						n_title_line_top.visible = true
						n_menu_text.visible = true
						n_description_text.visible = true
						n_stratagem_selection_panel.visible = true
						menu_option_focus = 0
						n_menu_text.update_text()
						n_description_text.update_text()
			GameState.MENU_ONLINE:
				match (from_state):
					GameState.IDLE:
						visible = true
						set_process(true)
						set_physics_process(true)
						n_title.text = "main_menu_text_online_effects"
						n_menu_text.update_text_online()
						n_description_text.update_text()
						StratagemHeroEffect.instance.audio_menu_click.play()
						_physics_process(0.0)
			GameState.STRATAGEM_EDIT:
				transfer_timers[0].current = 0.0
				n_stratagem_selection_panel.open_panel()
			GameState.CORE:
				n_title.visible = false
				n_title_line_top.visible = false
				n_menu_text.visible = false
				n_description_text.visible = false
				n_stratagem_selection_panel.visible = false
				n_game_core.start()
## 变换计时器列表
##  0 = 战备选择面板动画计时器
static var transfer_timers: Array[TransferTimer] = [
	TransferTimer.new(0.4, true, 0.4),
]
## 菜单选项焦点
static var menu_option_focus: int = 0
## 当前的特殊效果模式
static var special_effect_mode: SpecialEffectMode = SpecialEffectMode.NONE
## 是否开启一命模式
static var one_heart: bool = false
## 联机模式所属侧
static var online_side: OnlineSide = OnlineSide.HOST
## 联机模式端口
static var online_port: String = "0"
## 联机模式地址
static var online_address: String = "localhost"
## 记录上次打开输入框是要修改端口还是地址，false表示端口，true表示地址
static var last_edit_is_port_or_address: bool = false

func _init() -> void:
	instance = self

func _ready() -> void:
	n_text_type_in.edit_exited.connect(on_text_type_in_submit)
	game_state = GameState.IDLE

## 总启动入口，用于启动本主类，设计为由主菜单进入时调用
func start(online: bool) -> void:
	if (online):
		game_state = GameState.MENU_ONLINE
	else:
		game_state = GameState.MENU

func _process(delta: float) -> void:
	for transfer_timer in transfer_timers:
		transfer_timer.update(delta)
	n_stratagem_selection_panel.process(delta)
	n_game_core.process(delta)

func _physics_process(_delta: float) -> void:
	var window: Window = get_window()
	size = Vector2(window.size)
	n_stratagem_selection_panel.physics_process()
	match (game_state):
		GameState.MENU:
			n_title.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(72.0))
			n_title.size = Vector2(window.size.x, 0.0)
			n_title_line_top.size = Vector2(window.size.x, StratagemHeroEffect.instance.get_fit_size(16.0))
			n_title_line_top.position = Vector2(0.0, n_title.size.y)
			n_menu_text.add_theme_font_size_override(&"normal_font_size", int(StratagemHeroEffect.instance.get_font_size(64.0)))
			n_menu_text.add_theme_font_size_override(&"bold_font_size", int(StratagemHeroEffect.instance.get_font_size(72.0)))
			n_description_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(36.0))
			n_menu_text.size = size
			n_description_text.size = size
		GameState.CORE:
			n_game_core.fit_size(size)
	var fit_size: int = int(StratagemHeroEffect.instance.get_fit_size(4.0))
	for button_stylebox in (
		[
			theme.get_stylebox(&"normal", &"Button") as StyleBoxFlat,
			theme.get_stylebox(&"focus", &"Button") as StyleBoxFlat,
			theme.get_stylebox(&"pressed", &"Button") as StyleBoxFlat
		] as Array[StyleBoxFlat]
	):
		button_stylebox.border_width_top = fit_size
		button_stylebox.border_width_bottom = fit_size
		button_stylebox.border_width_right = fit_size
		button_stylebox.border_width_left = fit_size

func _unhandled_input(event: InputEvent) -> void:
	match (game_state):
		GameState.MENU:
			if (event.is_action_released(&"up")):
				menu_option_focus -= 1
				if (menu_option_focus < 0):
					menu_option_focus = MENU_OPTIONS_COUNT
				n_menu_text.update_text()
				n_description_text.update_text()
				StratagemHeroEffect.instance.audio_press.play()
			if (event.is_action_released(&"down")):
				menu_option_focus += 1
				if (menu_option_focus > MENU_OPTIONS_COUNT):
					menu_option_focus = 0
				n_menu_text.update_text()
				n_description_text.update_text()
				StratagemHeroEffect.instance.audio_press.play()
			if (event.is_action_released(&"space")):
				get_viewport().set_input_as_handled()
				menu_click()
		GameState.MENU_ONLINE:
			if (event.is_action_released(&"up")):
				menu_option_focus -= 1
				n_menu_text.update_text_online()
				if (online_side == OnlineSide.HOST):
					if (menu_option_focus < 0):
						menu_option_focus = ONLINE_MENU_OPTIONS_COUNT_HOST
					n_description_text.update_text_online_host()
				elif (online_side == OnlineSide.CLIENT):
					if (menu_option_focus < 0):
						menu_option_focus = ONLINE_MENU_OPTIONS_COUNT_CLIENT
					n_description_text.update_text_online_client()
				StratagemHeroEffect.instance.audio_press.play()
			if (event.is_action_released(&"down")):
				menu_option_focus += 1
				n_menu_text.update_text_online()
				if (online_side == OnlineSide.HOST):
					if (menu_option_focus > ONLINE_MENU_OPTIONS_COUNT_HOST):
						menu_option_focus = 0
					n_description_text.update_text_online_host()
				elif (online_side == OnlineSide.CLIENT):
					if (menu_option_focus > ONLINE_MENU_OPTIONS_COUNT_CLIENT):
						menu_option_focus = 0
					n_description_text.update_text_online_client()
				StratagemHeroEffect.instance.audio_press.play()
			if (event.is_action_released(&"space")):
				get_viewport().set_input_as_handled()
				menu_click_online()
	_physics_process(0.0)

func stop_game() -> void:
	game_state = GameState.IDLE
	emit_signal(&"game_end")

func menu_click() -> void:
	match (menu_option_focus):
		0: #返回
			StratagemHeroEffect.instance.audio_menu_click.play()
			stop_game()
		1: #切换特殊效果模式
			match (special_effect_mode):
				SpecialEffectMode.NONE:
					special_effect_mode = SpecialEffectMode.DICTATION
				SpecialEffectMode.DICTATION:
					special_effect_mode = SpecialEffectMode.GREATWALL
				SpecialEffectMode.GREATWALL:
					special_effect_mode = SpecialEffectMode.MULTILINES
				SpecialEffectMode.MULTILINES:
					special_effect_mode = SpecialEffectMode.TERMINAL
				SpecialEffectMode.TERMINAL:
					special_effect_mode = SpecialEffectMode.NONE
			n_menu_text.update_text()
			n_description_text.update_text()
			StratagemHeroEffect.instance.audio_menu_click.play()
		2: #设置战备列表
			n_menu_text.update_text()
			StratagemHeroEffect.instance.audio_menu_click.play()
			game_state = GameState.STRATAGEM_EDIT
		3: #切换一命模式
			one_heart = !one_heart
			n_menu_text.update_text()
			StratagemHeroEffect.instance.audio_menu_click.play()
		4: #开始游戏
			if (!check_is_able_to_start_core()):
				return
			start_core()

func menu_click_online() -> void:
	if (menu_option_focus == 0):
		StratagemHeroEffect.instance.audio_menu_click.play()
		stop_game()
		return
	if (menu_option_focus == 1): # 更换联机侧
		StratagemHeroEffect.instance.audio_menu_click.play()
		online_side = OnlineSide.HOST if online_side == OnlineSide.CLIENT else OnlineSide.CLIENT
		n_menu_text.update_text_online()
		return
	match (online_side):
		OnlineSide.HOST:
			match (menu_option_focus):
				2: #端口
					last_edit_is_port_or_address = false
					start_text_edit(online_port)
		OnlineSide.CLIENT:
			match (menu_option_focus):
				2: #地址
					last_edit_is_port_or_address = true
					start_text_edit(online_address)
				3: #端口
					last_edit_is_port_or_address = false
					start_text_edit(online_port)

func check_is_able_to_start_core() -> bool:
	match (special_effect_mode):
		SpecialEffectMode.NONE, SpecialEffectMode.DICTATION, SpecialEffectMode.MULTILINES:
			if (n_stratagem_selection_panel.stratagems_enabled.size() <= 0):
				return false
	return true

func start_core() -> void:
	game_state = GameState.CORE

## 获取已翻译的特殊模式名称
static func get_special_mode_name_translated() -> String:
	match (special_effect_mode):
		SpecialEffectMode.NONE:
			return TranslationServer.translate(&"effect_text.lantern_slide.generic.mode_none")
		SpecialEffectMode.DICTATION:
			return TranslationServer.translate(&"effect_text.lantern_slide.generic.mode_dictation")
		SpecialEffectMode.GREATWALL:
			return TranslationServer.translate(&"effect_text.lantern_slide.generic.mode_greatwall")
		SpecialEffectMode.MULTILINES:
			return TranslationServer.translate(&"effect_text.lantern_slide.generic.mode_multilines")
		SpecialEffectMode.TERMINAL:
			return TranslationServer.translate(&"effect_text.lantern_slide.generic.mode_terminal")
	return ""

func start_text_edit(init_text: String) -> void:
	n_text_type_in.visible = true
	n_text_type_in_line_edit.text = init_text
	n_text_type_in_line_edit.edit()
	n_text_type_in_line_edit.caret_column = n_text_type_in_line_edit.text.length()

func on_text_type_in_submit() -> void:
	var text: String = n_text_type_in_line_edit.text
	if (last_edit_is_port_or_address):
		online_address = text
		n_text_type_in.visible = false
	else:
		var port_num: int = text.to_int()
		online_port = str(clampi(port_num, 0, 65535))
		text = online_port
		n_text_type_in.visible = false
	n_menu_text.update_text_online()
