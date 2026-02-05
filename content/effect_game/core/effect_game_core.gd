extends Control
class_name StratagemHeroEffect_EffectGameCore
## 效果游戏核心

## 已抛下过焦点正在移出过程的幻灯片
static var lantern_slides_moveout: Array[StratagemHeroEffect_EffectGameCore_LanternSlide] = []
## 正处于焦点的幻灯片
static var lantern_slide_focus: StratagemHeroEffect_EffectGameCore_LanternSlide = null
## 还未获得过焦点正在待机状态的幻灯片
static var lantern_slides_standby: Array[StratagemHeroEffect_EffectGameCore_LanternSlide] = []

func process(delta: float) -> void:
	for lantern_slide in lantern_slides_moveout:
		lantern_slide._update(delta)
	lantern_slide_focus._update(delta)
	if (lantern_slides_moveout.size() > 0 and lantern_slides_moveout[0].state == StratagemHeroEffect_EffectGameCore_LanternSlide.State.DEAD):
		(lantern_slides_moveout.pop_front() as StratagemHeroEffect_EffectGameCore_LanternSlide).queue_free()
	if (lantern_slide_focus == null):
		next_focus()

func fit_size(window_size: Vector2) -> void:
	for lantern_slide in lantern_slides_moveout:
		lantern_slide._fit_size(window_size)
	lantern_slide_focus._fit_size(window_size)
	for lantern_slide in lantern_slides_standby:
		lantern_slide._fit_size(window_size)

func start() -> void:
	var new_intro: StratagemHeroEffect_EffectGameCore_LanternSlide_Intro = StratagemHeroEffect_EffectGameCore_LanternSlide_Intro.CPS.instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlide_Intro
	new_intro.set_effect_mode_displayed(StratagemHeroEffect_EffectGame.special_effect_mode)
	lantern_slides_standby.append(new_intro)
	match (StratagemHeroEffect_EffectGame.special_effect_mode):
		StratagemHeroEffect_EffectGame.SpecialEffectMode.GREATWALL:
			pass

## 在幻灯片列表最末尾添加一个新幻灯片，同时将该幻灯片节点添加至场景树
func add_lantern_slide(lantern_slide_node: StratagemHeroEffect_EffectGameCore_LanternSlide) -> void:
	lantern_slides_standby.append(lantern_slide_node)
	add_child(lantern_slide_node)

## 用于连接到信号，当有幻灯片节点抛下焦点时被调用，负责转移引用、给下一个幻灯片赋予焦点
func on_lantern_slide_drop_focus(the_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlide) -> void:
	lantern_slides_moveout.append(the_lantern_slide)
	next_focus()

## 转动幻灯片数组，将焦点转移给下一个待机幻灯片
func next_focus() -> void:
	lantern_slide_focus = lantern_slides_standby.pop_front() as StratagemHeroEffect_EffectGameCore_LanternSlide
	lantern_slide_focus.focus_dropped.connect(on_lantern_slide_drop_focus, CONNECT_ONE_SHOT)
	lantern_slide_focus.got_focus()
