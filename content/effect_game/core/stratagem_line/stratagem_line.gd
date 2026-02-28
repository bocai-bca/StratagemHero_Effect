extends Node2D
class_name StratagemHeroEffect_EffectGameCore_StratagemLine
## 效果模式幻灯片使用的战备行

static func CPS() -> PackedScene:
	return preload("res://content/effect_game/core/stratagem_line/stratagem_line.tscn") as PackedScene

## 信号-按下且正确时广播
signal pressed_correct()
## 信号-按下且错误时广播
signal pressed_wrong()
## 信号-战备输入完成时广播，同时附带本实例战备的箭头数量
signal stratagem_done(arrow_count: int)

var n_icon_frame: PanelContainer
var n_icon: Sprite2D
var n_arrows: Array[StratagemHeroEffect_EffectGameCore_EffectArrow] = []

## 图标纹理宽度
const ICON_IMAGE_WIDTH: float = 512.0
## 亮起动画时间
const LIGHTING_TIME: float = 0.8
## 图标动画时间
const ICON_ANIMATION_TIME: float = 0.5
## 图标动画的最大偏斜范围
const ICON_ANIMATION_MAX_SKEW: float = 0.52
## 箭头间距比率，基于箭头大小
const ARROW_SPACING_RATE: float = 0.25
## 箭头起始位置
const ARROW_START_POSITION_X: float = 128.0
## 箭头标准宽度
const ARROW_BASIC_WIDTH: float = 144.0

## 本实例的战备数据
var stratagem_data: StratagemData
## 当前是否应该亮起(不亮起时呈现灰白)
var lighting: bool = false
## 亮起动画计时器
var lighting_timer: TransferTimer = TransferTimer.new(LIGHTING_TIME, true, 0.0)
## 窗口尺寸
var window_size: Vector2 = Vector2(1280.0, 720.0)
## 图标动画计时器
var icon_animation_timer: TransferTimer = TransferTimer.new(ICON_ANIMATION_TIME, true, 0.0)
## 图标动画计时器上一刻百分比
var icon_animation_timer_last_tick: float = 0.0
## 本实例是否处于完成态
var was_done: bool = false

## 相当于process，需要由持有并管理本箭头的幻灯片实例调用
func update(delta: float) -> void:
	lighting_timer.update(delta)
	set_instance_shader_parameter(&"gray_degree", lighting_timer.percent)
	update_icon(delta)
	update_arrows(delta)

## 按帧执行的输入检查
func update_check_input() -> void:
	var current_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow
	var is_last_one: bool = false
	for i in n_arrows.size():
		var n_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i]
		if (n_arrow.pressed):
			continue
		current_arrow = n_arrow
		is_last_one = i == n_arrows.size() - 1
		break
	if (current_arrow == null):
		be_done()
		return
	if (Input.is_action_just_pressed(&"down")):
		if (current_arrow.direction_now == StratagemData.CodeArrow.DOWN):
			press_correct(current_arrow, is_last_one)
			return
		press_wrong()
		return
	if (Input.is_action_just_pressed(&"up")):
		if (current_arrow.direction_now == StratagemData.CodeArrow.UP):
			press_correct(current_arrow, is_last_one)
			return
		press_wrong()
		return
	if (Input.is_action_just_pressed(&"left")):
		if (current_arrow.direction_now == StratagemData.CodeArrow.LEFT):
			press_correct(current_arrow, is_last_one)
			return
		press_wrong()
		return
	if (Input.is_action_just_pressed(&"right")):
		if (current_arrow.direction_now == StratagemData.CodeArrow.RIGHT):
			press_correct(current_arrow, is_last_one)
			return
		press_wrong()
		return

## 判定按下正确并标记下一个箭头为完成状态，并播放相关音效，同时若is_last_one为true则会调用stratagem_done()并播放完成音效
func press_correct(the_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow, is_last_one: bool) -> void:
	the_arrow.set_pressed(true)
	emit_signal(&"pressed_correct")
	if (is_last_one):
		StratagemHeroEffect.instance.audio_done.play()
	else:
		StratagemHeroEffect.instance.audio_press.play()
		be_done()

## 判定按下错误并重置所有箭头，并播放相关音效
func press_wrong() -> void:
	emit_signal(&"pressed_wrong")

## 使本战备行处于完成态，本方法自身不会播放音效，如需播放完成音效请在其他地方执行
func be_done() -> void:
	emit_signal(&"stratagem_done", stratagem_data.codes.size())

## 更新箭头
func update_arrows(delta: float) -> void:
	var width_used: float = StratagemHeroEffect.instance.get_fit_size(ARROW_START_POSITION_X)
	var width_per_arrow: float = StratagemHeroEffect.instance.get_fit_size(ARROW_BASIC_WIDTH) * (1.0 + ARROW_SPACING_RATE)
	var free_index: Array[int] = []
	for i in n_arrows.size():
		var n_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i]
		n_arrow.update(delta)
		n_arrow.scale = Vector2.ONE * width_per_arrow / StratagemHeroEffect_EffectGameCore_EffectArrow.IMAGE_WIDTH
		var this_width: float = width_per_arrow * n_arrow.alive_timer.percent
		n_arrow.position = Vector2(width_used + this_width * 0.5, 0.0)
		width_used += this_width
		if (not n_arrow.alive and not n_arrow.visible):
			free_index.append(i)
	for i in free_index.size():
		var j: int = free_index.size() - i - 1
		n_arrows.pop_at(j).queue_free()

## 更新图标动画
func update_icon(delta: float) -> void:
	icon_animation_timer.update(delta)
	if (icon_animation_timer.percent >= 0.5 && icon_animation_timer_last_tick <= 0.5):
		n_icon.texture = stratagem_data.icon
	icon_animation_timer_last_tick = icon_animation_timer.percent
	var degree: float = ease(absf(icon_animation_timer.percent - 0.5) * 2.0, -2.0)
	n_icon.scale.y = n_icon.scale.x * degree
	n_icon.skew = degree * ICON_ANIMATION_MAX_SKEW

func fit_size(new_window_size: Vector2) -> void:
	window_size = new_window_size
	var panel_stylebox: StyleBoxFlat = n_icon_frame.theme.get_stylebox(&"panel", &"PanelContainer") as StyleBoxFlat
	panel_stylebox.border_width_top = int(StratagemHeroEffect.instance.get_fit_size(4.0))
	panel_stylebox.border_width_bottom = int(StratagemHeroEffect.instance.get_fit_size(4.0))
	panel_stylebox.border_width_left = int(StratagemHeroEffect.instance.get_fit_size(4.0))
	panel_stylebox.border_width_right = int(StratagemHeroEffect.instance.get_fit_size(4.0))
	n_icon.scale = Vector2.ONE * StratagemHeroEffect.instance.get_fit_size(192.0) / ICON_IMAGE_WIDTH

## 变更战备数据
func change_stratagem_data_to(new_data: StratagemData) -> void:
	stratagem_data = new_data
	while (n_arrows.size() < new_data.codes.size()):
		n_arrows.append(StratagemHeroEffect_EffectGameCore_EffectArrow.create(StratagemData.random_arrow()))
	for i in new_data.codes.size():
		var n_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i]
		if (i >= new_data.codes.size()):
			n_arrow.set_alive(false)
			continue
		var code: StratagemData.CodeArrow = new_data.codes[i]
		n_arrow.change_direction_to(code)

## 启动一次图标动画，如果当前已在图标动画过程中，未过半的继续计时，过半的翻转计时进度
func start_icon_animation() -> void:
	if (icon_animation_timer.percent >= 0.5):
		icon_animation_timer.reversal()

## 类场景创建函数
static func create(new_data: StratagemData) -> StratagemHeroEffect_EffectGameCore_StratagemLine:
	var new_instance: StratagemHeroEffect_EffectGameCore_StratagemLine = CPS().instantiate() as StratagemHeroEffect_EffectGameCore_StratagemLine
	new_instance.change_stratagem_data_to(new_data)
	new_instance.n_icon_frame = new_instance.get_node(^"Icon/IconFrame") as PanelContainer
	new_instance.n_icon = new_instance.get_node(^"Icon") as Sprite2D
	return new_instance
