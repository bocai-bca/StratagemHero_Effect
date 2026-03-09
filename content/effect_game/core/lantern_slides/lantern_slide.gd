@abstract
extends Panel
class_name StratagemHeroEffect_EffectGameCore_LanternSlide
## 效果模式幻灯片基类(抽象)

static func CPS() -> PackedScene:
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

## 抽象方法-适配窗口尺寸，需要实现使该幻灯片节点缩放至窗口尺寸的操作，本方法将由效果游戏核心调用
@abstract func _fit_size(window_size: Vector2) -> void

## 虚方法-相当于_process()的方法，将由效果游戏核心调用。一般需要实现以下内容：幻灯片的移动、在游戏环节角度上自身的行为(如侦听输入完成战备指令等)
## 如果没有特殊需求则不需要覆写
func _update(delta: float) -> void:
	match (state):
		State.DEAD:
			_update_dead(delta)
		State.FOCUS:
			_update_focus(delta)
		State.MOVEOUT:
			_update_moveout(delta)
		State.STANDBY:
			_update_standby(delta)

## 虚方法-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	pass

## 虚方法-幻灯片死亡状态的过程方法，一般会直接用于State.DEAD时的_update方法
@warning_ignore("unused_parameter")
func _update_dead(delta: float) -> void:
	pass

## 虚方法-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
@warning_ignore("unused_parameter")
func _update_focus(delta: float) -> void:
	pass

## 虚方法-幻灯片移出状态的过程方法，一般会直接用于State.MOVEOUT时的_update方法
func _update_moveout(delta: float) -> void:
	moveout_timer += delta
	position.y = lerpf(0.0, -size.y, ease(clampf(moveout_timer / MOVEOUT_TIME, 0.0, 1.0), 0.2))
	if (moveout_timer >= MOVEOUT_TIME):
		state = State.DEAD
		return

## 虚方法-幻灯片待机状态的过程方法，一般会直接用于State.STANDBY时的_update方法
@warning_ignore("unused_parameter")
func _update_standby(delta: float) -> void:
	pass

## 虚方法-当幻灯片获得焦点时将被调用，会被调用于state被设置为State.FOCUS之后
func _got_focus_postfix() -> void:
	pass

## 当本幻灯片实例应当抛下焦点时应被自身调用此方法，同时将广播相应信号，效果游戏核心应侦听本信号，如需实现特殊功能可以在子类中覆写此方法
func drop_focus() -> void:
	emit_signal(&"focus_dropped", self)
	state = State.MOVEOUT
	_drop_focus_postfix()

## 当本幻灯片实例获得焦点时应被效果游戏核心调用此方法以告知，如需要实现特殊功能可以在子类中覆写_got_focus_postfix方法
func got_focus() -> void:
	state = State.FOCUS
	_got_focus_postfix()

## 更新logo节点的静态方法，把对应参数输进去就行，通常建议搭配_fit_size执行
static func update_logo(logo_node: TextureRect, viewport_size: Vector2) -> void:
	logo_node.size = viewport_size
	logo_node.position = viewport_size * 0.125

## 从给定战备范围中随机生成指定长度的战备列表
static func make_stratagems_list(target_count: int, stratagems_enabled: Array[StringName] = StratagemHeroEffect_EffectGame_StratagemSelectionPanel.stratagems_enabled) -> Array[StratagemData]:
	var result: Array[StratagemData] = []
	while (result.size() < target_count):
		result.append(StratagemData.list[stratagems_enabled[randi_range(0, stratagems_enabled.size() - 1)]])
	return result
