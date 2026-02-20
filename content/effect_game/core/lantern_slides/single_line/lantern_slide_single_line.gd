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

## 计时器最大值
const TIME_MAX: float = 5.0

## 回合计数
var current_round: int = 1
## 分数计数
var current_score: int = 0
## 计时器
var timer: float = TIME_MAX
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

func _update_focus(delta: float) -> void:
	timer -= delta
	n_time_left_bar.value = timer / TIME_MAX
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
	pass # TODO 写RoundReady幻灯片、下一回合的SingleLine幻灯片的创建和添加到核心即可，注意要将本幻灯片的相关变量传递给下一个SingleLine幻灯片(如回合数、箭头完成数等)
