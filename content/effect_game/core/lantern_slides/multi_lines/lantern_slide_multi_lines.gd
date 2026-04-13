extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_MultiLines
## 效果模式多行幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/multi_lines/lantern_slide_multi_lines.tscn") as PackedScene

var label_settings_common: LabelSettings = preload("res://content/effect_game/core/lantern_slides/multi_lines/label_settings_common.tres") as LabelSettings

## 基本计时器最大值
const BASIC_TIMER_MAX: float = 8.0
## 基本计时器回复值
const BASIC_TIME_REVIVE: float = 4.0
## 基本计时器扣除值
const BASIC_TIME_DECREASE: float = 0.3
## 行列的X坐标的比率，基于屏幕横向尺寸
const LINES_POS_X_RATIO: float = 0.275
## 行列的Y坐标起点的比率，基于屏幕纵向尺寸
const LINES_POS_Y_START_RATIO: float = 0.3
## 行列的Y坐标增量的比率，基于屏幕纵向尺寸
const LINES_POS_Y_DELTA_RATIO: float = 0.2
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

var n_super_earth_logo: TextureRect
var n_time_left_bar: StratagemHeroEffect_EffectGameCore_TimeLeftBar
var n_round_text: Label
var n_round_num: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
var n_score_text: Label
var n_score_num: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
var n_lines: Array[StratagemHeroEffect_EffectGameCore_StratagemLine] = []
var n_round_finish_text: Label

var n_lines_need_to_play_wrong: Array[StratagemHeroEffect_EffectGameCore_StratagemLine] = []

## 战备池
var stratagem_pool: Array[StratagemData] = []
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
## 是否需要执行错误惩罚
var need_to_do_wrong: bool = false:
	get:
		return need_to_do_wrong
	set(value):
		if (not value):
			n_lines_need_to_play_wrong.clear()
		need_to_do_wrong = value
## 记录本刻是否有行按下正确
var is_line_correct_this_tick: bool = false
## 当前是否需要播放正确音效
var need_to_play_audio_correct: bool = false
## 正确音效方向
var correct_audio_direction: StratagemData.CodeArrow
## 当前是否需要播放完成音效
var need_to_play_audio_done: bool = false
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
		n_lines = [
			$StratagemLine_0 as StratagemHeroEffect_EffectGameCore_StratagemLine,
			$StratagemLine_1 as StratagemHeroEffect_EffectGameCore_StratagemLine,
			$StratagemLine_2 as StratagemHeroEffect_EffectGameCore_StratagemLine,
			$StratagemLine_3 as StratagemHeroEffect_EffectGameCore_StratagemLine,
		]

func _ready() -> void:
	n_round_num.text = str(current_round)

func _on_esc_exit() -> void:
	if (StratagemHeroEffect_EffectGameCore.lantern_slide_focus == self and not is_going_to_drop_focus):
		to_game_over()
		focus_drop_timer.complete()

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_time_left_bar.fit_size(window_size)
	n_round_text.position = Vector2(size.x * -0.4, size.y * -0.4)
	n_round_text.size = window_size
	n_score_text.position = Vector2(size.x * -0.4, size.y * -0.2)
	n_score_text.size = window_size
	n_round_num.position = Vector2(size.x * -0.4, size.y * -0.3)
	n_round_num.size = window_size
	n_round_num._fit_size(window_size)
	n_score_num.position = Vector2(size.x * -0.4, size.y * -0.1)
	n_score_num.size = window_size
	n_score_num._fit_size(window_size)
	var lines_pos_x: float = window_size.x * LINES_POS_X_RATIO
	var lines_pos_y_start: float = window_size.y * LINES_POS_Y_START_RATIO
	for i in n_lines.size():
		var n_line: StratagemHeroEffect_EffectGameCore_StratagemLine = n_lines[i]
		n_line.fit_size(window_size)
		n_line.position = Vector2(lines_pos_x, lines_pos_y_start + window_size.y * i * LINES_POS_Y_DELTA_RATIO)
	update_logo(n_super_earth_logo, window_size)
	n_round_finish_text.position = Vector2(0.0, size.y * 0.2)
	n_round_finish_text.size = window_size
	label_settings_common.font_size = int(StratagemHeroEffect.instance.get_fit_size(48.0))

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(delta: float) -> void:
	if (need_to_play_audio_correct):
		need_to_play_audio_correct = false
		match (correct_audio_direction):
			StratagemData.CodeArrow.UP:
				StratagemHeroEffect.instance.audio_press_up.play()
			StratagemData.CodeArrow.DOWN:
				StratagemHeroEffect.instance.audio_press_down.play()
			StratagemData.CodeArrow.LEFT:
				StratagemHeroEffect.instance.audio_press_left.play()
			StratagemData.CodeArrow.RIGHT:
				StratagemHeroEffect.instance.audio_press_right.play()
	if (need_to_play_audio_done):
		need_to_play_audio_done = false
		StratagemHeroEffect.instance.audio_done.play()
	if (not is_going_to_drop_focus):
		timer -= delta
		total_timer += delta
		if (timer <= 0.0):
			to_game_over()
			return
	if (need_to_do_wrong):
		do_wrong()
	is_line_correct_this_tick = false
	n_time_left_bar.update(delta, timer / timer_max)
	var is_line_start: bool = false
	for i in n_lines.size():
		var n_line: StratagemHeroEffect_EffectGameCore_StratagemLine = n_lines[i]
		n_line.update(delta)
		if (not n_line.was_done and n_line.was_start()):
			is_line_start = true
	if (is_line_start): #在没有任何行已经有进度的情况下
		for n_line in n_lines: #为有进度的当执行输入检测
			if (n_line.was_start()):
				n_line.update_check_input()
	else: #否则(已经有行有进度了)
		for n_line in n_lines: #为所有行执行输入检测
			n_line.update_check_input()
	if (is_going_to_drop_focus):
		focus_drop_timer.update(delta)
		if (focus_drop_timer.percent >= 1.0):
			drop_focus()
	round_finish_displaying_timer.update(delta)
	n_round_finish_text.visible_ratio = round_finish_displaying_timer.percent
	wrong_protect_timer.update(delta)

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.play()

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	pass

## 当有行列输入正确时被信号调用
func on_line_correct(_line_instance: StratagemHeroEffect_EffectGameCore_StratagemLine, direction: StratagemData.CodeArrow) -> void:
	need_to_do_wrong = false
	is_line_correct_this_tick = true
	need_to_play_audio_correct = true
	correct_audio_direction = direction

## 当有行列完成时被信号调用
func on_line_done(line_instance: StratagemHeroEffect_EffectGameCore_StratagemLine, code_num: int) -> void:
	arrow_completed += code_num
	arrow_completed_this_round += code_num
	current_score += code_num
	timer = move_toward(timer, timer_max, time_revive_this_round if StratagemHeroEffect_EffectGame.special_effect_mode != StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION_MULTILINES else time_revive_this_round * DICTATION_TIMER_MULTIPLIER)
	n_time_left_bar.play_revive_effect()
	if (stratagem_pool.is_empty()):
		line_instance.death = true
		var is_all_line_completed: bool = true
		for n_line in n_lines:
			if (not n_line.was_done):
				is_all_line_completed = false
				break
		if (is_all_line_completed):
			to_next_round()
	else:
		line_instance.change_stratagem_data_to(stratagem_pool.pop_back() as StratagemData, StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION_MULTILINES)
	need_to_play_audio_done = true

## 当有行列按错时被信号调用
func on_line_wrong(line_instance: StratagemHeroEffect_EffectGameCore_StratagemLine) -> void:
	if (is_line_correct_this_tick):
		return
	n_lines_need_to_play_wrong.append(line_instance)
	need_to_do_wrong = true

## 执行错误播放动画并施加相应时间惩罚，执行完毕后会重置need_to_do_wrong状态
func do_wrong() -> void:
	for n_line_need_to_play_wrong in n_lines_need_to_play_wrong:
		n_line_need_to_play_wrong.play_wrong()
	var time_decrease: float = timer_max if StratagemHeroEffect_EffectGame.one_heart else BASIC_TIME_DECREASE
	if (wrong_protect_timer.percent <= 0.01):
		wrong_protect_timer.restart()
		timer -= time_decrease if StratagemHeroEffect_EffectGame.special_effect_mode != StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION_MULTILINES else time_decrease * DICTATION_TIMER_DECREASE_MULTIPLIER
	n_time_left_bar.play_warning_effect()
	StratagemHeroEffect.instance.audio_wrong.play()
	is_perfect = false
	need_to_do_wrong = false

## 触发到游戏结束
func to_game_over() -> void:
	n_round_finish_text.text = tr(&"effect_text.lantern_slide.single_line.game_over")
	round_finish_displaying_timer.restart()
	var game_core: StratagemHeroEffect_EffectGameCore = StratagemHeroEffect_EffectGame.instance.n_game_core
	var new_game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver
	new_game_over_lantern_slide.update_text(StratagemHeroEffect_EffectGame.get_special_mode_name_translated(), current_score, current_round, arrow_completed * 60.0 / total_timer)
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
		tr(&"effect_text.lantern_slide.multi_line.round_completed") \
		+ "\n" + \
		tr(&"effect_text.lantern_slide.multi_line.time_bonus") + str(time_bonus) \
		+ "\n" + \
		tr(&"effect_text.lantern_slide.multi_line.perfect_bonus") + str(perfect_bonus)
	round_finish_displaying_timer.restart()
	var game_core: StratagemHeroEffect_EffectGameCore = StratagemHeroEffect_EffectGame.instance.n_game_core
	var next_round: int = current_round + 1
	var new_round_ready: StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady = StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady
	new_round_ready.set_number(next_round)
	game_core.add_lantern_slide(new_round_ready)
	game_core.add_lantern_slide(create_new_multiline(next_round, current_score, arrow_completed, total_timer))
	for n_line in n_lines:
		n_line.death = true
	StratagemHeroEffect.instance.audio_round_completes[(current_round - 1) % 4].play()
	start_is_going_to_drop_focus()

func start_is_going_to_drop_focus() -> void:
	StratagemHeroEffect.instance.audio_playing_music.stop()
	is_going_to_drop_focus = true

## 创建新的多行幻灯片实例
static func create_new_multiline(round_num: int, new_score: int, new_arrow_completed: int, new_total_timer: float) -> StratagemHeroEffect_EffectGameCore_LanternSlide_MultiLines:
	var new_multi_line: StratagemHeroEffect_EffectGameCore_LanternSlide_MultiLines = StratagemHeroEffect_EffectGameCore_LanternSlide_MultiLines.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_MultiLines
	new_multi_line.current_round = round_num
	new_multi_line.current_score = new_score
	new_multi_line.arrow_completed = new_arrow_completed
	new_multi_line.timer_max = get_timer_max_for_round(round_num)
	if (StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION_MULTILINES):
		new_multi_line.timer_max *= DICTATION_TIMER_MULTIPLIER
	new_multi_line.timer = new_multi_line.timer_max
	new_multi_line.total_timer = new_total_timer
	new_multi_line.stratagem_pool = make_stratagems_list(get_stratagems_count_for_round(new_multi_line.current_round))
	for n_line in new_multi_line.n_lines:
		n_line.lighting = true
		n_line.lighting_timer.complete()
		n_line.change_stratagem_data_to(new_multi_line.stratagem_pool.pop_back() as StratagemData, StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION_MULTILINES)
	return new_multi_line

## 获取给定回合数的战备数量
static func get_stratagems_count_for_round(round_num: int) -> int:
	return clampi(int(round_num * 0.5) + 2, 8, 28)

## 获取给定回合数的时间最大值
static func get_timer_max_for_round(round_num: int) -> float:
	return BASIC_TIMER_MAX / round_num ** 0.15

## 获取给定回合数的时间回复值
static func get_time_revive_for_round(round_num: int) -> float:
	return BASIC_TIME_REVIVE / round_num ** 0.5

func get_exitable() -> bool:
	return true
