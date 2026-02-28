extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine
## 效果模式单行式幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/single_line/lantern_slide_single_line.tscn") as PackedScene

@onready var n_time_left_bar: ProgressBar = $TimeLeftBar as ProgressBar
@onready var n_round_text: Label = $RoundText as Label
@onready var n_round_num: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer = $RoundNum as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
@onready var n_score_text: Label = $ScoreText as Label
@onready var n_score_num: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer = $ScoreNum as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
var n_lines: Array[StratagemHeroEffect_EffectGameCore_StratagemLine] = []

## 回合计数
var current_round: int = 1
## 分数计数
var current_score: int = 0
## 计时器
var timer: float
## 计时器最大值
var timer_max: float
## 箭头完成数(实际上必须完成整个指令才会记录该指令中的所有箭头)，其数值将跨回合传递，用于计算平均速度
var arrow_completed: int = 0
## 总计时器，其数值将跨回合传递，用于计算平均速度
var total_timer: float = 0.0

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_round_text.position = Vector2(size.x * -0.4, size.y * -0.3)
	n_score_text.position = Vector2(size.x * 0.4, size.y * -0.3)
	n_round_num.position = Vector2(size.x * -0.4, size.y * -0.2)
	n_score_num.position = Vector2(size.x * 0.4, size.y * -0.2)
	for n_line in n_lines:
		n_line.fit_size(window_size)

func _update_focus(delta: float) -> void:
	timer -= delta
	n_time_left_bar.value = timer / timer_max
	if (timer <= 0.0):
		to_game_over()

## 触发到游戏结束
func to_game_over() -> void:
	var game_core: StratagemHeroEffect_EffectGameCore = StratagemHeroEffect_EffectGame.instance.n_game_core
	var new_game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver.CPS().instantiate()
	new_game_over_lantern_slide.update_text(StratagemHeroEffect_EffectGame.get_special_mode_name_translated(), current_score, current_round, arrow_completed * 60.0 / total_timer)
	game_core.add_lantern_slide(new_game_over_lantern_slide)

## 触发到下一回合
func to_next_round() -> void:
	var game_core: StratagemHeroEffect_EffectGameCore = StratagemHeroEffect_EffectGame.instance.n_game_core
	var next_round: int = current_round + 1
	var new_round_ready: StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady = StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady
	new_round_ready.set_number(next_round)
	game_core.add_lantern_slide(new_round_ready)
	var new_single_line: StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine = StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine
	new_single_line.current_round = current_round
	new_single_line.current_score = current_score
	new_single_line.arrow_completed = arrow_completed
	new_single_line.total_timer = total_timer
	game_core.add_lantern_slide(new_single_line)

## 通过给定战备列表创建所有战备行节点
func stratagems_to_nodes(stratagems: Array[StratagemData]) -> void:
	for stratagem in stratagems:
		var new_line: StratagemHeroEffect_EffectGameCore_StratagemLine = StratagemHeroEffect_EffectGameCore_StratagemLine.create(stratagem)

		add_child(new_line)

## 获取给定回合数的战备数量
static func get_stratagems_count_for_round(round_num: int) -> int:
	return clampi(int(round_num * 0.5) + 2, 3, 16)

## 获取给定回合数的时间最大值
static func get_timer_max_for_round(round_num: int) -> float:
	return 0

## 从给定战备范围中随机生成指定长度的战备列表
static func make_stratagems_list(target_count: int, stratagems_enabled: Array[StringName] = StratagemHeroEffect_EffectGame_StratagemSelectionPanel.stratagems_enabled) -> Array[StratagemData]:
	var result: Array[StratagemData] = []
	while (result.size() < target_count):
		result.append(StratagemData.list[stratagems_enabled[randi_range(0, stratagems_enabled.size() - 1)]])
	return result
