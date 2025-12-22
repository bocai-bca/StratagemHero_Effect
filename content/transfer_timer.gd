extends RefCounted
class_name TransferTimer
## 变换计时器，是一种半自动的计时数据托管类

## 计时方向，为false表示向0移动，为true表示向max移动
var timing_direct: bool
## 当前持有值
var current: float
## 计时上限值，用于计算当前值的进度位置
var maximum: float
## 百分比，可通过访问本属性来直接获得本计时器的状态百分比，范围为0-1
var percent: float:
	get:
		return current / maximum

func update(delta: float) -> void:
	if (timing_direct):
		current = move_toward(current, maximum, delta)
	else:
		current = move_toward(current, 0.0, delta)

func _init(max_value: float, direct: bool, init_value: float = 0.0 if direct else max_value) -> void:
	maximum = max_value
	current = init_value
	timing_direct = direct
