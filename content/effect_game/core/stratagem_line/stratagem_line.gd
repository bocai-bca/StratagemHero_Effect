extends Node2D
class_name StratagemHeroEffect_EffectGameCore_StratagemLine
## 效果模式幻灯片使用的战备行

static func CPS() -> PackedScene:
	return preload("res://content/effect_game/core/stratagem_line/stratagem_line.tscn") as PackedScene

## 信号-按下且正确时广播，同时附带本实例和本实例
signal pressed_correct(this_instance: StratagemHeroEffect_EffectGameCore_StratagemLine)
## 信号-按下且错误时广播，同时附带本实例和本实例
signal pressed_wrong(this_instance: StratagemHeroEffect_EffectGameCore_StratagemLine)
## 信号-战备输入完成时广播，同时附带本实例和本实例战备的箭头数量
signal stratagem_done(this_instance: StratagemHeroEffect_EffectGameCore_StratagemLine, arrow_count: int)

var theme_namebar: Theme
var stylebox_namebar: StyleBoxFlat

var n_icon_frame: PanelContainer
var n_icon: Sprite2D
var n_arrows: Array[StratagemHeroEffect_EffectGameCore_EffectArrow] = []
var n_namebar_container: PanelContainer
var n_namebar_text: Label

## 图标边框标准宽度
const ICON_BORDER_BASIC_WIDTH: float = 8.0
## 图标纹理宽度
const ICON_IMAGE_WIDTH: float = 512.0
## 图标标准宽度
const ICON_BASIC_SCALE: float = 112.0
## 亮起动画时间
const LIGHTING_TIME: float = 0.2
## 图标动画时间
const ICON_ANIMATION_TIME: float = 0.2
## 图标动画的最大偏斜范围
const ICON_ANIMATION_MAX_SKEW: float = 0.52
## 箭头间距比率，基于箭头大小
const ARROW_SPACING_RATE: float = 0.15
## 箭头起始位置
const ARROW_START_POSITION_X: float = 8.0
## 箭头标准宽度
const ARROW_BASIC_WIDTH: float = 88.0
## 淡出动画时间
const DEATH_TIME: float = 0.2
## 箭头排列允许的最长宽度比率，基于屏幕横向尺寸。当战备指令过长导致后面的箭头超出此范围时，本个战备行实例会启用转动排列模式
const ARROWS_LONGEST_DISPLAY_WIDTH_RATE: float = 0.75
## 箭头处于暗淡状态的调制值，箭头的暗淡状态与图标亮起完全同步
const ARROW_DARK_MODULATE_VALUE: float = 0.6
## 名称栏默认扩展边距长度
const NAMEBAR_DEFAULT_EXPAND_MARGIN: float = 16.0
## 名称栏默认边框宽度(表示渐变淡出的部分的宽度)
const NAMEBAR_DEFAULT_BORDER_WIDTH: float = 64.0
## 名称栏默认字体大小
const NAMEBAR_DEFAULT_FONT_SIZE: float = 32.0
## 名称栏暗淡状态的颜色
const NAMEBAR_DARK_COLOR: Color = Color(0.57142857142857142857142857142857, 0.57142857142857142857142857142857, 0.57142857142857142857142857142857)
## 名称栏正常状态的颜色
const NAMEBAR_DEFAULT_COLOR: Color = Color(1.0, 1.0, 0.0)

## 本实例的战备数据
var stratagem_data: StratagemData
## 当前是否应该亮起(不亮起时呈现灰白)
var lighting: bool = false:
	get:
		return lighting
	set(value):
		lighting = value
		lighting_timer.timing_direct = not value
## 亮起动画计时器
var lighting_timer: TransferTimer = TransferTimer.new(LIGHTING_TIME, true, LIGHTING_TIME)
## 窗口尺寸缓存
static var window_size: Vector2 = Vector2(1280.0, 720.0)
## 图标动画计时器
var icon_animation_timer: TransferTimer = TransferTimer.new(ICON_ANIMATION_TIME, true, ICON_ANIMATION_TIME)
## 图标动画计时器上一刻百分比
var icon_animation_timer_last_tick: float = 0.0
## 本实例是否处于完成态
var was_done: bool = false
## 本实例是否处于淡出状态
var death: bool = false
## 淡出动画倒计时器
var death_timer: TransferTimer = TransferTimer.new(DEATH_TIME, false, DEATH_TIME)
## 设定当本行实例有按错时不呈现按错动画
@export var dont_warn_when_wrong: bool = false
## 是否静音，设置为true时本行列实例不会调用音效播放
@export var silent: bool = false

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_icon_frame = $Icon/IconFrame as PanelContainer
		n_icon = $Icon as Sprite2D
		n_namebar_container = $NameBar as PanelContainer
		n_namebar_text = $NameBar/NameText as Label
		theme_namebar = n_namebar_container.theme
		stylebox_namebar = theme_namebar.get_stylebox(&"panel", &"PanelContainer") as StyleBoxFlat

## 相当于process，需要由持有并管理本箭头的幻灯片实例调用
func update(delta: float) -> void:
	lighting_timer.update(delta)
	update_icon(delta)
	update_arrows(delta)
	if (death):
		death_timer.update(delta)
	modulate.a = death_timer.percent

## 获取当前等待被按的箭头的索引，如果战备序列为空或者箭头全部完成则返回-1
func get_index_of_next_arrow() -> int:
	if (stratagem_data == null or stratagem_data.codes.is_empty()):
		return -1
	var result: int = -1
	for i in n_arrows.size():
		var n_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i]
		if (n_arrow.pressed):
			continue
		result = i
		return result
	return result

## 获取该列实例是否有所进度，相当于判断get_index_of_next_arrow()的结果是否大于0，但性能比其更好
func was_start() -> bool:
	if (n_arrows.is_empty()):
		return false
	return n_arrows[0].pressed

## 按帧执行的输入检查
func update_check_input() -> void:
	if (death or was_done or n_arrows.is_empty()):
		return
	var current_index: int = get_index_of_next_arrow()
	if (current_index == -1):
		be_done()
		return
	var current_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[current_index]
	var is_last_one: bool = current_index == stratagem_data.codes.size() - 1
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
	the_arrow.is_unknown = false
	emit_signal(&"pressed_correct", self)
	if (is_last_one):
		if (not silent):
			StratagemHeroEffect.instance.audio_done.play()
		be_done()
	elif (not silent):
		StratagemHeroEffect.instance.audio_press.play()

## 判定按下错误并重置所有箭头，并播放相关音效。如果dont_warn_when_wrong为true，则不会播放音效和按错动画，只会广播信号并重置箭头进度
func press_wrong() -> void:
	if (not dont_warn_when_wrong):
		if (not silent):
			StratagemHeroEffect.instance.audio_wrong.play()
		play_wrong()
	for n_arrow in n_arrows:
		n_arrow.set_pressed(false)
	emit_signal(&"pressed_wrong", self)

## 播放按错动画
func play_wrong() -> void:
	for n_arrow in n_arrows:
		n_arrow.wrong()

## 使本战备行处于完成态，本方法自身不会播放音效，如需播放完成音效请在其他地方执行
func be_done() -> void:
	was_done = true
	emit_signal(&"stratagem_done", self, stratagem_data.codes.size())

## 更新箭头
func update_arrows(delta: float) -> void:
	var width_used: float = StratagemHeroEffect.instance.get_fit_size(ARROW_START_POSITION_X)
	var width_per_arrow: float = StratagemHeroEffect.instance.get_fit_size(ARROW_BASIC_WIDTH) * (1.0 + ARROW_SPACING_RATE)
	var free_index: Array[int] = []
	for i in n_arrows.size():
		var n_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i]
		n_arrow.update(delta)
		var this_width: float = width_per_arrow * n_arrow.alive_timer.percent
		n_arrow.position = Vector2(width_used + this_width * 0.5, 0.0)
		width_used += this_width
		if (not n_arrow.alive and not n_arrow.visible):
			free_index.push_front(i)
		var modulate_value: float = lerpf(1.0, ARROW_DARK_MODULATE_VALUE, lighting_timer.percent)
		n_arrow.modulate = Color(
			n_arrow.modulate.r * modulate_value,
			n_arrow.modulate.g * modulate_value,
			n_arrow.modulate.b * modulate_value,
		)
	for i in free_index:
		(n_arrows.pop_at(i) as StratagemHeroEffect_EffectGameCore_EffectArrow).queue_free()

## 更新图标动画(也包括战备名称栏的更新)
func update_icon(delta: float) -> void:
	icon_animation_timer.update(delta)
	if (icon_animation_timer.percent >= 0.5 && icon_animation_timer_last_tick <= 0.5):
		n_icon.texture = stratagem_data.icon
		n_namebar_text.text = tr(stratagem_data.name_key)
		fit_size(window_size)
	icon_animation_timer_last_tick = icon_animation_timer.percent
	var degree: float = ease(absf(icon_animation_timer.percent - 0.5) * 2.0, -2.0)
	n_icon.scale.y = n_icon.scale.x * degree
	n_icon.skew = (1.0 - degree) * ICON_ANIMATION_MAX_SKEW
	var gray_degree: float = lighting_timer.percent
	n_icon.set_instance_shader_parameter(&"gray_degree", gray_degree)
	n_icon_frame.set_instance_shader_parameter(&"gray_degree", gray_degree)
	stylebox_namebar.bg_color = Color(
		lerpf(NAMEBAR_DEFAULT_COLOR.r, NAMEBAR_DARK_COLOR.r, gray_degree),
		lerpf(NAMEBAR_DEFAULT_COLOR.g, NAMEBAR_DARK_COLOR.g, gray_degree),
		lerpf(NAMEBAR_DEFAULT_COLOR.b, NAMEBAR_DARK_COLOR.b, gray_degree),
	)
	stylebox_namebar.border_color = Color(stylebox_namebar.bg_color, 0.0)

func fit_size(_window_size: Vector2) -> void:
	var panel_stylebox: StyleBoxFlat = n_icon_frame.theme.get_stylebox(&"panel", &"PanelContainer") as StyleBoxFlat
	panel_stylebox.border_width_top = int(StratagemHeroEffect.instance.get_fit_size(ICON_BORDER_BASIC_WIDTH))
	panel_stylebox.border_width_bottom = int(StratagemHeroEffect.instance.get_fit_size(ICON_BORDER_BASIC_WIDTH))
	panel_stylebox.border_width_left = int(StratagemHeroEffect.instance.get_fit_size(ICON_BORDER_BASIC_WIDTH))
	panel_stylebox.border_width_right = int(StratagemHeroEffect.instance.get_fit_size(ICON_BORDER_BASIC_WIDTH))
	var icon_width: float = StratagemHeroEffect.instance.get_fit_size(ICON_BASIC_SCALE)
	n_icon.scale = Vector2.ONE * icon_width / ICON_IMAGE_WIDTH
	n_icon.position = Vector2(icon_width * -0.5, 0.0)
	var arrow_scale_rate: float = StratagemHeroEffect.instance.get_fit_size(1.0)
	for n_arrow in n_arrows:
		n_arrow.scale = Vector2.ONE * ARROW_BASIC_WIDTH / StratagemHeroEffect_EffectGameCore_EffectArrow.IMAGE_WIDTH * arrow_scale_rate
	n_namebar_container.size = Vector2.ZERO
	n_namebar_container.position = Vector2(-icon_width + stylebox_namebar.expand_margin_left, -icon_width * 0.5 - n_namebar_container.size.y)
	theme_namebar.set_font_size(&"font_size", &"Label", int(StratagemHeroEffect.instance.get_fit_size(NAMEBAR_DEFAULT_FONT_SIZE)))
	stylebox_namebar.border_width_right = int(StratagemHeroEffect.instance.get_fit_size(NAMEBAR_DEFAULT_BORDER_WIDTH))
	stylebox_namebar.expand_margin_left = StratagemHeroEffect.instance.get_fit_size(NAMEBAR_DEFAULT_EXPAND_MARGIN)
	stylebox_namebar.expand_margin_right = StratagemHeroEffect.instance.get_fit_size(NAMEBAR_DEFAULT_EXPAND_MARGIN)

## 变更战备数据
func change_stratagem_data_to(new_data: StratagemData, is_dictation: bool = false) -> void:
	stratagem_data = new_data
	was_done = false
	start_icon_animation()
	var arrow_scale_rate: float = StratagemHeroEffect.instance.get_fit_size(1.0)
	while (n_arrows.size() < new_data.codes.size()):
		var new_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = StratagemHeroEffect_EffectGameCore_EffectArrow.create(StratagemData.random_arrow())
		n_arrows.append(new_arrow)
		new_arrow.scale = Vector2.ONE * ARROW_BASIC_WIDTH / StratagemHeroEffect_EffectGameCore_EffectArrow.IMAGE_WIDTH * arrow_scale_rate
		new_arrow.position = Vector2(-114514.0, 0.0)
		add_child(new_arrow)
	for i in n_arrows.size():
		var n_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i]
		n_arrow.set_pressed(false)
		if (i >= new_data.codes.size()):
			n_arrow.set_alive(false)
			continue
		var code: StratagemData.CodeArrow = new_data.codes[i]
		n_arrow.change_direction_to(code)
		n_arrow.is_unknown = is_dictation

## 启动一次图标动画，如果当前已在图标动画过程中，未过半的继续计时，过半的翻转计时进度
func start_icon_animation() -> void:
	if (icon_animation_timer.percent >= 0.5):
		icon_animation_timer.reversal()
	icon_animation_timer_last_tick = 0.0

## 类场景创建函数
static func create(new_data: StratagemData, is_dictation: bool = false) -> StratagemHeroEffect_EffectGameCore_StratagemLine:
	var new_instance: StratagemHeroEffect_EffectGameCore_StratagemLine = CPS().instantiate() as StratagemHeroEffect_EffectGameCore_StratagemLine
	new_instance.change_stratagem_data_to(new_data, is_dictation)
	return new_instance
