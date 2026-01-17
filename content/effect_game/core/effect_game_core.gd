extends Control
class_name StratagemHeroEffect_EffectGameCore
## 效果游戏核心

static var lantern_slides: Array[StratagemHeroEffect_EffectGameCore_LanternSlide] = []
static var lantern_slides_focus_index: int = 0

func process(delta: float) -> void:
	pass

func fit_size(window_size: Vector2, get_fit_size_method: Callable) -> void:
	for lantern_slide in lantern_slides:
		lantern_slide.fit_size(window_size, get_fit_size_method)

func start(effect_mode: StratagemHeroEffect_EffectGame.SpecialEffectMode) -> void:
	pass
