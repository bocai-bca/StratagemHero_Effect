extends Label
class_name StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
## 效果模式动画化文本显示器，可以用于担任会在文本变化时产生跳动动画的文本显示任务
## 默认情况下本场景根节点不会对label_settings进行资源场景本地化

## 动画时间
const ANIMATION_TIME: float = 0.08
## 最高点旋转随机范围
const ANIMATION_FURTHER_ROTATION: Vector2 = Vector2(-0.1, 0.1)
## 最高点缩放随机范围
const ANIMATION_FURTHER_SCALE: Vector2 = Vector2(1.5, 1.7)
## 小动画最高点缩放
const ANIMATION_FURTHER_SCALE_SMALL: float = 1.2

## 动画计时器
var animation_timer: float = 0.0
## 动画最高点旋转
var animation_further_rotation_this: float = 0.0
## 动画最高点缩放
var animation_further_scale_this: float = 1.0

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	label_settings.font_size = int(StratagemHeroEffect.instance.get_fit_size(64.0))

func _process(delta: float) -> void:
	animation_timer = move_toward(animation_timer, 0.0, delta)
	var ease_value: float = ease(animation_timer / ANIMATION_TIME, 0.4)
	scale = Vector2.ONE * lerpf(1.0, animation_further_scale_this, ease_value)
	rotation = lerpf(0.0, animation_further_rotation_this, ease_value)

## 设置文本，同时会设置一个新的大动画。大动画是带放大和旋转的动画，且放大幅度更大
func set_new_text_large(new_text: String) -> void:
	text = new_text
	animation_further_rotation_this = randf_range(ANIMATION_FURTHER_ROTATION.x, ANIMATION_FURTHER_ROTATION.y)
	animation_further_scale_this = randf_range(ANIMATION_FURTHER_SCALE.x, ANIMATION_FURTHER_SCALE.y)
	animation_timer = ANIMATION_TIME

## 设置文本，同时会设置一个新的小动画，如果当前大动画正在播放，则不会覆盖大动画。小动画是只有放大的动画，且放大幅度较小
func set_new_text_small(new_text: String) -> void:
	text = new_text
	if (animation_timer <= 0.0):
		animation_further_rotation_this = 0.0
		animation_further_scale_this = ANIMATION_FURTHER_SCALE_SMALL
		animation_timer = ANIMATION_TIME
