extends Control
class_name StratagemHeroEffect_ClassicGame
## 经典游戏主类

## 在游戏完全结束(例如需要返回主菜单时)调用该信号，表示接下来画面将不再由经典游戏主类掌控
signal game_end()

## 标题文本，用于显示"准备"和"游戏结束"
@onready var n_title_text: Label = $TitleText as Label
## 回合文本，用于显示"回合"和"最高分"
@onready var n_round_text: Label = $RoundText as Label
## 回合数字文本，用于显示回合数和最高分数
@onready var n_round_number: Label = $RoundNumber as Label
## 分数文本，用于显示"得分"和"你的最终得分"
@onready var n_score_text: Label = $ScoreText as Label
## 分数数字文本，用于显示分数和结算屏幕上的分数
@onready var n_score_number: Label = $ScoreNumber as Label
@onready var n_time_left_bar: ProgressBar = $TimeLeftBar as ProgressBar
@onready var n_back_to_title_tip: Label = $BackToTitleTip as Label
@onready var n_name_color_rect: ColorRect = $NameColorRect as ColorRect
@onready var n_name_text: Label = $NameText as Label

## 回合准备停留时间
const ROUND_READY_STAY_TIME: float = 1.25
## 回合给予时间
const ROUND_TIME: float = 15.0
## 回合分数结算时间
const ROUND_SCORE_STAY_TIME: float = 4.0
## 游戏状态
enum GameState{
	IDLE, ## 闲置状态，相当于经典游戏主类未开始
	READY, ## 回合准备状态
	INROUND, ## 回合过程中
	ROUND_SCORE, ## 回合完成后结算分数过程中
	GAME_OVER, ## 游戏结束
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
			GameState.READY:
				if (from_state == GameState.IDLE):
					StratagemHeroEffect.instance.audio_start.play()
					rounds = 1
					score = 0
					_physics_process(0.0)
				if (from_state == GameState.ROUND_SCORE):
					StratagemHeroEffect.instance.audio_ready.play()
				timer = ROUND_READY_STAY_TIME
				n_round_number.text = str(rounds)
				n_title_text.text = "game_text_ready"
				n_round_text.text = "game_text_round"
				n_score_text.text = "game_text_score"
				n_score_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				n_score_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			GameState.INROUND:
				if (from_state == GameState.READY):
					StratagemHeroEffect.instance.audio_playing_music.play()
					_physics_process(0.0)
					n_title_text.visible = false
					n_score_text.visible = true
					n_score_number.visible = true
					n_time_left_bar.visible = true
					n_name_color_rect.visible = true
					n_name_text.visible = true
					time_max = ROUND_TIME
					timer = time_max
			GameState.GAME_OVER:
				if (rounds > 1):
					StratagemHeroEffect.instance.audio_game_over_large.play()
					timer = 5.0
				else:
					StratagemHeroEffect.instance.audio_game_over.play()
					timer = 1.0
				StratagemHeroEffect.instance.audio_playing_music.stop()
				n_time_left_bar.visible = false
				n_name_color_rect.visible = false
				n_name_text.visible = false
				n_title_text.visible = true
				n_title_text.text = "game_text_game_over"
				n_round_text.visible = true
				n_round_text.text = "game_text_high_score"
				n_score_text.visible = true
				n_score_text.text = "game_text_your_final_score"
				n_score_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				n_score_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				_physics_process(0.0)
## 回合计数
var rounds: int = 0
## 分数
var score: int = 0
## 计时器
var timer: float = 0.0
## 计时器上限
var time_max: float = 0.0

func _ready() -> void:
	game_state = GameState.IDLE

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_released(&"space")):
		if (game_state == GameState.GAME_OVER):
			get_viewport().set_input_as_handled()
			stop_game()

func _process(delta: float) -> void:
	match (game_state):
		GameState.READY:
			if (timer <= 0.0):
				game_state = GameState.INROUND
		GameState.INROUND:
			n_time_left_bar.value = timer / time_max
			if (timer <= 0.0):
				game_state = GameState.GAME_OVER
		GameState.GAME_OVER:
			n_round_text.visible = true if timer <= 4.0 else false
			n_round_number.visible = true if timer <= 3.0 else false
			n_score_text.visible = true if timer <= 2.0 else false
			n_score_number.visible = true if timer <= 1.0 else false
			n_back_to_title_tip.visible = true if timer <= 0.0 else false
	timer -= delta

func _physics_process(_delta: float) -> void:
	var window: Window = get_window()
	n_title_text.size = Vector2(window.size)
	n_round_text.size = Vector2(window.size)
	n_round_number.size = Vector2(window.size)
	n_score_text.size = Vector2(window.size)
	n_score_number.size = Vector2(window.size)
	n_time_left_bar.size = Vector2(window.size.x * 0.8, window.size.y * 0.04)
	n_name_color_rect.size = Vector2(window.size.x * 0.8, window.size.y * 0.075)
	n_name_text.size = Vector2(n_name_color_rect.size.x, 0.0)
	match (game_state):
		GameState.READY:
			n_title_text.position = Vector2(0.0, window.size.y * -0.1)
			n_title_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(128.0))
			n_round_text.position = Vector2(0.0, window.size.y * 0.2)
			n_round_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(48.0))
			n_round_number.position = Vector2(0.0, window.size.y * 0.3)
			n_round_number.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
		GameState.INROUND:
			n_round_text.position = Vector2(window.size.x * -0.4, window.size.y * -0.35)
			n_round_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(32.0))
			n_round_number.position = Vector2(window.size.x * -0.4, window.size.y * -0.25)
			n_round_number.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
			n_score_text.position = Vector2(window.size.x * -0.05, window.size.y * -0.25)
			n_score_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(32.0))
			n_score_number.position = Vector2(window.size.x * -0.05, window.size.y * -0.35)
			n_score_number.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
			n_time_left_bar.position = Vector2(window.size.x * 0.1, window.size.y * 0.8)
			n_name_color_rect.position = Vector2(window.size.x * 0.1, window.size.y * 0.5)
			n_name_text.position = Vector2(n_name_color_rect.position.x, n_name_color_rect.position.y - clampf((n_name_text.size.y - n_name_color_rect.size.y) / 2.0, 0.0, INF))
		GameState.GAME_OVER:
			n_title_text.position = Vector2(0.0, window.size.y * -0.2)
			n_title_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(128.0))
			n_round_text.position = Vector2(0.0, window.size.y * -0.05)
			n_round_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
			n_round_number.position = Vector2(0.0, window.size.y * 0.05)
			n_round_number.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
			n_score_text.position = Vector2(0.0, window.size.y * 0.15)
			n_score_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
			n_score_number.position = Vector2(0.0, window.size.y * 0.25)
			n_score_number.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))

func start_game() -> void:
	if (game_state != GameState.IDLE):
		push_error("Cannot start classic game when it is already running.")
		return
	game_state = GameState.READY
	visible = true
	n_score_text.visible = false
	n_score_number.visible = false
	n_time_left_bar.visible = false
	n_back_to_title_tip.visible = false
	n_name_color_rect.visible = false
	n_name_text.visible = false

func stop_game() -> void:
	game_state = GameState.IDLE
	visible = false
	StratagemHeroEffect.instance.audio_game_over.stop()
	StratagemHeroEffect.instance.audio_game_over_large.stop()
	emit_signal(&"game_end")
