extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady
## 效果模式回合准备幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/round_ready/lantern_slide_round_ready.tscn") as PackedScene

## 停留时间
const STAY_TIME: float = 1.0

var n_vbc: VBoxContainer

## 停留计时器
var stay_timer: float = STAY_TIME

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_vbc = $VBC as VBoxContainer

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	# 从此处可扩展更多内容，具体取决于你想要给本幻灯片子类实现什么功能以及用到什么子节点

func _update_focus(delta: float) -> void:
	stay_timer -= delta
	if (stay_timer <= 0.0):
		drop_focus()

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_ready.play()

func _drop_focus_postfix() -> void:
	if (StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.NONE or StratagemHeroEffect_EffectGame.special_effect_mode == StratagemHeroEffect_EffectGame.SpecialEffectMode.DICTATION):
		StratagemHeroEffect_EffectGame.instance.n_game_core.add_lantern_slide(StratagemHeroEffect_EffectGameCore_LanternSlide_SingleLine.CPS().instantiate())
