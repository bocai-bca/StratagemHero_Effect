extends StratagemHeroEffect_EffectGameCore_LanternSlide
#class_name StratagemHeroEffect_EffectGameCore_LanternSlide_
## 效果模式<name>幻灯片类

static func _get_CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://script_templates/StratagemHeroEffect_EffectGameCore_LanternSlide/Subclass.tscn") as PackedScene

func fit_size(window_size: Vector2) -> void:
	size = window_size
	# 从此处可扩展更多内容，具体取决于你想要给本幻灯片子类实现什么功能以及用到什么子节点

func update(delta: float) -> void:
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
