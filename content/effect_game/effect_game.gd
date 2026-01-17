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

## 游戏状态
enum GameState{
	IDLE, ## 闲置状态，相当于效果模式主类未开始
	MENU, ## 菜单界面
	STRATAGEM_EDIT, ## 编辑战备
	CORE, ## 核心(游戏运行中)
}
## 特殊效果模式
enum SpecialEffectMode{
	NONE, ## 无
	DICTATION, ## 默写
	GREATWALL, ## 长城
	MULTILINES, ## 多行
}

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
						n_menu_text.update_text()
						n_description_text.update_text()
						StratagemHeroEffect.instance.audio_menu_click.play()
						_physics_process(0.0)
					GameState.STRATAGEM_EDIT:
						transfer_timers[0].current = 0.0
						n_menu_text.update_text()
						n_description_text.update_text()
			GameState.STRATAGEM_EDIT:
				transfer_timers[0].current = 0.0
				n_stratagem_selection_panel.open_panel()
			GameState.CORE:
				n_game_core.start(special_effect_mode)
## 变换计时器列表
##  0 = 战备选择面板动画计时器
static var transfer_timers: Array[TransferTimer] = [
	TransferTimer.new(0.4, true, 0),
]
## 菜单选项焦点
static var menu_option_focus: int = 0
## 当前的特殊效果模式
static var special_effect_mode: SpecialEffectMode = SpecialEffectMode.NONE
## 是否开启一命模式
static var one_heart: bool = false

func _init() -> void:
	instance = self
	set_process(false)
	set_physics_process(false)

## 总启动入口，用于启动本主类，设计为由主菜单进入时调用
func start() -> void:
	game_state = GameState.MENU

func _process(delta: float) -> void:
	for transfer_timer in transfer_timers:
		transfer_timer.update(delta)
	n_stratagem_selection_panel.process()

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
					menu_option_focus = 4
				n_menu_text.update_text()
				n_description_text.update_text()
				StratagemHeroEffect.instance.audio_press.play()
			if (event.is_action_released(&"down")):
				menu_option_focus += 1
				if (menu_option_focus > 4):
					menu_option_focus = 0
				n_menu_text.update_text()
				n_description_text.update_text()
				StratagemHeroEffect.instance.audio_press.play()
			if (event.is_action_released(&"space")):
				get_viewport().set_input_as_handled()
				menu_click()

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

func check_is_able_to_start_core() -> bool:
	match (special_effect_mode):
		SpecialEffectMode.NONE, SpecialEffectMode.DICTATION, SpecialEffectMode.MULTILINES:
			if (n_stratagem_selection_panel.stratagems_enabled.size() <= 0):
				return false
	return true

func start_core() -> void:
	game_state = GameState.CORE
