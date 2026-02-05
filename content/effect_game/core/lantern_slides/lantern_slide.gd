@abstract
extends Panel
class_name StratagemHeroEffect_EffectGameCore_LanternSlide
## 效果模式幻灯片基类

## Class PackedScene
static var CPS: PackedScene:
	get:
		return _get_CPS()
	set(value):
		assert(false, "CPS(Class PackedScene) is used for get only.")

static func _get_CPS() -> PackedScene:
	assert(false, "This class has no CPS.")
	return null

## 信号-移交焦点，意味着本节点向效果游戏核心表示将幻灯片焦点移交给下一个幻灯片，同时附带一个本实例的引用
signal focus_dropped(this_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide)

## 幻灯片状态枚举
enum State{
	STANDBY, ## 待机状态，等待成为焦点
	FOCUS, ## 处于焦点
	MOVEOUT, ## 已不再是焦点，处于淡出过程中
	DEAD, ## 已完全离场，可以清除
}

## 移出动画时长
const MOVEOUT_TIME: float = 0.6

## 幻灯片状态
var state: State = State.STANDBY
## 移出计时器，用于幻灯片的出场动画
var moveout_timer: float = 0.0

## 抽象函数-适配窗口尺寸，需要实现使该幻灯片节点缩放至窗口尺寸的操作，本方法将由效果游戏核心调用
@abstract func _fit_size(window_size: Vector2) -> void

## 相当于_process()的方法，将由效果游戏核心调用。一般需要实现以下内容：幻灯片的移动、在游戏环节角度上自身的行为(如侦听输入完成战备指令等)
@abstract func _update(delta: float) -> void

## 当本幻灯片实例应当抛下焦点时应被自身调用此方法，同时将广播相应信号，效果游戏核心应侦听本信号，如需实现特殊功能可以在子类中覆写此方法
func drop_focus() -> void:
	emit_signal(&"focus_dropped", self)
	state = State.MOVEOUT

## 当本幻灯片实例获得焦点时应被效果游戏核心调用此方法以告知，如需要实现特殊功能可以在子类中覆写此方法
func got_focus() -> void:
	state = State.FOCUS
