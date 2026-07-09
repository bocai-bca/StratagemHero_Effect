extends Control
class_name StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing_StratagemsArea
## 联机效果模式弹幕夺取幻灯片类的战备区域

## 父节点的引用
var parent: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing
## 主计时器，记录当前自开始起已过去多久
var timer: float = 0.0
## 管理中的战备行
var lines: Array[LineInstance] = []

func update(delta: float) -> void:
	var last_tick_time: float = timer
	timer += delta
	for i in parent.stratagems_time_and_life:
		var stratagem_time_and_life: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing.StratagemTimeAndLife = parent.stratagems_time_and_life[i]
		if (last_tick_time <= stratagem_time_and_life.spawn_time and stratagem_time_and_life.spawn_time <= timer):
			var new_line: StratagemHeroEffect_EffectGameCore_StratagemLine = StratagemHeroEffect_EffectGameCore_StratagemLine.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_StratagemLine
			new_line.change_stratagem_data_to(parent.effect_game_main.online_in_game_stratagems_list[i])
			lines.append(new_line)
	for i in lines.size():
		var line: LineInstance = lines[lines.size() - i - 1]
		# TODO 更新战备行

## 战备实例引用数据
class LineInstance extends RefCounted:
	## 战备行实例
	var line: StratagemHeroEffect_EffectGameCore_StratagemLine
	## 该战备行在父节点的stratagems_time_and_life列表中的对应项的索引号
	var index: int
