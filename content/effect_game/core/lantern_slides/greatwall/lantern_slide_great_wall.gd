extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_GreatWall
## 效果模式长城模式幻灯片类

static func _get_CPS() -> PackedScene:
	return preload("res://content/effect_game/core/lantern_slides/greatwall/lantern_slide_great_wall.tscn") as PackedScene

@onready var n_time_left_bar: ProgressBar = $TimeLeftBar as ProgressBar

var time_left: float = 0.0

## 适配尺寸的方法，相当于其他类在physics_process中做的事，不建议高频率调用
func fit_size(window_size: Vector2, get_fit_size_method: Callable) -> void:
	n_time_left_bar.size = Vector2(window_size.x * 0.75, window_size.y * 0.0889)
	n_time_left_bar.position = Vector2(window_size.x * 0.125, window_size.y * 0.04)

## 相当于其他类在process中做的事，需要由效果游戏核心调用
func update(delta: float) -> void:
