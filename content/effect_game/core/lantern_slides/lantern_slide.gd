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

@abstract func fit_size(window_size: Vector2, get_fit_size_method: Callable) -> void
