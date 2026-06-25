extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Racing
## 联机效果模式竞速幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core_online/lantern_slides/racing/lantern_slide_online_racing.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_p1_progress_bar: ProgressBar
var n_p2_progress_bar: ProgressBar
var n_p1_stratagem_line: StratagemHeroEffect_EffectGameCore_StratagemLine
var n_p2_stratagem_line: StratagemHeroEffect_EffectGameCore_StratagemLine

## 进度条尺寸比率，基于屏幕尺寸
const PROGRESS_BARS_SIZE_RATE: Vector2 = Vector2(0.8, 0.03)
## 进度条P1坐标比率，基于屏幕尺寸
const PROGRESS_BAR_P1_POSITION_RATE: Vector2 = Vector2(0.1, 0.44)
## 进度条P2坐标比率，基于屏幕尺寸
const PROGRESS_BAR_P2_POSITION_RATE: Vector2 = Vector2(0.1, 0.48)
## 战备行P1坐标比率，基于屏幕尺寸
const STRATAGEM_LINE_P1_POSITION_RATE: Vector2 = Vector2(0.15, 0.25)
## 战备行P2坐标比率，基于屏幕尺寸
const STRATAGEM_LINE_P2_POSITION_RATE: Vector2 = Vector2(0.15, 0.75)

## 效果模式主类引用，由效果模式主类在创建本幻灯片实例时赋予
var effect_game_main: StratagemHeroEffect_EffectGame

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_p1_progress_bar = $P1ProgressBar as ProgressBar
		n_p1_progress_bar = $P2ProgressBar as ProgressBar
		n_p1_stratagem_line = $P1StratagemLine as StratagemHeroEffect_EffectGameCore_StratagemLine
		n_p2_stratagem_line = $P2StratagemLine as StratagemHeroEffect_EffectGameCore_StratagemLine

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_p1_progress_bar.size = window_size * PROGRESS_BARS_SIZE_RATE
	n_p1_progress_bar.position = window_size * PROGRESS_BAR_P1_POSITION_RATE
	n_p2_progress_bar.size = n_p1_progress_bar.size
	n_p2_progress_bar.position = window_size * PROGRESS_BAR_P2_POSITION_RATE
	n_p1_stratagem_line.fit_size(window_size)
	n_p1_stratagem_line.position = window_size * STRATAGEM_LINE_P1_POSITION_RATE
	n_p2_stratagem_line.fit_size(window_size)
	n_p2_stratagem_line.position = window_size * STRATAGEM_LINE_P2_POSITION_RATE

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(_delta: float) -> void:
	pass

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	pass

func get_exitable() -> bool:
	return false
