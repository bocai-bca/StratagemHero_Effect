extends CanvasItem
class_name StratagemHeroEffect
## 主类

static var instance: StratagemHeroEffect

## 基准游戏尺寸
const BASE_SIZE: Vector2 = Vector2(1280.0, 720.0)

@onready var audio_title_music: AudioStreamPlayer = $Audio_TitleMusic as AudioStreamPlayer
@onready var audio_ready: AudioStreamPlayer = $Audio_Ready as AudioStreamPlayer
@onready var audio_menu_click: AudioStreamPlayer = $Audio_MenuClick as AudioStreamPlayer
@onready var audio_press: AudioStreamPlayer = $Audio_Press as AudioStreamPlayer
@onready var audio_done: AudioStreamPlayer = $Audio_Done as AudioStreamPlayer
@onready var audio_wrong: AudioStreamPlayer = $Audio_Wrong as AudioStreamPlayer
@onready var audio_start: AudioStreamPlayer = $Audio_Start as AudioStreamPlayer
@onready var audio_playing_music: AudioStreamPlayer = $Audio_PlayingMusic as AudioStreamPlayer
@onready var audio_game_over: AudioStreamPlayer = $Audio_GameOver as AudioStreamPlayer
@onready var audio_game_over_large: AudioStreamPlayer = $Audio_GameOverLarge as AudioStreamPlayer
@onready var audio_round_completes: Array[AudioStreamPlayer] = [
	$Audio_RoundComplete_0 as AudioStreamPlayer,
	$Audio_RoundComplete_1 as AudioStreamPlayer,
	$Audio_RoundComplete_2 as AudioStreamPlayer,
	$Audio_RoundComplete_3 as AudioStreamPlayer,
]

@onready var n_super_earth_background: TextureRect = $SuperEarthBackground as TextureRect
@onready var n_title: Label = $Title as Label
@onready var n_title_tip_text: Label = $TitleTipText as Label
@onready var n_title_line_top: ColorRect = $TitleLineTop as ColorRect
@onready var n_title_line_bottom: ColorRect = $TitleLineBottom as ColorRect
@onready var n_main_menu_text: MainMenu_Text = $MainMenu_Text as MainMenu_Text
@onready var n_help_text: RichTextLabel = $HelpText as RichTextLabel
@onready var n_about_text: RichTextLabel = $AboutText as RichTextLabel

@onready var classic_game: StratagemHeroEffect_ClassicGame = $ClassicGame as StratagemHeroEffect_ClassicGame
@onready var effect_game: StratagemHeroEffect_EffectGame = $EffectGame as StratagemHeroEffect_EffectGame

## 游戏状态
enum GameState{
	Init, ## 初始化
	Title, ## 标题界面
	MainMenu, ## 主菜单
	Settings, ## 设置菜单
	#EffectMenu, ## Effect模式开始之前的设置菜单
	Classic, ## 经典模式
	Effect, ## 效果模式
	Helps, ## 操作帮助
	#Statistics, ## 统计信息
	HighScores, ## 高分记录
	About, ## 关于
}
## 支持的语言
const LanguagesSupported: PackedStringArray = [
	"en",
	"zh",
]

static var config_file: ConfigFile = ConfigFile.new()
var game_state: GameState = GameState.Init:
	get:
		return game_state
	set(value):
		var from_game_state: GameState = game_state
		game_state = value
		match (value):
			GameState.Title:
				if (from_game_state == GameState.Init):
					audio_title_music.play()
			GameState.MainMenu:
				match (from_game_state):
					GameState.Title:
						audio_ready.play()
						menu_option_focus = 0
						transfer_timers[0].current = 0.0
						n_main_menu_text.update_text()
					GameState.Settings:
						audio_menu_click.play()
						menu_option_focus = 2
						n_main_menu_text.update_text()
					GameState.Classic:
						n_title.visible = true
						n_title_tip_text.visible = true
						n_title_line_top.visible = true
						n_title_line_bottom.visible = true
						n_main_menu_text.visible = true
						audio_title_music.play()
					GameState.Effect:
						n_title.visible = true
						n_title_tip_text.visible = true
						n_title_line_top.visible = true
						n_title_line_bottom.visible = true
						n_main_menu_text.visible = true
					GameState.Helps:
						audio_menu_click.play()
						menu_option_focus = 3
						n_main_menu_text.update_text()
						n_help_text.visible = false
					GameState.HighScores:
						audio_menu_click.play()
						menu_option_focus = 4
						n_main_menu_text.update_text()
					GameState.About:
						audio_menu_click.play()
						menu_option_focus = 5
						n_main_menu_text.update_text()
						n_about_text.visible = false
			GameState.Settings:
				audio_menu_click.play()
				menu_option_focus = 0
				n_main_menu_text.update_text()
			GameState.Classic:
				audio_title_music.stop()
				n_title.visible = false
				n_title_tip_text.visible = false
				n_title_line_top.visible = false
				n_title_line_bottom.visible = false
				n_main_menu_text.visible = false
			GameState.Effect:
				n_title.visible = false
				n_title_tip_text.visible = false
				n_title_line_top.visible = false
				n_title_line_bottom.visible = false
				n_main_menu_text.visible = false
			GameState.Helps:
				audio_menu_click.play()
				menu_option_focus = 0
				n_main_menu_text.update_text()
				n_help_text.visible = true
			GameState.HighScores:
				audio_menu_click.play()
				menu_option_focus = 0
				n_main_menu_text.update_text()
			GameState.About:
				audio_menu_click.play()
				menu_option_focus = 0
				n_main_menu_text.update_text()
				n_about_text.visible = true

## 菜单焦点
static var menu_option_focus: int
## 全局变换计数器列表
##  0 = 游戏状态变换计数器，用于：在标题按下空格后变换到主菜单的过程计时
static var transfer_timers: Array[TransferTimer] = [
	TransferTimer.new(0.2, true, 0.2),
]
## 高分榜显示类型
static var high_scores_showing_type: int = 0
## 分数清除确认
static var score_clear_comfirm: bool = false
## 分数是否在刚刚已清除
static var score_clear_already: bool = false

func _init() -> void:
	instance = self

func _enter_tree() -> void:
	get_window().min_size = Vector2i(640, 360)

func _ready() -> void:
	classic_game.game_end.connect(on_game_end)
	effect_game.game_end.connect(on_game_end)
	game_state = GameState.Title
	StratagemHeroEffect_SaveAccess.load_save()
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx)

func _unhandled_input(event: InputEvent) -> void:
	match (game_state):
		GameState.Title:
			if (event.is_action_released(&"space")):
				game_state = GameState.MainMenu
		GameState.MainMenu:
			if (event.is_action_released(&"up")):
				menu_option_focus -= 1
				if (menu_option_focus < 0):
					menu_option_focus = 5
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"down")):
				menu_option_focus += 1
				if (menu_option_focus > 5):
					menu_option_focus = 0
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"space")):
				menu_click()
		GameState.Settings:
			if (event.is_action_released(&"up")):
				score_clear_comfirm = false
				score_clear_already = false
				menu_option_focus -= 1
				if (menu_option_focus < 0):
					menu_option_focus = 4
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"down")):
				score_clear_comfirm = false
				score_clear_already = false
				menu_option_focus += 1
				if (menu_option_focus > 4):
					menu_option_focus = 0
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"space")):
				menu_click()
			if (event.is_action_released(&"left")):
				menu_turn_left()
			if (event.is_action_released(&"right")):
				menu_turn_right()
		GameState.Helps:
			if (event.is_action_released(&"space")):
				menu_click()
		GameState.HighScores:
			if (event.is_action_released(&"up")):
				menu_option_focus -= 1
				if (menu_option_focus < 0):
					menu_option_focus = 1
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"down")):
				menu_option_focus += 1
				if (menu_option_focus > 1):
					menu_option_focus = 0
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"space")):
				menu_click()
			if (event.is_action_released(&"left")):
				menu_turn_left()
			if (event.is_action_released(&"right")):
				menu_turn_right()
		GameState.About:
			if (event.is_action_released(&"space")):
				menu_click()

## 代表按下当前菜单的键，旨在实现高度封装
func menu_click() -> void:
	match (game_state):
		GameState.MainMenu:
			match (menu_option_focus):
				0: #经典
					game_state = GameState.Classic
					classic_game.start_game()
				1: #Effect
					game_state = GameState.Effect
					effect_game.start()
				2: #设置
					game_state = GameState.Settings
				3: #帮助
					game_state = GameState.Helps
				4: #高分记录
					game_state = GameState.HighScores
				5: #关于
					game_state = GameState.About
		GameState.Settings:
			match (menu_option_focus):
				0: #返回
					game_state = GameState.MainMenu
					StratagemHeroEffect_SaveAccess.store_save()
				3: #更改语言
					change_language()
					n_main_menu_text.update_text()
					audio_press.play()
				4: #清除分数记录
					if (not score_clear_already):
						audio_press.play()
						if (score_clear_comfirm):
							clear_score()
							score_clear_comfirm = false
						else:
							score_clear_comfirm = true
					n_main_menu_text.update_text()
		GameState.Helps:
			match (menu_option_focus):
				0: #返回
					game_state = GameState.MainMenu
		GameState.HighScores:
			match (menu_option_focus):
				0: #返回
					game_state = GameState.MainMenu
		GameState.About:
			match (menu_option_focus):
				0: #返回
					game_state = GameState.MainMenu

func menu_turn_left() -> void:
	match (game_state):
		GameState.Settings:
			match (menu_option_focus):
				1: #音乐音量
					StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music = clampf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music - 0.1, 0.0, 1.0)
					AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music)
					n_main_menu_text.update_text()
					audio_press.play()
				2: #音效音量
					StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx = clampf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx - 0.1, 0.0, 1.0)
					AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx)
					n_main_menu_text.update_text()
					audio_press.play()
		GameState.HighScores:
			match (menu_option_focus):
				1: #切换高分类别
					high_scores_showing_type -= 1
					if (high_scores_showing_type < 0):
						high_scores_showing_type = 5
					n_main_menu_text.update_text()
					audio_press.play()

func menu_turn_right() -> void:
	match (game_state):
		GameState.Settings:
			match (menu_option_focus):
				1: #音乐音量
					StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music = clampf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music + 0.1, 0.0, 1.0)
					AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music)
					n_main_menu_text.update_text()
					audio_press.play()
				2: #音效音量
					StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx = clampf(StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx + 0.1, 0.0, 1.0)
					AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx)
					n_main_menu_text.update_text()
					audio_press.play()
		GameState.HighScores:
			match (menu_option_focus):
				1: #切换高分类别
					high_scores_showing_type += 1
					if (high_scores_showing_type > 5):
						high_scores_showing_type = 0
					n_main_menu_text.update_text()
					audio_press.play()

func _process(delta: float) -> void:
	for transfer_timer in transfer_timers:
		transfer_timer.update(delta)

func _physics_process(_delta: float) -> void:
	var window_size: Vector2 = get_window().size
	n_help_text.size = window_size
	n_help_text.position = Vector2(0.0, window_size.y * 0.1)
	n_help_text.add_theme_font_size_override(&"normal_font_size", int(get_fit_size(36.0)))
	n_help_text.add_theme_constant_override(&"line_separation", int(get_fit_size(-12.0)))
	n_about_text.size = window_size
	n_about_text.position = Vector2(0.0, window_size.y * 0.1)
	n_about_text.add_theme_font_size_override(&"normal_font_size", int(get_fit_size(36.0)))
	n_about_text.add_theme_constant_override(&"line_separation", int(get_fit_size(-12.0)))

## 获取当前分辨率下合适的字体大小，需要给定在1280*720尺寸下的原始大小，不建议高频调用本方法，仅基于Y进行缩放
func get_font_size(original_size: float) -> float:
	var window: Window = get_window()
	return (original_size / BASE_SIZE.y) * window.size.y

## get_font_size()的改进型，用于需要同时兼顾X和Y的缩放，也不建议高频调用本方法
func get_fit_size(original_size: float) -> float:
	var window: Window = get_window()
	return minf((original_size / BASE_SIZE.x) * window.size.x, (original_size / BASE_SIZE.y) * window.size.y)

## 切换语言
static func change_language() -> void:
	var current_language_index: int = LanguagesSupported.find(TranslationServer.get_locale())
	current_language_index += 1
	if (current_language_index >= LanguagesSupported.size()):
		current_language_index = 0
	TranslationServer.set_locale(LanguagesSupported[current_language_index])

## 信号方法-游戏结束，用于使画面回到主类接管
func on_game_end() -> void:
	game_state = GameState.MainMenu

## 执行清除分数
func clear_score() -> void:
	StratagemHeroEffect_SaveAccess.clear_score()
	StratagemHeroEffect_SaveAccess.store_save()
	score_clear_already = true
