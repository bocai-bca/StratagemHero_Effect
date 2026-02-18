extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_RoundReady
## 效果模式回合准备幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core/lantern_slides/round_ready/lantern_slide_round_ready.tscn") as PackedScene

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	# 从此处可扩展更多内容，具体取决于你想要给本幻灯片子类实现什么功能以及用到什么子节点

func _update(delta: float) -> void:
	# 可修改以下的各个分支代码块(包括DEAD的也可以根据需要修改)
	match (state):
		State.DEAD:
			return
		State.FOCUS:
			pass
		State.MOVEOUT:
			pass
		State.STANDBY:
			pass
