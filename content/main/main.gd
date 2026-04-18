extends CanvasItem
class_name StratagemHeroEffect
## 主类

static var instance: StratagemHeroEffect

## 基准游戏尺寸
const BASE_SIZE: Vector2 = Vector2(1280.0, 720.0)

@onready var audio_title_music: AudioStreamPlayer = $Audio_TitleMusic as AudioStreamPlayer
@onready var audio_ready: AudioStreamPlayer = $Audio_Ready as AudioStreamPlayer
@onready var audio_menu_click: AudioStreamPlayer = $Audio_MenuClick as AudioStreamPlayer
@onready var audio_press: AudioStreamPlayer = $Audio_Press_OriginalRandom as AudioStreamPlayer
@onready var audio_press_up: AudioStreamPlayer = $Audio_Press_Up as AudioStreamPlayer
@onready var audio_press_down: AudioStreamPlayer = $Audio_Press_Down as AudioStreamPlayer
@onready var audio_press_left: AudioStreamPlayer = $Audio_Press_Left as AudioStreamPlayer
@onready var audio_press_right: AudioStreamPlayer = $Audio_Press_Right as AudioStreamPlayer
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
						settings_menu_page = 0
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
## 设置菜单当前所在页
static var settings_menu_page: int = 0

func _init() -> void:
	instance = self

func _enter_tree() -> void:
	get_window().min_size = Vector2i(640, 360)
	StratagemHeroEffect_SaveAccess.load_save()

func _ready() -> void:
	classic_game.game_end.connect(on_game_end)
	effect_game.game_end.connect(on_game_end)
	game_state = GameState.Title
	load_sfx_variant(StratagemHeroEffect_SaveAccess.save_struct_in_memory.sfx_variant)
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
				match (settings_menu_page):
					0:
						if (menu_option_focus < 0):
							menu_option_focus = 5
					1:
						if (menu_option_focus < 0):
							menu_option_focus = 2
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"down")):
				score_clear_comfirm = false
				score_clear_already = false
				menu_option_focus += 1
				match (settings_menu_page):
					0:
						if (menu_option_focus > 5):
							menu_option_focus = 0
					1:
						if (menu_option_focus > 2):
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
			match (settings_menu_page):
				0:
					match (menu_option_focus):
						0: #返回
							game_state = GameState.MainMenu
							StratagemHeroEffect_SaveAccess.store_save()
						4: #更换箭头样式
							StratagemHeroEffect_SaveAccess.save_struct_in_memory.arrow_style += 1
							if (StratagemHeroEffect_SaveAccess.save_struct_in_memory.arrow_style > 2):
								StratagemHeroEffect_SaveAccess.save_struct_in_memory.arrow_style = 0
							n_main_menu_text.update_text()
							audio_press.play()
						5: #更改音效变体
							change_sfx_variant()
							n_main_menu_text.update_text()
							audio_press.play()
				1:
					match (menu_option_focus):
						0: #返回
							game_state = GameState.MainMenu
							StratagemHeroEffect_SaveAccess.store_save()
						1: #更改语言
							change_language()
							n_main_menu_text.update_text()
							audio_press.play()
						2: #清除分数记录
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
			match (settings_menu_page):
				0:
					match (menu_option_focus):
						1: #音乐音量
							StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music = clampf(roundf((StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music - 0.1) * 10.0) / 10.0, 0.0, 1.0)
							AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music)
							n_main_menu_text.update_text()
							audio_press.play()
						2: #音效音量
							StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx = clampf(roundf((StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx - 0.1) * 10.0) / 10.0, 0.0, 1.0)
							AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx)
							n_main_menu_text.update_text()
							audio_press.play()
						3: #界面元素缩放
							StratagemHeroEffect_SaveAccess.save_struct_in_memory.element_scale = clampf(roundf((StratagemHeroEffect_SaveAccess.save_struct_in_memory.element_scale - 0.1) * 10.0) / 10.0, 0.2, 1.0)
							_physics_process(0.0)
							n_main_menu_text.update_text()
							audio_press.play()
				1:
					pass
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
			match (settings_menu_page):
				0:
					match (menu_option_focus):
						0: #换页
							settings_menu_page = 1
							n_main_menu_text.update_text()
							audio_press.play()
						1: #音乐音量
							StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music = clampf(roundf((StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music + 0.1) * 10.0) / 10.0, 0.0, 1.0)
							AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_music)
							n_main_menu_text.update_text()
							audio_press.play()
						2: #音效音量
							StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx = clampf(roundf((StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx + 0.1) * 10.0) / 10.0, 0.0, 1.0)
							AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX"), StratagemHeroEffect_SaveAccess.save_struct_in_memory.volume_sfx)
							n_main_menu_text.update_text()
							audio_press.play()
						3: #界面元素缩放
							StratagemHeroEffect_SaveAccess.save_struct_in_memory.element_scale = clampf(roundf((StratagemHeroEffect_SaveAccess.save_struct_in_memory.element_scale + 0.1) * 10.0) / 10.0, 0.2, 1.0)
							_physics_process(0.0)
							n_main_menu_text.update_text()
							audio_press.play()
				1:
					match (menu_option_focus):
						0: #换页
							settings_menu_page = 0
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
	return (original_size / BASE_SIZE.y) * window.size.y * StratagemHeroEffect_SaveAccess.save_struct_in_memory.element_scale

## get_font_size()的改进型，用于需要同时兼顾X和Y的缩放，也不建议高频调用本方法
func get_fit_size(original_size: float) -> float:
	var window: Window = get_window()
	return minf((original_size / BASE_SIZE.x) * window.size.x, (original_size / BASE_SIZE.y) * window.size.y) * StratagemHeroEffect_SaveAccess.save_struct_in_memory.element_scale

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

func change_sfx_variant() -> void:
	var current_variant: String = StratagemHeroEffect_SaveAccess.save_struct_in_memory.sfx_variant
	if (not SoundManagment.sfx_variants.has(current_variant)):
		current_variant = "normal"
	else:
		var index: int = SoundManagment.sfx_variants.find(current_variant)
		index = (index + 1) % SoundManagment.sfx_variants.size()
		current_variant = SoundManagment.sfx_variants[index]
	StratagemHeroEffect_SaveAccess.save_struct_in_memory.sfx_variant = current_variant
	load_sfx_variant(current_variant)

func load_sfx_variant(variant: String) -> void:
	audio_press.stream = SoundManagment.load_sound(variant, "press")
	audio_press_up.stream = SoundManagment.load_sound(variant, "press_up")
	audio_press_down.stream = SoundManagment.load_sound(variant, "press_down")
	audio_press_left.stream = SoundManagment.load_sound(variant, "press_left")
	audio_press_right.stream = SoundManagment.load_sound(variant, "press_right")
	audio_done.stream = SoundManagment.load_sound(variant, "done")
	audio_wrong.stream = SoundManagment.load_sound(variant, "wrong")
	SoundManagment.load_press_only(variant)

func play_audio_wrong(direction: StratagemData.CodeArrow) -> void:
	if (SoundManagment.sfx_loaded_press_only_cache):
		play_audio_press(direction)
		return
	StratagemHeroEffect.instance.audio_wrong.play()

func play_audio_press(direction: StratagemData.CodeArrow) -> void:
	match (direction):
		StratagemData.CodeArrow.UP:
			StratagemHeroEffect.instance.audio_press_up.play()
		StratagemData.CodeArrow.DOWN:
			StratagemHeroEffect.instance.audio_press_down.play()
		StratagemData.CodeArrow.LEFT:
			StratagemHeroEffect.instance.audio_press_left.play()
		StratagemData.CodeArrow.RIGHT:
			StratagemHeroEffect.instance.audio_press_right.play()

func play_audio_done(direction: StratagemData.CodeArrow) -> void:
	if (SoundManagment.sfx_loaded_press_only_cache):
		play_audio_press(direction)
		return
	StratagemHeroEffect.instance.audio_done.play()

## 音频管理
class SoundManagment:
	const sfx_variants: PackedStringArray = [
		"normal",
		"otto",
		"chen_qian_yu",
	]
	const sfx_variants_press_only: PackedByteArray = [
		false,
		false,
		true,
	]
	## 已加载的音频缓存
	static var sfx_loaded_cache: Dictionary[String, AudioStream] = {}
	## 缓存当前加载的音频变体是否仅播放按下音
	static var sfx_loaded_press_only_cache: bool = false

	## 加载音频变体的press_only并返回
	static func load_press_only(target_variant_name: String) -> bool:
		var index: int = sfx_variants.find(target_variant_name)
		sfx_loaded_press_only_cache = false if index == -1 else (sfx_variants_press_only[index] as bool)
		return sfx_loaded_press_only_cache

	## 加载音频
	static func load_sound(variant_name: String, sound_name: String) -> AudioStream:
		var path: String = "res://resources/sounds".path_join(variant_name).path_join(sound_name) + ".tres"
		if (sfx_loaded_cache.has(path)):
			return sfx_loaded_cache[path]
		if (not ResourceLoader.exists(path)):
			if (variant_name != "normal"):
				return load_sound("normal", sound_name)
			else:
				return null
		var loaded_audio_stream: AudioStream = ResourceLoader.load(path) as AudioStream
		if (loaded_audio_stream == null):
			return null
		sfx_loaded_cache[path] = loaded_audio_stream
		return loaded_audio_stream
