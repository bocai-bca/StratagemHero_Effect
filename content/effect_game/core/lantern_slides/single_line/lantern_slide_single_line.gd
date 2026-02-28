extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine
## 效果模式单行式幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/single_line/lantern_slide_single_line.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_time_left_bar: ProgressBar
var n_round_text: Label
var n_round_num: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
var n_score_text: Label
var n_score_num: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
var n_lines: Array[StratagemHeroEffect_EffectGameCore_StratagemLine] = []
var n_lines_fadeouting: Array[StratagemHeroEffect_EffectGameCore_StratagemLine] = []

## 基本计时器最大值
const BASIC_TIMER_MAX: float = 8.0
## 行阵列的X坐标起始位置比率，基于本节点的横向尺寸
const LINES_POSITION_X_START_RATE: float = 0.25
## 行阵列的Y坐标起始位置比率，基于本节点的纵向尺寸
const LINES_POSITION_Y_START_RATE: float = 0.4
## 行阵列的垂直间隔距离比率，基于行的StratagemHeroEffect.instance.get_fit_size(ICON_BASIC_SCALE)
const LINES_SPACING_RATE: float = 0.2

## 回合计数
var current_round: int = 1
## 分数计数
var current_score: int = 0:
	get:
		return current_score
	set(value):
		current_score = value
		if (n_score_num != null):
			n_score_num.text = str(value)
## 计时器
var timer: float
## 计时器最大值
var timer_max: float
## 箭头完成数(实际上必须完成整个指令才会记录该指令中的所有箭头)，其数值将跨回合传递，用于计算平均速度
var arrow_completed: int = 0
## 总计时器，其数值将跨回合传递，用于计算平均速度
var total_timer: float = 0.0

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_time_left_bar = $TimeLeftBar as ProgressBar
		n_round_text = $RoundText as Label
		n_round_num = $RoundNum as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
		n_score_text = $ScoreText as Label
		n_score_num = $ScoreNum as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer

func _ready() -> void:
	n_round_num.text = str(current_round)

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_round_text.position = Vector2(size.x * -0.4, size.y * -0.3)
	n_score_text.position = Vector2(size.x * 0.4, size.y * -0.3)
	n_round_num.position = Vector2(size.x * -0.4, size.y * -0.2)
	n_score_num.position = Vector2(size.x * 0.4, size.y * -0.2)
	for n_line in n_lines:
		n_line.fit_size(window_size)
	update_logo(n_super_earth_logo, window_size)

func _update_focus(delta: float) -> void:
	timer -= delta
	n_time_left_bar.value = timer / timer_max
	total_timer += delta
	if (timer <= 0.0):
		to_game_over()
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
		n_lines_fadeouting.pop_front().queue_free()
	update_lines_position()

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
		to_next_round()
		return
	var the_one_moving: StratagemHeroEffect_EffectGameCore_StratagemLine = n_lines.pop_front() as StratagemHeroEffect_EffectGameCore_StratagemLine
	the_one_moving.death = true
	n_lines_fadeouting.append(the_one_moving)
	if (n_lines.is_empty()):
		to_next_round()
		return

## 触发到游戏结束
func to_game_over() -> void:
	var game_core: StratagemHeroEffect_EffectGameCore = StratagemHeroEffect_EffectGame.instance.n_game_core
	var new_game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver
	new_game_over_lantern_slide.update_text("--" if StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.NONE else StratagemHeroEffect_EffectGame.get_special_mode_name_translated(), current_score, current_round, arrow_completed * 60.0 / total_timer)
	game_core.add_lantern_slide(new_game_over_lantern_slide)
	drop_focus()

## 触发到下一回合
func to_next_round() -> void:
	var game_core: StratagemHeroEffect_EffectGameCore = StratagemHeroEffect_EffectGame.instance.n_game_core
	var next_round: int = current_round + 1
	var new_round_ready: StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady = StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady
	new_round_ready.set_number(next_round)
	game_core.add_lantern_slide(new_round_ready)
	game_core.add_lantern_slide(create_new_singleline(next_round, current_score, arrow_completed, total_timer))
	drop_focus()

## 通过给定战备列表创建所有战备行节点，同时添加节点到列表
func stratagems_to_nodes(stratagems: Array[StratagemData]) -> void:
	for stratagem in stratagems:
		var new_line: StratagemHeroEffect_EffectGameCore_StratagemLine = StratagemHeroEffect_EffectGameCore_StratagemLine.create(stratagem)
		n_lines.append(new_line)
		add_child(new_line)

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.play()

func _drop_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.stop()

## 创建新的单行幻灯片实例
static func create_new_singleline(round_num: int, new_score: int, new_arrow_completed: int, new_total_timer: float) -> StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine:
	var new_single_line: StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine = StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine
	new_single_line.current_round = round_num
	new_single_line.current_score = new_score
	new_single_line.arrow_completed = new_arrow_completed
	new_single_line.timer_max = get_timer_max_for_round(round_num)
	new_single_line.timer = new_single_line.timer_max
	new_single_line.total_timer = new_total_timer
	new_single_line.stratagems_to_nodes(make_stratagems_list(get_stratagems_count_for_round(new_single_line.current_round)))
	return new_single_line

## 获取给定回合数的战备数量
static func get_stratagems_count_for_round(round_num: int) -> int:
	return clampi(int(round_num * 0.5) + 2, 3, 16)

## 获取给定回合数的时间最大值
static func get_timer_max_for_round(round_num: int) -> float:
	return BASIC_TIMER_MAX / round_num ** 0.5

## 从给定战备范围中随机生成指定长度的战备列表
static func make_stratagems_list(target_count: int, stratagems_enabled: Array[StringName] = StratagemHeroEffect_EffectGame_StratagemSelectionPanel.stratagems_enabled) -> Array[StratagemData]:
	var result: Array[StratagemData] = []
	while (result.size() < target_count):
		result.append(StratagemData.list[stratagems_enabled[randi_range(0, stratagems_enabled.size() - 1)]])
	return result
