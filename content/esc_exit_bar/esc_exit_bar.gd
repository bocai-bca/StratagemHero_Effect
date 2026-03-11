extends ProgressBar
class_name StratagemHeroEffect_EscExitBar
## ESC退出栏，也掌管监听ESC退出的事

signal exit_emit()

@onready var n_text: Label = $Label as Label

## 计时器总值
const TIME: float = 1.25
## 尺寸比例，基于屏幕尺寸
const SIZE_RATIO: Vector2 = Vector2(0.2, 0.075)

static var instance: StratagemHeroEffect_EscExitBar
static var timer: TransferTimer = TransferTimer.new(TIME, true, 0.0)
static var was_reach_max: bool = false
static var is_now_able_to_exit: bool = false

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	if (Input.is_action_pressed(&"exit") and is_now_able_to_exit):
		timer.update(delta)
		if (timer.percent >= 1.0 and not was_reach_max):
			emit_signal(&"exit_emit")
			was_reach_max = true
		n_text.visible = true
	else:
		timer.restart()
		was_reach_max = false
		n_text.visible = false
	value = ease(timer.percent, 0.3)

func _physics_process(_delta: float) -> void:
	var window_size: Vector2 = Vector2(get_window().size)
	size = window_size * SIZE_RATIO
	n_text.size = size
