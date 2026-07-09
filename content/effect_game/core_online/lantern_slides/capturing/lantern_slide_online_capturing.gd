extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing
## 联机效果模式弹幕夺取幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core_online/lantern_slides/capturing/lantern_slide_online_capturing.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_stratagems_area: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing_StratagemsArea

## 效果模式主类引用，由效果模式主类在创建本幻灯片实例时赋予
var effect_game_main: StratagemHeroEffect_EffectGame
## 战备的出生时间和生存时间数据表，索引与EffectGame.online_in_game_stratagems_list一一对应
var stratagems_time_and_life: Array[StratagemTimeAndLife] = []

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_stratagems_area = $StratagemsArea as StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing_StratagemsArea
		n_stratagems_area.main = self

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_stratagems_area.size = window_size

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(delta: float) -> void:
	n_stratagems_area.update(delta)

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	pass

func get_exitable() -> bool:
	return true

## 战备的出生时间和生存时间数据
class StratagemTimeAndLife extends RefCounted:
	## 出生时间
	var spawn_time: float
	## 在屏幕上能够存在的时间
	var life_time: float
