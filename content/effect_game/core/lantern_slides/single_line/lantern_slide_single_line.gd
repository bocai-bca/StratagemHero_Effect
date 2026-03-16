extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine
## 效果模式单行式幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/single_line/lantern_slide_single_line.tscn") as PackedScene

var label_settings_common: LabelSettings = preload("res://content/effect_game/core/lantern_slides/single_line/label_settings_common.tres") as LabelSettings

var n_super_earth_logo: TextureRect
var n_time_left_bar: StratagemHeroEffect_EffectGameCore_TimeLeftBar
var n_round_text: Label
var n_round_num: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
var n_score_text: Label
var n_score_num: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
var n_lines: Array[StratagemHeroEffect_EffectGameCore_StratagemLine] = []
var n_lines_fadeouting: Array[StratagemHeroEffect_EffectGameCore_StratagemLine] = []
var n_round_finish_text: Label

## 基本计时器最大值
const BASIC_TIMER_MAX: float = 8.0
## 基本计时器回复值
const BASIC_TIME_REVIVE: float = 4.0
## 基本计时器扣除值
const BASIC_TIME_DECREASE: float = 0.3
## 行阵列的X坐标起始位置比率，基于本节点的横向尺寸
const LINES_POSITION_X_START_RATE: float = 0.2
## 行阵列的Y坐标起始位置比率，基于本节点的纵向尺寸
const LINES_POSITION_Y_START_RATE: float = 0.28
## 行阵列的垂直间隔距离比率，基于行的StratagemHeroEffect.instance.get_fit_size(ICON_BASIC_SCALE)
const LINES_SPACING_RATE: float = 0.5
## 抛下焦点计时器(回合结束后开始计时)
const FOCUS_DROP_TIME: float = 3.5
## 回合结束文本显现过程时间
const ROUND_FINISH_TEXT_DISPLAYING_TIME: float = 1.5
## 连错保护时间
const WRONG_PROTECT_TIME: float = 0.6

## 默写模式的计时器乘数，影响回合总时间和回复时间
const DICTATION_TIMER_MULTIPLIER: float = 6.0
## 默写模式的惩罚时间乘数，影响按错时扣除的时间
const DICTATION_TIMER_DECREASE_MULTIPLIER: float = 5.0

## 回合计数
var current_round: int = 1:
	get:
		return current_round
	set(value):
		current_round = value
		time_revive_this_round = get_time_revive_for_round(value)
## 分数计数
var current_score: int = 0:
	get:
		return current_score
	set(value):
		current_score = value
		if (n_score_num != null):
			n_score_num.set_new_text_large(str(value))
## 计时器
var timer: float
## 计时器最大值
var timer_max: float
## 箭头完成数(实际上必须完成整个指令才会记录该指令中的所有箭头)，其数值将跨回合传递，用于计算平均速度
var arrow_completed: int = 0
## 本回合的箭头完成数，用于计算完美奖励
var arrow_completed_this_round: int = 0
## 本回合内是否完美，用于计算完美奖励
var is_perfect: bool = true
## 总计时器，其数值将跨回合传递，用于计算平均速度
var total_timer: float = 0.0
## 缓存当前回合的时间回复值
var time_revive_this_round: float = BASIC_TIME_REVIVE
## 是否即将抛下焦点
var is_going_to_drop_focus: bool = false
## 抛下焦点计时器
var focus_drop_timer: TransferTimer = TransferTimer.new(FOCUS_DROP_TIME, true, 0.0)
## 回合结束文本显现计时器
var round_finish_displaying_timer: TransferTimer = TransferTimer.new(ROUND_FINISH_TEXT_DISPLAYING_TIME, true, 0.0)
## 连错保护计时器
var wrong_protect_timer: TransferTimer = TransferTimer.new(WRONG_PROTECT_TIME, false, 0.0)

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_time_left_bar = $TimeLeftBar as StratagemHeroEffect_EffectGameCore_TimeLeftBar
		n_round_text = $RoundText as Label
		n_round_num = $RoundNum as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
		n_score_text = $ScoreText as Label
		n_score_num = $ScoreNum as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
		n_round_finish_text = $RoundFinishText as Label

func _ready() -> void:
	n_round_num.text = str(current_round)

func _on_esc_exit() -> void:
	to_game_over()
	focus_drop_timer.complete()

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_time_left_bar.fit_size(window_size)
	n_round_text.position = Vector2(size.x * -0.4, size.y * -0.4)
	n_round_text.size = window_size
	n_score_text.position = Vector2(size.x * 0.4, size.y * -0.4)
	n_score_text.size = window_size
	n_round_num.position = Vector2(size.x * -0.4, size.y * -0.3)
	n_round_num.size = window_size
	n_round_num._fit_size(window_size)
	n_score_num.position = Vector2(size.x * 0.4, size.y * -0.3)
	n_score_num.size = window_size
	n_score_num._fit_size(window_size)
	for n_line in n_lines:
		n_line.fit_size(window_size)
	update_logo(n_super_earth_logo, window_size)
	n_round_finish_text.position = Vector2(0.0, size.y * 0.2)
	n_round_finish_text.size = window_size
	label_settings_common.font_size = int(StratagemHeroEffect.instance.get_fit_size(48.0))
	#StratagemHeroEffect_EffectGameCore_StratagemLine.static_fit_size(window_size)

func _update_focus(delta: float) -> void:
	if (not is_going_to_drop_focus):
		timer -= delta
		total_timer += delta
		if (timer <= 0.0):
			to_game_over()
			return
	n_time_left_bar.update(delta, timer / timer_max)
	for i in n_lines.size():
		var n_line: StratagemHeroEffect_EffectGameCore_StratagemLine = n_lines[i]
		n_line.update(delta)
	for i in n_lines_fadeouting.size():
		var n_line: StratagemHeroEffect_EffectGameCore_StratagemLine = n_lines_fadeouting[i]
		n_line.update(delta)
	if (n_lines.size() > 0):
		if (n_lines[0].was_done):
			next_line()
		else:
			n_lines[0].update_check_input()
	while (n_lines_fadeouting.size() > 0 and n_lines_fadeouting[0].death_timer.percent == 0.0):
		(n_lines_fadeouting.pop_front() as StratagemHeroEffect_EffectGameCore_StratagemLine).queue_free()
	if (is_going_to_drop_focus):
		focus_drop_timer.update(delta)
		if (focus_drop_timer.percent >= 1.0):
			drop_focus()
	round_finish_displaying_timer.update(delta)
	n_round_finish_text.visible_ratio = round_finish_displaying_timer.percent
	update_lines_position()
	wrong_protect_timer.update(delta)

func update_lines_position() -> void:
	var lines_list: Array[StratagemHeroEffect_EffectGameCore_StratagemLine] = n_lines_fadeouting + n_lines
	var x_pos: float = size.x * LINES_POSITION_X_START_RATE
	var height_used: float = size.y * LINES_POSITION_Y_START_RATE
	var line_icon_true_height: float = StratagemHeroEffect.instance.get_fit_size(StratagemHeroEffect_EffectGameCore_StratagemLine.ICON_BASIC_SCALE) * (1.0 + LINES_SPACING_RATE)
	for i in lines_list.size():
		var n_line: StratagemHeroEffect_EffectGameCore_StratagemLine = lines_list[i]
		var this_height: float = n_line.death_timer.percent * line_icon_true_height
		n_line.position = Vector2(x_pos, height_used + this_height * 0.5)
		height_used += this_height

## 移动下一个幻灯片行
func next_line() -> void:
	if (n_lines.is_empty()):
		#这一段正常情况下不会被运行，是特殊情况的容错机制，防止n_lines为空但是尝试弹出值。基本上可以当不存在
		to_next_round()
		return
	var the_one_moving: StratagemHeroEffect_EffectGameCore_StratagemLine = n_lines.pop_front() as StratagemHeroEffect_EffectGameCore_StratagemLine
	the_one_moving.death = true
	var code_num: int = the_one_moving.stratagem_data.codes.size()
	arrow_completed += code_num
	arrow_completed_this_round += code_num
	current_score += code_num
	timer = move_toward(timer, timer_max, time_revive_this_round if StratagemHeroEffect_EffectGame.special_effect_mode != StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION else time_revive_this_round * DICTATION_TIMER_MULTIPLIER)
	n_time_left_bar.play_revive_effect()
	n_lines_fadeouting.append(the_one_moving)
	if (n_lines.is_empty()):
		to_next_round()
		return
	n_lines[0].lighting = true

## 触发到游戏结束
func to_game_over() -> void:
	n_round_finish_text.text = tr(&"effect_text.lantern_slide.single_line.game_over")
	round_finish_displaying_timer.restart()
	var game_core: StratagemHeroEffect_EffectGameCore = StratagemHeroEffect_EffectGame.instance.n_game_core
	var new_game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver
	new_game_over_lantern_slide.update_text("--" if StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.NONE else StratagemHeroEffect_EffectGame.get_special_mode_name_translated(), current_score, current_round, arrow_completed * 60.0 / total_timer)
	game_core.add_lantern_slide(new_game_over_lantern_slide)
	for n_line in n_lines:
		n_line.death = true
	if (current_round > 5):
		StratagemHeroEffect.instance.audio_game_over_large.play()
	else:
		StratagemHeroEffect.instance.audio_game_over.play()
	start_is_going_to_drop_focus()
	if (StratagemHeroEffect_EffectGame_StratagemSelectionPanel.stratagems_enabled.size() >= StratagemHeroEffect_EffectGame.MINIMUM_STRATAGEMS_ENABLED_ABLE_TO_RECORD_HIGH_SCORE):
		StratagemHeroEffect_SaveAccess.check_and_save_effect_score(StratagemHeroEffect_EffectGame.instance.special_effect_mode, current_score, current_round, arrow_completed * 60.0 / total_timer)

## 触发到下一回合
func to_next_round() -> void:
	n_time_left_bar.update(0.0, timer / timer_max)
	var time_bonus: int = int(timer / timer_max * 10.0)
	var perfect_bonus: int = arrow_completed_this_round if is_perfect else 0
	current_score += time_bonus + perfect_bonus
	n_round_finish_text.text = \
		tr(&"effect_text.lantern_slide.single_line.round_completed") \
		+ "\n" + \
		tr(&"effect_text.lantern_slide.single_line.time_bonus") + str(time_bonus) \
		+ "\n" + \
		tr(&"effect_text.lantern_slide.single_line.perfect_bonus") + str(perfect_bonus)
	round_finish_displaying_timer.restart()
	var game_core: StratagemHeroEffect_EffectGameCore = StratagemHeroEffect_EffectGame.instance.n_game_core
	var next_round: int = current_round + 1
	var new_round_ready: StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady = StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady
	new_round_ready.set_number(next_round)
	game_core.add_lantern_slide(new_round_ready)
	game_core.add_lantern_slide(create_new_singleline(next_round, current_score, arrow_completed, total_timer))
	for n_line in n_lines:
		n_line.death = true
	StratagemHeroEffect.instance.audio_round_completes[(current_round - 1) % 4].play()
	start_is_going_to_drop_focus()

## 通过给定战备列表创建所有战备行节点，同时添加节点到列表
func stratagems_to_nodes(stratagems: Array[StratagemData]) -> void:
	for stratagem in stratagems:
		var new_line: StratagemHeroEffect_EffectGameCore_StratagemLine = StratagemHeroEffect_EffectGameCore_StratagemLine.create(stratagem, StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION)
		n_lines.append(new_line)
		new_line.pressed_wrong.connect(on_line_wrong)
		add_child(new_line)
	if (not n_lines.is_empty()):
		n_lines[0].lighting = true

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.play()

func _drop_focus_postfix() -> void:
	pass

func on_line_wrong(_line_instance: StratagemHeroEffect_EffectGameCore_StratagemLine) -> void:
	var time_decrease: float = timer_max if StratagemHeroEffect_EffectGame.one_heart else BASIC_TIME_DECREASE
	if (wrong_protect_timer.percent <= 0.01):
		wrong_protect_timer.restart()
		timer -= time_decrease if StratagemHeroEffect_EffectGame.special_effect_mode != StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION else time_decrease * DICTATION_TIMER_DECREASE_MULTIPLIER
	n_time_left_bar.play_warning_effect()
	is_perfect = false

func start_is_going_to_drop_focus() -> void:
	StratagemHeroEffect.instance.audio_playing_music.stop()
	is_going_to_drop_focus = true

## 创建新的单行幻灯片实例
static func create_new_singleline(round_num: int, new_score: int, new_arrow_completed: int, new_total_timer: float) -> StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine:
	var new_single_line: StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine = StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine
	new_single_line.current_round = round_num
	new_single_line.current_score = new_score
	new_single_line.arrow_completed = new_arrow_completed
	new_single_line.timer_max = get_timer_max_for_round(round_num)
	if (StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION):
		new_single_line.timer_max *= DICTATION_TIMER_MULTIPLIER
	new_single_line.timer = new_single_line.timer_max
	new_single_line.total_timer = new_total_timer
	new_single_line.stratagems_to_nodes(make_stratagems_list(get_stratagems_count_for_round(new_single_line.current_round)))
	return new_single_line

## 获取给定回合数的战备数量
static func get_stratagems_count_for_round(round_num: int) -> int:
	return clampi(int(round_num * 0.5) + 2, 3, 16)

## 获取给定回合数的时间最大值
static func get_timer_max_for_round(round_num: int) -> float:
	return BASIC_TIMER_MAX / round_num ** 0.15

## 获取给定回合数的时间回复值
static func get_time_revive_for_round(round_num: int) -> float:
	return BASIC_TIME_REVIVE / round_num ** 0.5

func get_exitable() -> bool:
	return true
