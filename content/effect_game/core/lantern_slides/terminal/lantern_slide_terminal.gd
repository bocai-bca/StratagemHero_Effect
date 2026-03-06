extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_Terminal
## 效果模式终端幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/terminal/lantern_slide_terminal.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_time_left_bar: ProgressBar
var n_score: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer
var n_arrows: Array[StratagemHeroEffect_EffectGameCore_EffectArrow] = []

## 初始箭头数量
const ARROWS_NUM_INITIAL_VALUE: int = 5
## 箭头数量最大值
const ARROWS_NUM_MAXIMUM: int = 12
## 剩余时间计时器上限
const TIMER_MAX: float = 20.0
## 摁完一行的回复时间的基础值
const TIME_REVIVE_BASIC: float = 15.0
## 摁错扣除时间的基础值
const TIME_DECREASE_BASIC: float = 1.0
## 能够播放大型结束音效所需达成的最少完成行数
const MIN_LINES_COMPLETED_ABLE_TO_PLAY_LARGE_GAMEOVER_SOUND: int = 5
## 每个箭头的标准宽度
const WIDTH_PER_ARROW: float = 96.0
## 每两个箭头之间的标准间距宽度
const SPACING_WIDTH_BETWEEN_ARROW: float = 8.0
## 箭头Y坐标比率，基于屏幕纵向长度
const ARROWS_POSITION_Y_RATIO: float = 0.5

## 剩余时间
var timer: TransferTimer = TransferTimer.new(TIMER_MAX, false, TIMER_MAX)
## 当前已完成的行数，本值+1即代表当前所在的回合数
var lines_completed: int = 0
## 当前获得的分数
#var score: int:
	#get:
		#return arrow_completed
## 当前已完成的箭头数，用于计量速度
var arrow_completed: int = 0:
	get:
		return arrow_completed
	set(value):
		arrow_completed = value
		n_score.set_new_text_large(str(arrow_completed))
## 总计时器，用于计量速度
var total_timer: float = 0.0
## 当前指令的缓存，执行判断的时候是基于节点的
var code_cache: Array[StratagemData.CodeArrow] = []
## 下一个指令缓存
var next_code_cache: StratagemData.CodeArrow
## 下一个箭头在n_arrows中的索引缓存
var next_arrow_index_cache: int

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_time_left_bar = $TimeLeftBar as ProgressBar
		n_score = $AnimatedTextDisplayer as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_score.size = window_size
	n_score.position = Vector2(0.0, window_size.y * 0.3)
	update_logo(n_super_earth_logo, window_size)
	var arrow_scale: float = StratagemHeroEffect.instance.get_fit_size(WIDTH_PER_ARROW) / StratagemHeroEffect_EffectGameCore_EffectArrow.IMAGE_WIDTH
	for n_arrow in n_arrows:
		n_arrow.scale = Vector2.ONE * arrow_scale

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(delta: float) -> void:
	timer.update(delta)
	total_timer += delta
	n_time_left_bar.value = timer.percent
	update_arrows(delta)
	check_input()
	if (timer.current <= 0.0):
		to_game_over()

## 更新箭头
func update_arrows(delta: float) -> void:
	var start_point: float = size.x * 0.5
	var width_used: float = 0.0
	var y_pos: float = size.y * ARROWS_POSITION_Y_RATIO
	var width_per_arrow: float = StratagemHeroEffect.instance.get_fit_size(WIDTH_PER_ARROW) + StratagemHeroEffect.instance.get_fit_size(SPACING_WIDTH_BETWEEN_ARROW) * 2.0
	for i in n_arrows.size():
		var n_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i]
		n_arrow.update(delta)
		n_arrow.position = Vector2(width_used + start_point + width_per_arrow * 0.5, y_pos)
		width_used += n_arrow.alive_timer.percent * width_per_arrow
	for n_arrow in n_arrows:
		n_arrow.position.x -= 0.5 * width_used

func check_input() -> void:
	if (Input.is_action_just_pressed(&"down")):
		if (next_code_cache == StratagemData.CodeArrow.DOWN):
			press_correct(n_arrows[next_arrow_index_cache])
			return
		press_wrong()
	elif (Input.is_action_just_pressed(&"up")):
		if (next_code_cache == StratagemData.CodeArrow.UP):
			press_correct(n_arrows[next_arrow_index_cache])
			return
		press_wrong()
	elif (Input.is_action_just_pressed(&"left")):
		if (next_code_cache == StratagemData.CodeArrow.LEFT):
			press_correct(n_arrows[next_arrow_index_cache])
			return
		press_wrong()
	elif (Input.is_action_just_pressed(&"right")):
		if (next_code_cache == StratagemData.CodeArrow.RIGHT):
			press_correct(n_arrows[next_arrow_index_cache])
			return
		press_wrong()

func press_correct(this_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow) -> void:
	this_arrow.set_pressed(true)
	next_arrow_index_cache += 1
	if (next_arrow_index_cache >= n_arrows.size()):
		next_line()
		StratagemHeroEffect.instance.audio_done.play()
		timer.current = move_toward(timer.current, TIMER_MAX, get_revive_time_for_line(lines_completed))
		lines_completed += 1
		arrow_completed += code_cache.size()
		return
	next_code_cache = code_cache[next_arrow_index_cache]
	StratagemHeroEffect.instance.audio_press.play()

func press_wrong() -> void:
	for n_arrow in n_arrows:
		n_arrow.wrong()
		n_arrow.set_pressed(false)
	next_arrow_index_cache = 0
	next_code_cache = code_cache[0]
	StratagemHeroEffect.instance.audio_wrong.play()
	timer.current -= TIME_DECREASE_BASIC

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.stop()
	if lines_completed >= MIN_LINES_COMPLETED_ABLE_TO_PLAY_LARGE_GAMEOVER_SOUND:
		StratagemHeroEffect.instance.audio_game_over_large.play()
	else:
		StratagemHeroEffect.instance.audio_game_over.play()

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.play()

## 进入新行
func next_line() -> void:
	code_cache.clear()
	var new_code_arrows_count: int = get_arrows_num_for_line(lines_completed + 1)
	while code_cache.size() < new_code_arrows_count:
		code_cache.append(StratagemData.random_arrow())
	var arrow_scale: float = StratagemHeroEffect.instance.get_fit_size(WIDTH_PER_ARROW) / StratagemHeroEffect_EffectGameCore_EffectArrow.IMAGE_WIDTH
	for i in code_cache.size():
		var this_code: StratagemData.CodeArrow = code_cache[i]
		if i >= n_arrows.size():
			var new_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = StratagemHeroEffect_EffectGameCore_EffectArrow.create(this_code)
			new_arrow.scale = Vector2.ONE * arrow_scale
			n_arrows.append(new_arrow)
			add_child(new_arrow)
		else:
			var this_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i]
			this_arrow.change_direction_to(this_code)
			this_arrow.set_pressed(false)
	next_arrow_index_cache = 0
	next_code_cache = code_cache[0]

## 执行游戏结束
func to_game_over() -> void:
	var game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver
	game_over_lantern_slide.update_text_str(tr(&"effect_text.lantern_slide.generic.mode_terminal"), str(arrow_completed), str(lines_completed), str(snappedf(arrow_completed * 60.0 / total_timer, 0.1)) + "/min")
	StratagemHeroEffect_EffectGame.instance.n_game_core.add_lantern_slide(game_over_lantern_slide)
	drop_focus()

## 获取给定行号的回复时间
static func get_revive_time_for_line(num_of_line_completed: int) -> float:
	return TIME_REVIVE_BASIC * clampf(1.5 / (num_of_line_completed + 1), 0.0, 1.0)

## 获取给定行号的箭头数量
static func get_arrows_num_for_line(the_line_num: int) -> int:
	return clampi(int(log(the_line_num) * 1.5) + ARROWS_NUM_INITIAL_VALUE, ARROWS_NUM_INITIAL_VALUE, ARROWS_NUM_MAXIMUM)
