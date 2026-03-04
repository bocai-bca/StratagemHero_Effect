extends Node2D
class_name StratagemHeroEffect_EffectGameCore_EffectArrow
## 效果模式效果箭头。坐标、大小方面的处理需要由其父节点或管理它们的节点进行，代码实现自由

static func CPS() -> PackedScene:
	return preload("res://content/effect_game/core/effect_arrow/effect_arrow.tscn") as PackedScene

#下方节点变量由创建函数(create)赋值
var n_arrow: Sprite2D
var n_ring: Sprite2D
var n_unknown: Sprite2D

## 动画时间，用于旋转、淡入淡出、位移
const ANIMATION_TIME: float = 0.15
## 箭头图像的宽度，用于缩放时参与计算
const IMAGE_WIDTH: float = 512.0
## 圆环动画时间，与ring_animation_timer关联
const RING_ANIMATION_TIME: float = 0.5
## 圆环被缩放到最大的缩放率
const RING_ANIMATION_MAX_SCALE: float = 5.0
## 圆环开始变得透明的最小缩放率(即需要介于0.0与RING_ANIMATION_MAX_SCALE之间)
const RING_ANIMATION_ALPHA_DECREASE_START_SCALE: float = 3.5
## 错误闪红动画时间
const WRONG_ANIMATION_TIME: float = 0.4
## 箭头动画时间，与arrow_animation_timer关联
const ARROW_ANIMATION_TIME: float = 0.15
## 箭头动画最远位移距离比率，基于IMAGE_WIDTH
const ARROW_ANIMATION_FAREST_MOVE_DISTANCE_RATE: float = 0.5
## 箭头动画曲线切换点位置，起百分比作用。必须位于区间(0.0, 1.0]之内
const ARROW_ANIMATION_CURVE_SWITCH_POINT: float = 1.0 / 3.0

## 表示本箭头是否存活，存活时本箭头会开始执行淡入过程，不再存活时本箭头会开始执行淡出过程，并在淡出完毕后将根节点的visible设为false以便外部调用queue_free()和清除
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
## 记录本箭头是否已被按下过
var pressed: bool = false:
	get:
		return pressed
	set(value):
		pressed = value
		if (value):
			ring_animation_timer = RING_ANIMATION_TIME
			arrow_animation_timer.restart()
			arrow_animation_direction = direction_now
## 圆环动画计时器，与RING_ANIMATION_TIME关联
var ring_animation_timer: float = 0.0
## 错误计时器，用于实现错误标红效果
var wrong_timer: float = 0.0
## 箭头动画计时器，与ARROW_ANIMATION_TIME关联，采用正计时
var arrow_animation_timer: TransferTimer = TransferTimer.new(ARROW_ANIMATION_TIME, true, ARROW_ANIMATION_TIME)
## 记录箭头动画的运动方向
var arrow_animation_direction: StratagemData.CodeArrow
## 当前箭头是否已知，主要用于默写模式
var is_unknown: bool = false:
	get:
		return is_unknown
	set(value):
		n_arrow.visible = not value
		n_unknown.visible = value

## 相当于process，需要由持有并管理本箭头的幻灯片实例调用
func update(delta: float) -> void:
	alive_timer.update(delta)
	spin_timer.update(delta)
	arrow_animation_timer.update(delta)
	n_arrow.rotation = lerpf(from_rotation, from_rotation + to_rotation_offset, ease(spin_timer.percent, -2.2))
	if (alive):
		modulate.a = alive_timer.percent
		visible = true
	else:
		modulate.a = alive_timer.percent
		if (modulate.a == 0.0):
			visible = false
	ring_animation_timer = move_toward(ring_animation_timer, 0.0, delta)
	var ring_scale_rate: float = lerpf(RING_ANIMATION_MAX_SCALE, 0.0, ring_animation_timer / RING_ANIMATION_TIME)
	n_ring.scale = Vector2.ONE * ring_scale_rate
	n_ring.modulate.a = clampf((RING_ANIMATION_ALPHA_DECREASE_START_SCALE - ring_scale_rate) / (RING_ANIMATION_MAX_SCALE - RING_ANIMATION_ALPHA_DECREASE_START_SCALE), 0.0, 1.0)
	wrong_timer = move_toward(wrong_timer, 0.0, delta)
	var wrong_modulate: float = 1.0 - (wrong_timer / WRONG_ANIMATION_TIME)
	if (pressed):
		modulate = Color(1.0, wrong_modulate, 0.0, modulate.a)
	else:
		modulate = Color(1.0, wrong_modulate, wrong_modulate, modulate.a)
	update_arrow_animation()

## 更新箭头动画，注意箭头动画计时器的更新由update()承担
func update_arrow_animation() -> void:
	#坐标偏移量，实际的偏移距离 = offset_rate * ARROW_ANIMATION_FAREST_MOVE_DISTANCE_RATE * IMAGE_WIDTH
	var offset_rate: float = \
		ease(arrow_animation_timer.percent / ARROW_ANIMATION_CURVE_SWITCH_POINT, 0.4) \
		if (arrow_animation_timer.percent <= ARROW_ANIMATION_CURVE_SWITCH_POINT) \
		else 1.0 - ease((arrow_animation_timer.percent - ARROW_ANIMATION_CURVE_SWITCH_POINT) / (1.0 - ARROW_ANIMATION_CURVE_SWITCH_POINT), -2)
	match (arrow_animation_direction):
		StratagemData.CodeArrow.UP:
			n_arrow.position = Vector2(0.0, -offset_rate * ARROW_ANIMATION_FAREST_MOVE_DISTANCE_RATE * IMAGE_WIDTH)
		StratagemData.CodeArrow.DOWN:
			n_arrow.position = Vector2(0.0, offset_rate * ARROW_ANIMATION_FAREST_MOVE_DISTANCE_RATE * IMAGE_WIDTH)
		StratagemData.CodeArrow.LEFT:
			n_arrow.position = Vector2(-offset_rate * ARROW_ANIMATION_FAREST_MOVE_DISTANCE_RATE * IMAGE_WIDTH, 0.0)
		StratagemData.CodeArrow.RIGHT:
			n_arrow.position = Vector2(offset_rate * ARROW_ANIMATION_FAREST_MOVE_DISTANCE_RATE * IMAGE_WIDTH, 0.0)

## 直接更换箭头朝向，箭头将旋转到新朝向，如果在已完成淡出过程状态下(!visible)调用本方法，将瞬间完成旋转
func change_direction_to(new_direction: StratagemData.CodeArrow) -> void:
	from_rotation = rotation_normalize(from_rotation)
	to_rotation_offset = fmod(direction_to_rotation(new_direction) - from_rotation, 2 * PI)
	direction_now = new_direction
	arrow_animation_direction = new_direction
	spin_timer.current = 0.0 if visible else ANIMATION_TIME

## 执行错误动画
func wrong() -> void:
	wrong_timer = WRONG_ANIMATION_TIME

## 设置按下状态
func set_pressed(value: bool) -> void:
	pressed = value

## 设置存活状态
func set_alive(value: bool) -> void:
	alive = value
	alive_timer.timing_direct = not alive_timer.timing_direct

## 给定一个方向，返回对应该方向的旋转弧度
static func direction_to_rotation(the_direction: StratagemData.CodeArrow) -> float:
	match (the_direction):
		StratagemData.CodeArrow.UP:
			return 0.0
		StratagemData.CodeArrow.LEFT:
			return -0.5 * PI
		StratagemData.CodeArrow.DOWN:
			return PI
		StratagemData.CodeArrow.RIGHT:
			return 0.5 * PI
	return 0.0

## 旋转标准化，给定一个旋转弧度，返回它映射到处于-PI到PI之间的等效值
static func rotation_normalize(original_rotation: float) -> float:
	return fmod(original_rotation + PI, 2.0 * PI) - PI

## 类场景创建函数
static func create(new_direction: StratagemData.CodeArrow) -> StratagemHeroEffect_EffectGameCore_EffectArrow:
	var new_instance: StratagemHeroEffect_EffectGameCore_EffectArrow = CPS().instantiate() as StratagemHeroEffect_EffectGameCore_EffectArrow
	new_instance.n_arrow = new_instance.get_node(^"Arrow") as Sprite2D
	new_instance.n_ring = new_instance.get_node(^"Ring") as Sprite2D
	new_instance.n_unknown = new_instance.get_node(^"Unknown") as Sprite2D
	new_instance.change_direction_to(new_direction)
	return new_instance
