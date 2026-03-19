extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_GreatWall
## 效果模式长城模式幻灯片类

static func CPS() -> PackedScene:
	return preload("res://content/effect_game/core/lantern_slides/greatwall/lantern_slide_great_wall.tscn") as PackedScene

## 允许同时存在的箭头数量(不包含淡出过程中的)
const MAX_ARROWS_SAME_TIME: int = 8
## 留给箭头用的宽度相对于幻灯片根节点宽度的比率
const ARROWS_USABLE_WIDTH_RATE: float = 0.8
## 箭头的隔断宽度相对于幻灯片根节点宽度的比率，每个箭头的隔断代表该箭头左侧和右侧额外空间的和
const ARROWS_SPACING_WIDTH_RATE: float = 0.02
## 播放大型游戏结束音效所需完成的箭头数量
const MIN_ARROW_COMPLETED_ABLE_TO_PLAY_LARGE_GAMEOVER_SOUND: int = 12
## 按错时扣除的时间
const TIME_REDUCE_WHEN_WRONG: float = 0.75
## 时间条上限
const TIME_LEFT_MAX: float = 15.0
## 连错保护时间
const WRONG_PROTECT_TIME: float = 0.6

var n_super_earth_logo: TextureRect
var n_time_left_bar: StratagemHeroEffect_EffectGameCore_TimeLeftBar
var n_score: StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer

var n_arrows: Array[StratagemHeroEffect_EffectGameCore_EffectArrow] = []
var arrow_completed: int = 0:
	get:
		return arrow_completed
	set(value):
		if (n_score != null):
			n_score.text = str(value)
		arrow_completed = value
var time_left: float = TIME_LEFT_MAX
## 每个箭头的最大允许宽度
var arrow_max_width: float = 0.0
## 计时器，用于计算平均速度
var total_timer: float = 0.0
## 连错保护计时器
var wrong_protect_timer: TransferTimer = TransferTimer.new(WRONG_PROTECT_TIME, false, 0.0)

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_time_left_bar = $TimeLeftBar as StratagemHeroEffect_EffectGameCore_TimeLeftBar
		n_score = $AnimatedTextDisplayer as StratagemHeroEffect_EffectGameCore_AnimatedTextDisplayer

func _on_esc_exit() -> void:
	if (StratagemHeroEffect_EffectGameCore.lantern_slide_focus == self):
		time_left -= TIME_LEFT_MAX

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_time_left_bar.fit_size(window_size)
	n_score._fit_size(window_size)
	n_score.position = Vector2(0.0, window_size.y * 0.3)
	arrow_max_width = (size.x * ARROWS_USABLE_WIDTH_RATE - size.x * ARROWS_SPACING_WIDTH_RATE * MAX_ARROWS_SAME_TIME) / MAX_ARROWS_SAME_TIME
	update_logo(n_super_earth_logo, window_size)

func _update_focus(delta: float) -> void:
	if (time_left <= 0.0):
		var game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_GameOver
		game_over_lantern_slide.update_text_str(tr(&"effect_text.lantern_slide.generic.mode_greatwall"), str(arrow_completed), "--", str(snappedf(arrow_completed * 60.0 / total_timer, 0.1)) + "/min")
		StratagemHeroEffect_EffectGame.instance.n_game_core.add_lantern_slide(game_over_lantern_slide)
		drop_focus()
		return
	while (n_arrows.size() < MAX_ARROWS_SAME_TIME):
		var new_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = StratagemHeroEffect_EffectGameCore_EffectArrow.create(StratagemData.random_arrow())
		n_arrows.append(new_arrow)
		add_child(new_arrow)
	for n_arrow in n_arrows:
		n_arrow.update(delta)
	time_left -= delta
	total_timer += delta
	n_time_left_bar.update(delta, time_left / TIME_LEFT_MAX)
	positioning_arrows()
	while (true):
		if (n_arrows.is_empty()): break
		if (not n_arrows[0].visible):
			n_arrows.pop_front().queue_free()
			continue
		break
	for n_arrow in n_arrows:
		if (not n_arrow.pressed):
			check_input(n_arrow)
			break
	wrong_protect_timer.update(delta)

func check_input(next_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow) -> void:
	if (Input.is_action_just_pressed(&"up")):
		if (next_arrow.direction_now == StratagemData.CodeArrow.UP):
			input_right(next_arrow)
		else:
			input_wrong()
	if (Input.is_action_just_pressed(&"down")):
		if (next_arrow.direction_now == StratagemData.CodeArrow.DOWN):
			input_right(next_arrow)
		else:
			input_wrong()
	if (Input.is_action_just_pressed(&"left")):
		if (next_arrow.direction_now == StratagemData.CodeArrow.LEFT):
			input_right(next_arrow)
		else:
			input_wrong()
	if (Input.is_action_just_pressed(&"right")):
		if (next_arrow.direction_now == StratagemData.CodeArrow.RIGHT):
			input_right(next_arrow)
		else:
			input_wrong()

func input_right(the_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow) -> void:
	the_arrow.set_alive(false)
	the_arrow.set_pressed(true)
	StratagemHeroEffect.instance.audio_press.play()
	arrow_completed += 1
	time_left = move_toward(time_left, TIME_LEFT_MAX, (1.0 / clampf(float(arrow_completed ** 0.8), 0.0, INF)) * TIME_LEFT_MAX)
	n_score.set_new_text_large(str(arrow_completed))

func input_wrong() -> void:
	for n_arrow in n_arrows:
		if (not n_arrow.pressed):
			n_arrow.wrong()
	StratagemHeroEffect.instance.audio_wrong.play()
	n_time_left_bar.play_warning_effect()
	if (wrong_protect_timer.percent <= 0.01):
		wrong_protect_timer.restart()
		time_left -= TIME_REDUCE_WHEN_WRONG if not StratagemHeroEffect_EffectGame.one_heart else TIME_LEFT_MAX

## 排列箭头，将设置它们的坐标和缩放
func positioning_arrows() -> void:
	var start_pos_x: float = (1.0 - ARROWS_USABLE_WIDTH_RATE) / 2.0 * size.x #箭头的起始排列X位置(对齐第一个箭头的左边框)
	var spacing: float = size.x * ARROWS_SPACING_WIDTH_RATE #每个箭头的宽度数
	var width_used: float = 0.0 #已使用的长度
	for i in n_arrows.size():
		var n_arrow: StratagemHeroEffect_EffectGameCore_EffectArrow = n_arrows[i] #获取当前遍历到达的箭头实例
		n_arrow.scale = Vector2.ONE * (arrow_max_width / n_arrow.IMAGE_WIDTH) #设置该箭头实例的缩放
		var this_width: float = (n_arrow.IMAGE_WIDTH * n_arrow.scale.x + spacing) * ease(n_arrow.modulate.a, -1.6) #计算该箭头实例的实际宽度占用
		n_arrow.position = Vector2(this_width / 2.0 + start_pos_x + width_used, size.y / 2.0)
		width_used += this_width

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.play()

func _drop_focus_postfix() -> void:
	if (arrow_completed >= MIN_ARROW_COMPLETED_ABLE_TO_PLAY_LARGE_GAMEOVER_SOUND):
		StratagemHeroEffect.instance.audio_game_over_large.play()
	else:
		StratagemHeroEffect.instance.audio_game_over.play()
	StratagemHeroEffect_SaveAccess.check_and_save_effect_score(StratagemHeroEffect_EffectGame.SpecialEffectMode.GREATWALL, arrow_completed, -1, arrow_completed * 60.0 / total_timer)

func get_exitable() -> bool:
	return true
