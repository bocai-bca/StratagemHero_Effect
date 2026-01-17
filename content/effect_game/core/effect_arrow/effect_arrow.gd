extends Control
class_name StratagemHeroEffect_EffectGameCore_EffectArrow

const CPS: PackedScene = preload("res://content/effect_game/core/effect_arrow/effect_arrow.tscn") as PackedScene

var n_arrow: Sprite2D # 由创建函数(create)赋值

## 动画时间，用于旋转、淡入淡出、位移
const ANIMATION_TIME: float = 0.25
## 箭头图像的宽度，用于缩放时参与计算
const IMAGE_WIDTH: float = 512.0

## 表示本箭头是否存活，存活时本箭头会开始执行淡入过程，不再存活时本箭头会开始执行淡入过程，并在淡出完毕后将根节点的visible设为false以便外部调用queue_free()和清除
var alive: bool = true
## 用于记录淡入淡出过程的计时器
var alive_timer: TransferTimer = TransferTimer.new(ANIMATION_TIME, true, 0.0)
## 记录本箭头旋转动画的起始角度
var from_rotation: float = 0.0
## 记录本箭头旋转动画的目标角度相对起始角度的偏移，也相当于from_rotation + to_rotation_offset代表它正确应该指向的角度
var to_rotation_offset: float = 0.0
## 记录本箭头的方向，方便外部快捷访问
var direction_now: StratagemData.CodeArrow
## 用于记录旋转过程时间的计时器
var spin_timer: TransferTimer = TransferTimer.new(ANIMATION_TIME, true, ANIMATION_TIME)

## 相当于process，需要由持有并管理本箭头的幻灯片实例调用
func update(delta: float) -> void:
	alive_timer.update(delta)
	spin_timer.update(delta)
	n_arrow.rotation = lerpf(from_rotation, from_rotation + to_rotation_offset, ease(spin_timer.percent, -2.2))
	if (alive):
		modulate.a = alive_timer.percent
		visible = true
	else:
		modulate.a = 1.0 - alive_timer.percent
		if (modulate.a == 0.0):
			visible = false

## 直接更换箭头朝向，箭头将旋转到新朝向，如果在已完成淡出过程状态下(!visible)调用本方法，将瞬间完成旋转
func change_direction_to(new_direction: StratagemData.CodeArrow) -> void:
	from_rotation = rotation_normalize(from_rotation)
	to_rotation_offset = fmod(direction_to_rotation(new_direction) - from_rotation, PI)
	direction_now = new_direction
	spin_timer.current = 0.0 if visible else ANIMATION_TIME

## 给定一个方向，返回对应该方向的旋转弧度
static func direction_to_rotation(the_direction: StratagemData.CodeArrow) -> float:
	match (the_direction):
		StratagemData.CodeArrow.UP:
			return 0.0
		StratagemData.CodeArrow.LEFT:
			return 0.5 * PI
		StratagemData.CodeArrow.DOWN:
			return PI
		StratagemData.CodeArrow.RIGHT:
			return -0.5 * PI
	return 0.0

## 旋转标准化，给定一个旋转弧度，返回它映射到处于-PI到PI之间的等效值
static func rotation_normalize(original_rotation: float) -> float:
	return fmod(original_rotation + PI, 2.0 * PI) - PI

static func create(new_direction: StratagemData.CodeArrow) -> StratagemHeroEffect_EffectGameCore_EffectArrow:
	var new_instance: StratagemHeroEffect_EffectGameCore_EffectArrow = CPS.instantiate() as StratagemHeroEffect_EffectGameCore_EffectArrow
	new_instance.n_arrow = new_instance.get_node(^"Arrow") as Sprite2D
	new_instance.change_direction_to(new_direction)
	return new_instance
