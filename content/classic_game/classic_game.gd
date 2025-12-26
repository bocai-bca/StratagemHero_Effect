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
## 回合给予时间基础值，实际情况会因为回合数增加而对数减少
const ROUND_TIME: float = 15.0
## 回合分数结算时间
const ROUND_SCORE_STAY_TIME: float = 3.5
## 按错闪红光时红色不满的持续时间
const WRONG_FLASH_NONMAX_TIME: float = 0.3
## 按错闪红光时的总持续时间
const WRONG_FLASH_TOTAL_TIME: float = 0.4
## 完成一个战备的回复时间
const TIME_REVIVE_AFTER_A_COMPLETE: float = 2.5
## 时间条开始呈现橙色警告的百分比位置
const TIME_BAR_WARNING_PERCENT: float = 0.4
## 按错罚时
const WRONG_TIME_PENALTY: float = 0.75
## 游戏状态
enum GameState{
	IDLE, ## 闲置状态，相当于经典游戏主类未开始
	READY, ## 回合准备状态
	INROUND, ## 回合过程中
	ROUND_SCORE, ## 回合完成后结算分数过程中
	GAME_OVER, ## 游戏结束
}
## 不常见战备列表，首次抽到以下战备时，会进行一次重抽，以降低一下战备出现的可能性，变相提高其他战备出现的可能性
const IMCOMMON_STRATAGEMS: Array[StringName] = [
	&"sterilizer",
	&"guard_dog_breath",
	&"directional_shield",
	&"anti_tank_emplacement",
	&"flame_sentry",
	&"hellbomb_portable",
	&"hover_pack",
	&"one_true_flag",
	&"gl_52_de_escalator",
	&"guard_dog_k_9",
	&"epoch",
	&"laser_sentry",
	&"warp_pack",
	&"speargun",
	&"expendable_napalm",
	&"solo_silo",
	&"maxigun",
	&"defoliation_tool",
	&"guard_dog_hot_dog",
	&"sos_beacon",
	&"dark_fluid_vessel",
	&"tectonic_drill",
	&"hive_breaker_drill",
	&"cargo_container"
]

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
				set_process(false)
				set_physics_process(false)
			GameState.READY:
				if (from_state == GameState.IDLE):
					StratagemHeroEffect.instance.audio_start.play()
					rounds = 1
					score = 0
					n_score_number.visible = false
					n_score_text.visible = false
					n_perfect_bonus_number.visible = false
					n_total_score_text.visible = false
					n_total_score_number.visible = false
					was_wrong_this_round = false
					codes_count_this_round = 0
					_physics_process(0.0)
				if (from_state == GameState.ROUND_SCORE):
					StratagemHeroEffect.instance.audio_ready.play()
					rounds += 1
					was_wrong_this_round = false
					codes_count_this_round = 0
					n_title_text.visible = true
					n_title_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					n_round_number.visible = true
					n_round_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					n_round_text.visible = true
					n_round_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					n_score_number.visible = false
					n_score_text.visible = false
					n_perfect_bonus_number.visible = false
					n_total_score_text.visible = false
					n_total_score_number.visible = false
					_physics_process(0.0)
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
					time_max = get_round_time(rounds)
					print("this round time = ", time_max)
					timer = time_max
					stratagem_sequence = create_sequence(clampi(int((rounds + 4) / 1.3), 3, 30))
					next_stratagem()
					n_arrows.visible = true
					n_score_number.text = str(score)
			GameState.ROUND_SCORE:
				StratagemHeroEffect.instance.audio_round_completes[(rounds - 1) % 4].play()
				StratagemHeroEffect.instance.audio_playing_music.stop()
				n_time_left_bar.visible = false
				n_name_color_rect.visible = false
				n_name_text.visible = false
				n_icons.visible = false
				n_arrows.visible = false
				n_title_text.text = "game_text_round_bonus"
				n_round_text.text = "game_text_time_bonus"
				n_score_text.text = "game_text_perfect_bonus"
				n_total_score_text.text = "game_text_total_score"
				var round_bonus: int = codes_count_this_round * 5
				score += round_bonus
				n_round_number.text = str(round_bonus) #本轮加分
				var time_bonus: int = int(timer / time_max * 100.0)
				score += time_bonus
				n_score_number.text = str(time_bonus) #时间加分
				n_perfect_bonus_number.text = "0" if was_wrong_this_round else "100" #完美加分
				score += 0 if was_wrong_this_round else 100
				n_total_score_number.text = str(score) #总分
				n_score_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				n_score_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				time_max = ROUND_SCORE_STAY_TIME
				timer = time_max
				_physics_process(0.0)
			GameState.GAME_OVER:
				if (rounds > 1):
					StratagemHeroEffect.instance.audio_game_over_large.play()
					timer = 3.0
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
				n_round_text.text = "game_text_rounds_reached"
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
## 回合内所有指令数量(用于在回合结算时转换成回合加分，在回合结算之前该值不正确，仍然处于累积过程中)
var codes_count_this_round: int = 0

func _ready() -> void:
	game_state = GameState.IDLE

## 手动输入处理方法，需要被process调用
func input_handle() -> void:
	match (game_state):
		GameState.GAME_OVER:
			if (Input.is_action_just_released(&"space")):
				stop_game()
		GameState.INROUND:
			if (arrow_completed >= current_codes.size()):
				next_code()
				return
			var current_code: StratagemData.CodeArrow = current_codes[arrow_completed]
			if (Input.is_action_just_pressed(&"up")):
				if (current_code == StratagemData.CodeArrow.UP): next_code()
				else: wrong_pressed()
			if (Input.is_action_just_pressed(&"down")):
				if (current_code == StratagemData.CodeArrow.DOWN): next_code()
				else: wrong_pressed()
			if (Input.is_action_just_pressed(&"left")):
				if (current_code == StratagemData.CodeArrow.LEFT): next_code()
				else: wrong_pressed()
			if (Input.is_action_just_pressed(&"right")):
				if (current_code == StratagemData.CodeArrow.RIGHT): next_code()
				else: wrong_pressed()

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
	was_wrong_this_round = true
	timer -= WRONG_TIME_PENALTY
	wrong_timer.current = WRONG_FLASH_TOTAL_TIME
	StratagemHeroEffect.instance.audio_wrong.play()

func _process(delta: float) -> void:
	match (game_state):
		GameState.READY:
			if (timer <= 0.0):
				game_state = GameState.INROUND
		GameState.INROUND:
			n_time_left_bar.value = timer / time_max
			var time_bar_fill_stylebox: StyleBoxFlat = n_time_left_bar.theme.get_stylebox(&"fill", &"ProgressBar") as StyleBoxFlat
			time_bar_fill_stylebox.bg_color = Color(1.0, 0.3, 0.0) if n_time_left_bar.value <= TIME_BAR_WARNING_PERCENT else Color.YELLOW
			n_time_left_bar.theme.set_stylebox(&"fill", &"ProgressBar", time_bar_fill_stylebox)
			if (timer <= 0.0):
				game_state = GameState.GAME_OVER
			var arrow_nodes: Array[Node] = n_arrows.get_children() as Array[Node]
			for index in arrow_nodes.size():
				var this_arrow_node: TextureRect = arrow_nodes[index] as TextureRect
				var yellow_blue_decrease: float = clampf(wrong_timer.current, 0.0, WRONG_FLASH_NONMAX_TIME) / WRONG_FLASH_NONMAX_TIME
				this_arrow_node.modulate = Color(1.0, 1.0 - yellow_blue_decrease, 0.0 if index < arrow_completed else 1.0 - yellow_blue_decrease)
		GameState.ROUND_SCORE:
			n_title_text.visible = true if timer <= 3.5 else false #文本"本轮加分"
			n_round_number.visible = true if timer <= 3.5 else false #分数-本轮加分
			n_round_text.visible = true if timer <= 2.8 else false #文本"时间加分"
			n_score_number.visible = true if timer <= 2.8 else false #分数-时间加分
			n_score_text.visible = true if timer <= 2.1 else false #文本"完美加分"
			n_perfect_bonus_number.visible = true if timer <= 2.1 else false #分数-完美加分
			n_total_score_text.visible = true if timer <= 1.4 else false #文本"总分"
			n_total_score_number.visible = true if timer <= 1.4 else false #分数-总分
			if (timer <= 0.0):
				game_state = GameState.READY
		GameState.GAME_OVER:
			n_round_text.visible = true if timer <= 2.2 else false
			n_round_number.visible = true if timer <= 2.2 else false
			n_score_text.visible = true if timer <= 1.5 else false
			n_score_number.visible = true if timer <= 1.5 else false
			n_back_to_title_tip.visible = true if timer <= 0.0 else false
	timer -= delta
	wrong_timer.update(delta)
	input_handle()

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
		GameState.ROUND_SCORE:
			var font_size: int = int(StratagemHeroEffect.instance.get_font_size(48.0))
			var label_size: Vector2 = Vector2(window.size.x * 0.75, window.size.y)
			var position_x: float = window.size.x * 0.125
			n_title_text.label_settings.font_size = font_size
			n_title_text.size = label_size
			n_title_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			n_title_text.position = Vector2(position_x, window.size.y * -0.3)
			n_round_number.label_settings.font_size = font_size
			n_round_number.size = label_size
			n_round_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			n_round_number.position = Vector2(position_x, window.size.y * -0.3)
			n_round_text.label_settings.font_size = font_size
			n_round_text.size = label_size
			n_round_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			n_round_text.position = Vector2(position_x, window.size.y * -0.1)
			n_score_number.label_settings.font_size = font_size
			n_score_number.size = label_size
			n_score_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			n_score_number.position = Vector2(position_x, window.size.y * -0.1)
			n_score_text.label_settings.font_size = font_size
			n_score_text.size = label_size
			n_score_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			n_score_text.position = Vector2(position_x, window.size.y * 0.1)
			n_perfect_bonus_number.label_settings.font_size = font_size
			n_perfect_bonus_number.size = label_size
			n_perfect_bonus_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			n_perfect_bonus_number.position = Vector2(position_x, window.size.y * 0.1)
			n_total_score_text.label_settings.font_size = font_size
			n_total_score_text.size = label_size
			n_total_score_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			n_total_score_text.position = Vector2(position_x, window.size.y * 0.3)
			n_total_score_number.label_settings.font_size = font_size
			n_total_score_number.size = label_size
			n_total_score_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			n_total_score_number.position = Vector2(position_x, window.size.y * 0.3)
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
	set_process(true)
	set_physics_process(true)
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
	score += current_codes.size() * 5
	n_score_number.text = str(score)
	var next_stratagem_data: StratagemData = stratagem_sequence.pop_front()
	if (next_stratagem_data == null):
		timer += TIME_REVIVE_AFTER_A_COMPLETE
		game_state = GameState.ROUND_SCORE
		return
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
		if (i >= stratagem_sequence.size()):
			n_icon_nodes[index].texture = null
			continue
		n_icon_nodes[index].texture = stratagem_sequence[i].icon
	n_name_text.text = next_stratagem_data.name_key
	current_codes = next_stratagem_data.codes
	codes_count_this_round += current_codes.size()
	arrow_completed = 0
	timer = move_toward(timer, time_max, get_round_revive(rounds))

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
	var keys: Array[StringName] = StratagemHeroEffect.StratagemDataList.keys() as Array[StringName]
	while (count > 0):
		count -= 1
		var key: StringName = keys[randi_range(0, keys.size() - 1)]
		if (IMCOMMON_STRATAGEMS.has(key)):
			key = keys[randi_range(0, keys.size() - 1)]
		result.append(StratagemHeroEffect.StratagemDataList[key])
	return result

## 获取给定回合的回合时间
static func get_round_time(round_num: int) -> float:
	return ROUND_TIME / clampf(round_num ** 0.3, 0.01, INF)

## 获取给定回合下完成一个战备的回复时间
static func get_round_revive(round_num: int) -> float:
	return TIME_REVIVE_AFTER_A_COMPLETE / clampf(round_num ** 0.5, 0.01, INF)
