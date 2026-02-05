extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_GreatWall
## 效果模式长城模式幻灯片类

static func _get_CPS() -> PackedScene:
	return preload("res://content/effect_game/core/lantern_slides/greatwall/lantern_slide_great_wall.tscn") as PackedScene

@onready var n_time_left_bar: ProgressBar = $TimeLeftBar as ProgressBar

var n_arrows: Array[StratagemHeroEffect_EffectGameCore_EffectArrow] = []
var time_left: float = 0.0

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_time_left_bar.size = Vector2(window_size.x * 0.75, window_size.y * 0.0889)
	n_time_left_bar.position = Vector2(window_size.x * 0.125, window_size.y * 0.04)

func _update(delta: float) -> void:
	match (state):
		State.DEAD:
			return
		State.FOCUS:
			if (time_left <= 0.0):
				drop_focus()
				return
			time_left -= delta
		State.MOVEOUT:
			moveout_timer += delta
			position.y = lerpf(0.0, -size.y, ease(clampf(moveout_timer / MOVEOUT_TIME, 0.0, 1.0), 0.2))
			if (moveout_timer >= MOVEOUT_TIME):
				state = State.DEAD
				return
