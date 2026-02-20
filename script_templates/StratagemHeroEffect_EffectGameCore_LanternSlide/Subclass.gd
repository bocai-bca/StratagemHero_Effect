extends StratagemHeroEffect_EffectGameCore_LanternSlide
#class_name StratagemHeroEffect_EffectGameCore_LanternSlide_
## 效果模式<name>幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://script_templates/StratagemHeroEffect_EffectGameCore_LanternSlide/Subclass.tscn") as PackedScene

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	# 从此处可扩展更多内容，具体取决于你想要给本幻灯片子类实现什么功能以及用到什么子节点

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(_delta: float) -> void:
	pass

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	pass
