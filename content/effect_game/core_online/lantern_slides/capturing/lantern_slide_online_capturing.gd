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
## 对方完成时间，由对方发包过来
var opponent_line_completion_time: PackedFloat32Array = []
## 本地是否已结束
var was_over: bool = false
## 对方是否已确认可以游戏结束
var game_over_confirmed: bool = false
## 本地所得分数，在游戏结束后计算。由主机发给客机
var local_score: int = 0
## 对手所得分数，在游戏结束后计算。由主机发给客机
var opponent_score: int = 0

func _init() -> void:
	opponent_line_completion_time.resize(30)
	opponent_line_completion_time.fill(0.0)

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
	ingame_data_handle_loop()

func ingame_data_handle_loop() -> void:
	var reback_list: Array[StratagemHeroEffect_EffectGame_InGameData] = []
	while (not StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.is_empty()):
		var ingame_data: StratagemHeroEffect_EffectGame_InGameData = StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.pop_front() as StratagemHeroEffect_EffectGame_InGameData
		match (ingame_data.head):
			StratagemHeroEffect_EffectGame_InGameData.DataHead.STRATAGEM_INDEX:
				set_line_captured(ingame_data.data.to_int())
			StratagemHeroEffect_EffectGame_InGameData.DataHead.GAME_OVER:
				game_over()
			StratagemHeroEffect_EffectGame_InGameData.DataHead.GAME_OVER_CONFIRM:
				game_over_confirmed = true
			_:
				reback_list.append(ingame_data) #不是本幻灯片该处理的，塞回去
	StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.append_array(reback_list)

## 为一个战备行设置被夺取效果
func set_line_captured(line_index: int) -> void:
	if (line_index >= opponent_line_completion_time.size()):
		return
	opponent_line_completion_time[line_index] = 1.0
	n_stratagems_area.set_line_captured(line_index)

## 游戏结束，添加结束幻灯片并抛下焦点
func game_over() -> void:
	var game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlideOnline_GameOver.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlideOnline_GameOver
	game_over_lantern_slide.set_detail_capturing(local_score, opponent_score)
	if (opponent_score >= local_score):
		StratagemHeroEffect.instance.audio_game_over.play()
	else:
		StratagemHeroEffect.instance.audio_round_completes[randi_range(0, StratagemHeroEffect.instance.audio_round_completes.size() - 1)].play()
	StratagemHeroEffect.instance.audio_playing_music.stop()
	effect_game_main.n_game_core.add_lantern_slide(game_over_lantern_slide)
	drop_focus()

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
