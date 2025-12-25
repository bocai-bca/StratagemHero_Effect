extends CanvasItem
class_name StratagemHeroEffect
## 主类

static var instance: StratagemHeroEffect

@onready var audio_title_music: AudioStreamPlayer = $Audio_TitleMusic as AudioStreamPlayer
@onready var audio_ready: AudioStreamPlayer = $Audio_Ready as AudioStreamPlayer
@onready var audio_menu_click: AudioStreamPlayer = $Audio_MenuClick as AudioStreamPlayer
@onready var audio_press: AudioStreamPlayer = $Audio_Press as AudioStreamPlayer
@onready var audio_start: AudioStreamPlayer = $Audio_Start as AudioStreamPlayer
@onready var audio_playing_music: AudioStreamPlayer = $Audio_PlayingMusic as AudioStreamPlayer
@onready var audio_game_over: AudioStreamPlayer = $Audio_GameOver as AudioStreamPlayer
@onready var audio_game_over_large: AudioStreamPlayer = $Audio_GameOverLarge as AudioStreamPlayer

@onready var n_super_earth_background: TextureRect = $SuperEarthBackground as TextureRect
@onready var n_title: Label = $Title as Label
@onready var n_title_tip_text: Label = $TitleTipText as Label
@onready var n_title_line_top: ColorRect = $TitleLineTop as ColorRect
@onready var n_title_line_bottom: ColorRect = $TitleLineBottom as ColorRect
@onready var n_main_menu_text: MainMenu_Text = $MainMenu_Text as MainMenu_Text

@onready var classic_game: StratagemHeroEffect_ClassicGame = $ClassicGame as StratagemHeroEffect_ClassicGame

## 游戏状态
enum GameState{
	Init, ## 初始化
	Title, ## 标题界面
	MainMenu, ## 主菜单
	Settings, ## 设置菜单
	Classic, ## 经典游戏
}
## 支持的语言
const LanguagesSupported: PackedStringArray = [
	"en",
	"zh",
]
## 战备数据列表
static var StratagemDataList: Dictionary[StringName, StratagemData] = {
	&"airburst_rocket_launcher":
		StratagemData.new(
			preload("res://resources/images/airburst_rocket_launcher.svg"),
			"stratagem_name.airburst_rocket_launcher",
			"v^^<>"
		),
	&"anti_materiel_rifle":
		StratagemData.new(
			preload("res://resources/images/anti_materiel_rifle.svg"),
			"stratagem_name.anti_materiel_rifle",
			"v<>^v"
		),
	&"anti_personnel_minefield":
		StratagemData.new(
			preload("res://resources/images/anti_personnel_minefield.svg"),
			"stratagem_name.anti_personnel_minefield",
			"v<^>"
		),
	&"eagle_500kg_bomb":
		StratagemData.new(
			preload("res://resources/images/eagle_500kg_bomb.svg"),
			"stratagem_name.eagle_500kg_bomb",
			"^>vvv"
		)
}

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
				if (from_game_state == GameState.Title):
					audio_ready.play()
					menu_option_focus = 0
					transfer_timers[0].current = 0.0
					n_main_menu_text.update_text()
				if (from_game_state == GameState.Settings):
					audio_menu_click.play()
					menu_option_focus = 2
					n_main_menu_text.update_text()
				if (from_game_state == GameState.Classic):
					n_title.visible = true
					n_title_tip_text.visible = true
					n_title_line_top.visible = true
					n_title_line_bottom.visible = true
					n_main_menu_text.visible = true
					audio_title_music.play()
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

## 菜单焦点
static var menu_option_focus: int
## 全局变换计数器列表
##  0 = 游戏状态变换计数器，用于：在标题按下空格后变换到主菜单的过程计时
static var transfer_timers: Array[TransferTimer] = [
	TransferTimer.new(0.2, true, 0.2),
]

func _init() -> void:
	instance = self

func _enter_tree() -> void:
	get_window().min_size = Vector2i(640, 360)

func _ready() -> void:
	classic_game.game_end.connect(on_game_end)
	game_state = GameState.Title

func _unhandled_input(event: InputEvent) -> void:
	match (game_state):
		GameState.Title:
			if (event.is_action_released(&"space")):
				game_state = GameState.MainMenu
		GameState.MainMenu:
			if (event.is_action_released(&"up")):
				menu_option_focus -= 1
				if (menu_option_focus < 0):
					menu_option_focus = 4
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"down")):
				menu_option_focus += 1
				if (menu_option_focus > 4):
					menu_option_focus = 0
				n_main_menu_text.update_text()
				audio_press.play()
			if (event.is_action_released(&"space")):
				menu_click()
		GameState.Settings:
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

## 代表按下当前菜单的键，旨在实现高度封装
func menu_click() -> void:
	match (game_state):
		GameState.MainMenu:
			match (menu_option_focus):
				0: #经典
					game_state = GameState.Classic
					classic_game.start_game()
				2: #设置
					game_state = GameState.Settings
		GameState.Settings:
			match (menu_option_focus):
				0: #返回
					game_state = GameState.MainMenu
				1: #更改语言
					change_language()
					n_main_menu_text.update_text()
					audio_press.play()

func _process(delta: float) -> void:
	for transfer_timer in transfer_timers:
		transfer_timer.update(delta)

## 获取当前分辨率下合适的字体大小，需要给定在1280*720尺寸下的原始大小，不建议高频调用本方法
func get_font_size(original_size: float) -> float:
	var window: Window = get_window()
	return (original_size / 720.0) * window.size.y
	#var new_size_by_x: float = (original_size / 1280.0) * window.size.x
	#var new_size_by_y: float = (original_size / 720.0) * window.size.y
	#return minf(new_size_by_x, new_size_by_y)

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
