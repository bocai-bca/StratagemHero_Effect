extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_Terminal
## 效果模式终端幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/terminal/lantern_slide_terminal.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_time_left_bar: ProgressBar
var n_score: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer

## 剩余时间计时器上限
const TIMER_MAX: float = 10.0
## 摁完一行的回复时间的基础值
const TIME_REVIVE_BASIC: float = 5.0
## 摁错扣除时间的基础值
const TIME_DECREASE_BASIC: float = 1.0
## 能够播放大型结束音效所需达成的最少完成行数
const MIN_LINES_COMPLETED_ABLE_TO_PLAY_LARGE_GAMEOVER_SOUND: int = 5

## 剩余时间
var timer: TransferTimer = TransferTimer.new(TIMER_MAX, false, TIMER_MAX)
## 当前已完成的行数
var lines_completed: int = 0
## 当前获得的分数
var score: int = 0
## 当前已完成的箭头数，用于计量速度
var arrow_completed: int = 0
## 总计时器，用于计量速度
var total_timer: float = 0.0

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_time_left_bar = $TimeLeftBar as ProgressBar
		n_score = $AnimatedTextDisplayer as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_score.size = window_size
	n_score.position = Vector2(0.0, window_size.y * 0.3)
	update_logo(n_super_earth_logo, window_size)

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(delta: float) -> void:
	timer.update(delta)
	n_time_left_bar.value = timer.percent
	if (timer.current <= 0.0):
		to_game_over()

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	if (lines_completed >= MIN_LINES_COMPLETED_ABLE_TO_PLAY_LARGE_GAMEOVER_SOUND):
		StratagemHeroEffect.instance.audio_game_over_large.play()
	else:
		StratagemHeroEffect.instance.audio_game_over.play()

func to_game_over() -> void:
	var game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver
	game_over_lantern_slide.update_text_str(tr(&"effect_text.lantern_slide.generic.mode_terminal"), str(score), str(lines_completed), str(snappedf(arrow_completed * 60.0 / total_timer, 0.1)) + "/min")
	StratagemHeroEffect_EffectGame.instance.n_game_core.add_lantern_slide(game_over_lantern_slide)
	drop_focus()
