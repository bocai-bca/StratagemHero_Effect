extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlide_Online_GameOver
## 联机效果模式游戏结束幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core_online/lantern_slides/game_over/lantern_slide_online_game_over.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_container: MarginContainer
var n_win_lose_text: Label

## 胜负文本默认字体大小
const WIN_LOSE_TEXT_FONT_SIZE_DEFAULT: float = 96.0

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_container.size = window_size
	n_win_lose_text.add_theme_font_size_override(&"font_size", int(StratagemHeroEffect.instance.get_fit_size(96.0)))

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(_delta: float) -> void:
	pass

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	pass

func get_exitable() -> bool:
	return false
