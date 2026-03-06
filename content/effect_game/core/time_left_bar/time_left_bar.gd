extends ProgressBar
class_name StratagemHeroEffect_EffectGameCore_TimeLeftBar
## 效果模式幻灯片使用的剩余时间条。时间条按单例运作设计，请勿用于同时存在多个时间条相互独立运作的场合

static var stylebox_fill: StyleBoxFlat = preload("res://content/effect_game/core/time_left_bar/stylebox_fill.tres")
static var stylebox_background: StyleBoxFlat = preload("res://content/effect_game/core/time_left_bar/stylebox_background.tres")

## 默认宽度比率，用于计算尺寸
const DEFAULT_WIDTH_RATIO: float = 0.65
## 默认高度比率，用于计算尺寸
const DEFAULT_HEIGHT_RATIO: float = 0.09
## 默认坐标比率，基于屏幕尺寸
const DEFAULT_POS_RATIO: Vector2 = Vector2(0.175, 0.09)
## 背景样式盒默认颜色
const STYLEBOX_BACKGROUND_DEFAULT_COLOR: Color = Color(0.25, 0.25, 0.25, 1.0)
## 背景样式盒警告颜色
const STYLEBOX_BACKGROUND_WARNING_COLOR: Color = Color(1.0, 0.0, 0.0, 1.0)
## 填充样式盒默认颜色
const STYLEBOX_FILL_DEFAULT_COLOR: Color = Color(1.0, 1.0, 0.0, 1.0)
## 填充样式盒警告颜色
const STYLEBOX_FILL_WARNING_COLOR: Color = Color(1.0, 0.3, 0.0, 1.0)
## 填充样式盒回复颜色
const STYLEBOX_FILL_REVIVE_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
## 回复效果时间
const REVIVE_EFFECT_TIME: float = 0.5
## 警告过渡开始点比率
const WARNING_RATIO: float = 0.6
## 背景警告效果时间
const BACKGROUND_WARNING_EFFECT_TIME: float = 0.2

## 宽度比率，基于屏幕宽度
@export var width_ratio: float = DEFAULT_WIDTH_RATIO
## 高度比率，基于屏幕高度
@export var height_ratio: float = DEFAULT_HEIGHT_RATIO
## 坐标比率，基于屏幕尺寸
@export var pos_ratio: Vector2 = DEFAULT_POS_RATIO
## 回复效果计时器
var revive_effect_timer: float = 0.0
## 背景警告效果计时器
var background_warning_effect_timer: float = 0.0

## 更新，建议于持有者节点的_process()或类似作用的方法调用
func update(delta: float, new_percent: float) -> void:
	revive_effect_timer = move_toward(revive_effect_timer, 0.0, delta)
	background_warning_effect_timer = move_toward(background_warning_effect_timer, 0.0, delta)
	var timebar_background_warning_effect_timing_percent: float = background_warning_effect_timer / BACKGROUND_WARNING_EFFECT_TIME
	stylebox_background.bg_color = Color(
		lerpf(STYLEBOX_BACKGROUND_DEFAULT_COLOR.r, STYLEBOX_BACKGROUND_WARNING_COLOR.r, timebar_background_warning_effect_timing_percent),
		lerpf(STYLEBOX_BACKGROUND_DEFAULT_COLOR.g, STYLEBOX_BACKGROUND_WARNING_COLOR.g, timebar_background_warning_effect_timing_percent),
		lerpf(STYLEBOX_BACKGROUND_DEFAULT_COLOR.b, STYLEBOX_BACKGROUND_WARNING_COLOR.b, timebar_background_warning_effect_timing_percent),
	)
	var fill_warning_weight: float = clampf(new_percent / WARNING_RATIO, 0.0, 1.0)
	var basic_current_fill_color: Color = Color(
		lerpf(STYLEBOX_FILL_WARNING_COLOR.r, STYLEBOX_FILL_DEFAULT_COLOR.r, fill_warning_weight),
		lerpf(STYLEBOX_FILL_WARNING_COLOR.g, STYLEBOX_FILL_DEFAULT_COLOR.g, fill_warning_weight),
		lerpf(STYLEBOX_FILL_WARNING_COLOR.b, STYLEBOX_FILL_DEFAULT_COLOR.b, fill_warning_weight),
	)
	var revive_effect_timing_percent: float = revive_effect_timer / REVIVE_EFFECT_TIME
	stylebox_fill.bg_color = Color(
		lerpf(basic_current_fill_color.r, STYLEBOX_FILL_REVIVE_COLOR.r, revive_effect_timing_percent),
		lerpf(basic_current_fill_color.g, STYLEBOX_FILL_REVIVE_COLOR.g, revive_effect_timing_percent),
		lerpf(basic_current_fill_color.b, STYLEBOX_FILL_REVIVE_COLOR.b, revive_effect_timing_percent),
	)
	value = new_percent

## 尺寸更新
func fit_size(window_size: Vector2) -> void:
	size = Vector2(window_size.x * width_ratio, window_size.y * height_ratio)
	position = window_size * pos_ratio

## 在本时间条实例上播放时间回复效果
func play_revive_effect() -> void:
	revive_effect_timer = REVIVE_EFFECT_TIME

## 在本时间条实例上播放背景警告效果
func play_warning_effect() -> void:
	background_warning_effect_timer = BACKGROUND_WARNING_EFFECT_TIME

# TODO 继续完成时间条的模块化工作，然后去其他各个幻灯片里移植
