extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Racing
## 联机效果模式竞速幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core_online/lantern_slides/racing/lantern_slide_online_racing.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_p1_progress_bar: ProgressBar
var n_p2_progress_bar: ProgressBar
var n_p1_stratagem_line: StratagemHeroEffect_EffectGameCore_StratagemLine
var n_p2_stratagem_line: StratagemHeroEffect_EffectGameCore_StratagemLine

## 进度条尺寸比率，基于屏幕尺寸
const PROGRESS_BARS_SIZE_RATE: Vector2 = Vector2(0.8, 0.03)
## 进度条P1坐标比率，基于屏幕尺寸
const PROGRESS_BAR_P1_POSITION_RATE: Vector2 = Vector2(0.1, 0.44)
## 进度条P2坐标比率，基于屏幕尺寸
const PROGRESS_BAR_P2_POSITION_RATE: Vector2 = Vector2(0.1, 0.48)
## 战备行P1坐标比率，基于屏幕尺寸
const STRATAGEM_LINE_P1_POSITION_RATE: Vector2 = Vector2(0.15, 0.25)
## 战备行P2坐标比率，基于屏幕尺寸
const STRATAGEM_LINE_P2_POSITION_RATE: Vector2 = Vector2(0.15, 0.75)
## "你"提示文本P1坐标比率，基于屏幕尺寸
const YOU_TIP_TEXT_P1_POSITION_RATE: Vector2 = Vector2(0.02, 0.38)
## "你"提示文本P2坐标比率，基于屏幕尺寸
const YOU_TIP_TEXT_P2_POSITION_RATE: Vector2 = Vector2(0.02, 0.5)

## 效果模式主类引用，由效果模式主类在创建本幻灯片实例时赋予
var effect_game_main: StratagemHeroEffect_EffectGame
## 自己的战备行
var self_stratagem_line: StratagemHeroEffect_EffectGameCore_StratagemLine
## 对手战备行
var opponent_stratagem_line: StratagemHeroEffect_EffectGameCore_StratagemLine
## 本地战备进度索引
var local_stratagem_index: int = 0
## 对手战备索引缓存
var opponent_stratagem_index_cache: int = -1

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_p1_progress_bar = $P1ProgressBar as ProgressBar
		n_p1_progress_bar = $P2ProgressBar as ProgressBar
		n_p1_stratagem_line = $P1StratagemLine as StratagemHeroEffect_EffectGameCore_StratagemLine
		n_p2_stratagem_line = $P2StratagemLine as StratagemHeroEffect_EffectGameCore_StratagemLine

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_p1_progress_bar.size = window_size * PROGRESS_BARS_SIZE_RATE
	n_p1_progress_bar.position = window_size * PROGRESS_BAR_P1_POSITION_RATE
	n_p2_progress_bar.size = n_p1_progress_bar.size
	n_p2_progress_bar.position = window_size * PROGRESS_BAR_P2_POSITION_RATE
	n_p1_stratagem_line.fit_size(window_size)
	n_p1_stratagem_line.position = window_size * STRATAGEM_LINE_P1_POSITION_RATE
	n_p2_stratagem_line.fit_size(window_size)
	n_p2_stratagem_line.position = window_size * STRATAGEM_LINE_P2_POSITION_RATE

func _ready() -> void:
	if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
		self_stratagem_line = n_p1_stratagem_line
		opponent_stratagem_line = n_p2_stratagem_line
	elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
		self_stratagem_line = n_p2_stratagem_line
		opponent_stratagem_line = n_p1_stratagem_line

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(delta: float) -> void:
	while (not StratagemHeroEffect_EffectGame.online_in_game_stratagems_list.is_empty()):
		var ingame_data: StratagemHeroEffect_EffectGame_InGameData = StratagemHeroEffect_EffectGame.online_in_game_stratagems_list.pop_front() as StratagemHeroEffect_EffectGame_InGameData
		match (ingame_data.head):
			StratagemHeroEffect_EffectGame_InGameData.DataHead.STRATAGEM_INDEX:
				set_opponent_progress(ingame_data.data.to_int(), 0)
			StratagemHeroEffect_EffectGame_InGameData.DataHead.ARROW_INDEX:
				set_opponent_progress(opponent_stratagem_index_cache, ingame_data.data.to_int())
			StratagemHeroEffect_EffectGame_InGameData.DataHead.COMPLETE:
				if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
					complete_p1()
				elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
					complete_p2()
	self_stratagem_line.update_check_input()
	self_stratagem_line.update(delta)
	opponent_stratagem_line.update(delta)

func on_local_done() -> void:
	local_stratagem_index += 1
	if (StratagemHeroEffect_EffectGame.online_special_effect_mode == StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.RACING):
		if (local_stratagem_index >= StratagemHeroEffect_EffectGame.ONLINE_SPECIAL_EFFECT_MODE_RACING_STRATAGEMS_COUNT):
			effect_game_main.send_pack(
				StratagemHeroEffect_EffectGame_OnlineCode.new(
					StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA,
					StratagemHeroEffect_EffectGame.ONLINE_INGAME_DATA_OPERATION_HEAD_COMPLETE + ","
				),
				MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED
			)
			return
	if (StratagemHeroEffect_EffectGame.online_special_effect_mode == StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.DICTATION_RACING):
		if (local_stratagem_index >= StratagemHeroEffect_EffectGame.ONLINE_SPECIAL_EFFECT_MODE_DICTATION_RACING_STRATAGEMS_COUNT):
			effect_game_main.send_pack(
				StratagemHeroEffect_EffectGame_OnlineCode.new(
					StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA,
					StratagemHeroEffect_EffectGame.ONLINE_INGAME_DATA_OPERATION_HEAD_COMPLETE + ","
				),
				MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED
			)
			return
	effect_game_main.send_pack(
		StratagemHeroEffect_EffectGame_OnlineCode.new(
			StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA,
			StratagemHeroEffect_EffectGame.ONLINE_INGAME_DATA_OPERATION_HEAD_STRATAGEM_INDEX + "," + str(local_stratagem_index)
		),
		MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED
	)

## 设置战备总数，用于修改进度条上限
func set_stratagems_count(count_num: int) -> void:
	n_p1_progress_bar.max_value = count_num
	n_p2_progress_bar.max_value = count_num

## 播放对手错误效果
func opponent_wrong() -> void:
	opponent_stratagem_line.play_wrong()

## 设置对手进度，如果给定的战备索引数和缓存的索引数不同，则会切换战备，这将导致播放战备行的变换动画
func set_opponent_progress(current_stratagem_index: int, current_arrow_index: int) -> void:
	if (current_stratagem_index < 0 or current_stratagem_index >= StratagemHeroEffect_EffectGame.online_in_game_stratagems_list.size()):
		push_warning("Dirty data! Stratagem index given by remote peer is out of the bound of the local stratagem list. Disconnecting with remote peer.")
		drop_focus()
		StratagemHeroEffect_EffectGame.instance.soft_disconnect()
		return
	if (opponent_stratagem_index_cache != current_stratagem_index):
		opponent_stratagem_line.change_stratagem_data_to(StratagemHeroEffect_EffectGame.online_in_game_stratagems_list[current_stratagem_index])
		opponent_stratagem_index_cache = current_stratagem_index
	opponent_stratagem_line.set_arrow_index(current_arrow_index)

## 使P1已完成
func complete_p1() -> void:
	pass

## 使P2已完成
func complete_p2() -> void:
	pass

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	pass

func get_exitable() -> bool:
	return false
