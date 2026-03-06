extends RefCounted
class_name TransferTimer
## 变换计时器，是一种半自动的计时数据托管类

## 计时方向，为false表示向0移动，为true表示向max移动
var timing_direct: bool
## 当前持有值
var current: float
## 计时上限值，用于计算当前值的进度位置
var maximum: float
## 百分比，可通过访问本属性来直接获得本计时器的状态百分比，或者设定本属性来通过百分比设置当前值，范围为0-1
var percent: float:
	get:
		return current / maximum
	set(value):
		value = clampf(value, 0.0, 1.0)
		current = maximum * value

## 更新函数，建议捆绑于使用节点的_process()或类似作用的函数调用，以便传入正确的delta
func update(delta: float) -> void:
	if (timing_direct):
		current = move_toward(current, maximum, delta)
	else:
		current = move_toward(current, 0.0, delta)

## 反转计时进度，使被调用的计时器呈现反转percent的效果，例如0.75将变为0.25
func reversal() -> void:
	current = maximum - current

## 反转计时进度并返回当前数值，详情见reversal()，另见reversal_with_percent()
func reversal_with_value() -> float:
	current = maximum - current
	return current

## 反转计时进度并返回当前百分比，详情见reversal()，另见reversal_with_value()
func reversal_with_percent() -> float:
	current = maximum - current
	return percent

## 重置计时进度，相当于将计时进度拨回到远离计时方向的最远端(如当timing_direct为true时将拨回0，反之拨回maximum)
func restart() -> void:
	if (timing_direct):
		current = 0.0
	else:
		current = maximum

## 立即完成计时，相当于将计时进度跳转到100%位置(如当timing_direct为true时将跳转到maximum，反之跳转到0)
func complete() -> void:
	if (timing_direct):
		current = maximum
	else:
		current = 0.0

## 减少计时进度，使计时值向远离计时方向移动value
func decrease(value: float) -> void:
	current = move_toward(current, 0.0 if timing_direct else maximum, value)

## 增加计时进度，使计时值向顺计时方向移动value
func increase(value: float) -> void:
	current = move_toward(current, maximum if timing_direct else 0.0, value)

## 构造函数，参数：最大值，变化方向(false负true增)，初始值
func _init(max_value: float, direct: bool, init_value: float = 0.0 if direct else max_value) -> void:
	maximum = max_value
	current = init_value
	timing_direct = direct
