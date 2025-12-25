extends Control
class_name StratagemHeroEffect_ClassicGame
## 经典游戏主类

## 在游戏完全结束(例如需要返回主菜单时)调用该信号，表示接下来画面将不再由经典游戏主类掌控
signal game_end()

## 标题文本，用于显示"准备"和"游戏结束"和"本轮加分"
@onready var n_title_text: Label = $TitleText as Label
## 回合文本，用于显示"回合"和"最高分"和"时间加分"
@onready var n_round_text: Label = $RoundText as Label
## 回合数字文本，用于显示回合数和最高分数
@onready var n_round_number: Label = $RoundNumber as Label
## 分数文本，用于显示"得分"和"你的最终得分"和"完美加分"
@onready var n_score_text: Label = $ScoreText as Label
## 分数数字文本，用于显示分数和结算屏幕上的分数
@onready var n_score_number: Label = $ScoreNumber as Label
## 总分文本，用于在回合分数屏幕上显示"总分"
@onready var n_total_score_text: Label = $TotalScoreText as Label
## 完美加分数字文本，用于在回合分数屏幕上显示完美加分分数
@onready var n_perfect_bonus_number: Label = $PerfectBonusNumber as Label
## 总分数字文本，用于在回合分数屏幕上显示总分分数
@onready var n_total_score_number: Label = $TotalScoreNumber as Label
@onready var n_time_left_bar: ProgressBar = $TimeLeftBar as ProgressBar
@onready var n_back_to_title_tip: Label = $BackToTitleTip as Label
@onready var n_name_color_rect: ColorRect = $NameColorRect as ColorRect
@onready var n_name_text: Label = $NameText as Label
@onready var n_icons: Control = $Icons as Control
@onready var n_icon_nodes: Array[TextureRect] = [
	$Icons/Icon_0 as TextureRect,
	$Icons/Icon_1 as TextureRect,
	$Icons/Icon_2 as TextureRect,
	$Icons/Icon_3 as TextureRect,
	$Icons/Icon_4 as TextureRect,
]
@onready var n_icon_0_panel: Panel = $Icons/Icon_0/Panel as Panel
@onready var n_arrows: HBoxContainer = $Arrows as HBoxContainer

## 回合准备停留时间
const ROUND_READY_STAY_TIME: float = 1.25
## 回合给予时间
const ROUND_TIME: float = 15.0
## 回合分数结算时间
const ROUND_SCORE_STAY_TIME: float = 4.0
## 按错闪红光时红色不满的持续时间
const WRONG_FLASH_NONMAX_TIME: float = 0.6
## 按错闪红光时的总持续时间
const WRONG_FLASH_TOTAL_TIME: float = 0.9
## 游戏状态
enum GameState{
	IDLE, ## 闲置状态，相当于经典游戏主类未开始
	READY, ## 回合准备状态
	INROUND, ## 回合过程中
	ROUND_SCORE, ## 回合完成后结算分数过程中
	GAME_OVER, ## 游戏结束
}

## 战备队列
var stratagem_sequence: Array[StratagemData] = []
## 游戏状态(特指本类的游戏状态)
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
				n_time_left_bar.visible = false
				n_name_color_rect.visible = false
				n_name_text.visible = false
				n_icons.visible = false
				for node in n_arrows.get_children():
					node.queue_free()
				n_arrows.visible = false
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
					n_icons.visible = true
					time_max = ROUND_TIME
					timer = time_max
					stratagem_sequence = create_sequence(clampi(int(rounds / 2.0), 6, 16))
					next_stratagem()
					n_arrows.visible = true
			GameState.ROUND_SCORE:
				StratagemHeroEffect.instance.audio_round_completes[rounds % 4].play()
				StratagemHeroEffect.instance.audio_playing_music.stop()
				n_time_left_bar.visible = false
				n_name_color_rect.visible = false
				n_name_text.visible = false
				n_icons.visible = false
				n_arrows.visible = false
				n_title_text.visible = true
				n_title_text.text = "game_text_round_bonus"
				n_round_text.visible = true
				n_round_text.text = "game_text_time_bonus"
				n_score_text.visible = true
				n_score_text.text = "game_text_perfect_bonus"
				n_total_score_text.visible = true
				n_total_score_text.text = "game_text_total_score"
				n_round_number.text #本轮加分
				n_score_number.text #时间加分
				n_perfect_bonus_number.text #完美加分
				n_total_score_number.text #总分
				n_score_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				n_score_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				_physics_process(0.0)
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
				n_icons.visible = false
				n_arrows.visible = false
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
## 本回合是否有错误
var was_wrong_this_round: bool = false
## 错误闪红光计时器
var wrong_timer: TransferTimer = TransferTimer.new(WRONG_FLASH_TOTAL_TIME, false, 0.0)
## 当前的战备的箭头列表
var current_codes: Array[StratagemData.CodeArrow] = []
## 当前战备的箭头完成数量
var arrow_completed: int = 0

func _ready() -> void:
	game_state = GameState.IDLE

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_released(&"space")):
		if (game_state == GameState.GAME_OVER):
			get_viewport().set_input_as_handled()
			stop_game()
	if (game_state == GameState.INROUND):
		if (pressing_code(event)): #如果按对了
			next_code()
		else: #否则(按错了)
			wrong_pressed()

## 判断并返回该按下的按键是否是当前正确箭头的按键
func pressing_code(event: InputEvent) -> bool:
	if (arrow_completed >= current_codes.size()):
		return true
	var current_code: StratagemData.CodeArrow = current_codes[arrow_completed]
	if (event.is_action_pressed(&"up") and current_code == StratagemData.CodeArrow.UP):
		return true
	if (event.is_action_pressed(&"down") and current_code == StratagemData.CodeArrow.DOWN):
		return true
	if (event.is_action_pressed(&"left") and current_code == StratagemData.CodeArrow.LEFT):
		return true
	if (event.is_action_pressed(&"right") and current_code == StratagemData.CodeArrow.RIGHT):
		return true
	return false

## 使当前的箭头正确，来到下一个箭头或者完成当前战备
func next_code() -> void:
	arrow_completed += 1
	if (arrow_completed >= current_codes.size()):
		next_stratagem()
		StratagemHeroEffect.instance.audio_done.play()
	StratagemHeroEffect.instance.audio_press.play()

## 按错时调用，用于重置当前已经按的数量
func wrong_pressed() -> void:
	arrow_completed = 0
	wrong_timer.current = WRONG_FLASH_TOTAL_TIME
	StratagemHeroEffect.instance.audio_wrong.play()

func _process(delta: float) -> void:
	match (game_state):
		GameState.READY:
			if (timer <= 0.0):
				game_state = GameState.INROUND
		GameState.INROUND:
			n_time_left_bar.value = timer / time_max
			if (timer <= 0.0):
				game_state = GameState.GAME_OVER
			var arrow_nodes: Array[TextureRect] = n_arrows.get_children() as Array[TextureRect]
			for index in arrow_nodes.size():
				arrow_nodes[index].modulate = Color(1.0 - clampf(wrong_timer.current, 0.0, WRONG_FLASH_NONMAX_TIME) / WRONG_FLASH_NONMAX_TIME, 1.0, 0.0 if index < arrow_completed else 1.0)
		GameState.GAME_OVER:
			n_round_text.visible = true if timer <= 4.0 else false
			n_round_number.visible = true if timer <= 3.0 else false
			n_score_text.visible = true if timer <= 2.0 else false
			n_score_number.visible = true if timer <= 1.0 else false
			n_back_to_title_tip.visible = true if timer <= 0.0 else false
	timer -= delta
	wrong_timer.update(delta)

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
	n_back_to_title_tip.size = window.size
	match (game_state):
		GameState.READY:
			n_title_text.position = Vector2(0.0, window.size.y * -0.1)
			n_title_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(128.0))
			n_round_text.position = Vector2(0.0, window.size.y * 0.2)
			n_round_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(48.0))
			n_round_number.position = Vector2(0.0, window.size.y * 0.3)
			n_round_number.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
		GameState.INROUND:
			n_round_text.position = Vector2(window.size.x * -0.45, window.size.y * -0.35)
			n_round_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(32.0))
			n_round_number.position = Vector2(window.size.x * -0.45, window.size.y * -0.25)
			n_round_number.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
			n_score_text.position = Vector2(window.size.x * -0.05, window.size.y * -0.25)
			n_score_text.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(32.0))
			n_score_number.position = Vector2(window.size.x * -0.05, window.size.y * -0.35)
			n_score_number.label_settings.font_size = int(StratagemHeroEffect.instance.get_font_size(64.0))
			n_time_left_bar.position = Vector2(window.size.x * 0.1, window.size.y * 0.8)
			n_name_color_rect.position = Vector2(window.size.x * 0.1, window.size.y * 0.5)
			n_name_text.position = Vector2(n_name_color_rect.position.x, n_name_color_rect.position.y - clampf((n_name_text.size.y - n_name_color_rect.size.y) / 2.0, 0.0, INF))
			var large_icon_width: float = StratagemHeroEffect.instance.get_font_size(288.0)
			var small_icon_width: float = StratagemHeroEffect.instance.get_font_size(180.0)
			for i in n_icon_nodes.size():
				if (i == 0):
					n_icon_nodes[i].size = Vector2.ONE * large_icon_width
					n_icon_nodes[i].position = n_name_color_rect.position - Vector2(0.0, n_icon_nodes[i].size.y)
					continue
				n_icon_nodes[i].size = Vector2.ONE * small_icon_width
				n_icon_nodes[i].position = n_name_color_rect.position + Vector2(large_icon_width + (i - 1) * small_icon_width, -n_icon_nodes[i].size.y)
			n_icon_0_panel.size = n_icon_nodes[0].size
			n_arrows.size = Vector2(window.size.x, window.size.y * 0.175)
			n_arrows.position = Vector2(0.0, window.size.y * 0.6)
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
	n_icons.visible = false

## 将界面切换至下一个战备，或者本回合完成
func next_stratagem() -> void:
	var next_stratagem_data: StratagemData = stratagem_sequence.pop_front()
	for node in n_arrows.get_children():
		node.queue_free()
	for arrow in next_stratagem_data.codes:
		n_arrows.add_child(create_arrow(arrow))
	n_icon_nodes[0].texture = next_stratagem_data.icon
	for i in 4: # [0,1,2,3]
		var index: int = i + 1
		if (index >= n_icon_nodes.size()):
			n_icon_nodes[index].texture = null
			continue
		n_icon_nodes[index].texture = stratagem_sequence[i].icon
	n_name_text.text = next_stratagem_data.name_key
	current_codes = next_stratagem_data.codes

func stop_game() -> void:
	game_state = GameState.IDLE
	visible = false
	StratagemHeroEffect.instance.audio_game_over.stop()
	StratagemHeroEffect.instance.audio_game_over_large.stop()
	emit_signal(&"game_end")

## 创建一个箭头TextureRect节点，用于作为$Arrows的子节点
static func create_arrow(direct: StratagemData.CodeArrow) -> TextureRect:
	var arrow_node: TextureRect = TextureRect.new()
	arrow_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	arrow_node.stretch_mode = TextureRect.STRETCH_SCALE
	match (direct):
		StratagemData.CodeArrow.UP:
			arrow_node.texture = preload("res://resources/images/arrow_v.svg")
		StratagemData.CodeArrow.DOWN:
			arrow_node.texture = preload("res://resources/images/arrow_v.svg")
			arrow_node.flip_v = true
		StratagemData.CodeArrow.LEFT:
			arrow_node.texture = preload("res://resources/images/arrow_h.svg")
		StratagemData.CodeArrow.RIGHT:
			arrow_node.texture = preload("res://resources/images/arrow_h.svg")
			arrow_node.flip_h = true
	return arrow_node

## 创建战备序列
static func create_sequence(count: int) -> Array[StratagemData]:
	var result: Array[StratagemData] = []
	var values: Array[StratagemData] = StratagemHeroEffect.StratagemDataList.values() as Array[StratagemData]
	while (count > 0):
		count -= 1
		result.append(values[randi_range(0, values.size() - 1)])
	return result
