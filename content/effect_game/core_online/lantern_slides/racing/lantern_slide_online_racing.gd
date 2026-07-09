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
var n_you_tip_text: Label
var n_p1_completed_text: Label
var n_p2_completed_text: Label

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
const YOU_TIP_TEXT_P1_POSITION_RATE: Vector2 = Vector2(0.04, 0.38)
## "你"提示文本P2坐标比率，基于屏幕尺寸
const YOU_TIP_TEXT_P2_POSITION_RATE: Vector2 = Vector2(0.04, 0.5)
## "你"提示文本默认字体大小
const YOU_TIP_TEXT_DEFAULT_FONT_SIZE: float = 36.0
## 已完成提示文本默认字体大小
const COMPLETED_TEXT_DEFAULT_FONT_SIZE: float = 48.0
## 已完成提示文本P1坐标比率，基于屏幕尺寸
const COMPLETED_TEXT_P1_POSITION_RATE: Vector2 = Vector2(0.0, 0.2)
## 已完成提示文本P2坐标比率，基于屏幕尺寸
const COMPLETED_TEXT_P2_POSITION_RATE: Vector2 = Vector2(0.0, 0.7)
## 已完成提示文本动画时间
const COMPLETED_TEXT_ANIMATION_TIME: float = 1.0

## 效果模式主类引用，由效果模式主类在创建本幻灯片实例时赋予
var effect_game_main: StratagemHeroEffect_EffectGame
## 自己的战备行
var self_stratagem_line: StratagemHeroEffect_EffectGameCore_StratagemLine
## 对手战备行
var opponent_stratagem_line: StratagemHeroEffect_EffectGameCore_StratagemLine
## 本地战备进度索引
var local_stratagem_index: int = 0
## 对手战备索引缓存
var opponent_stratagem_index_cache: int = 0
## P1已完成提示文本动画计时器
var p1_completed_text_animation_timer: float = 0.0
## P2已完成提示文本动画计时器
var p2_completed_text_animation_timer: float = 0.0
## P1是否已完成
var was_p1_completed: bool = false
## P2是否已完成
var was_p2_completed: bool = false
## 本地完成时间
var local_complete_time: float = 0.0
## 对方完成时间，由对方在完成时发包过来
var remote_complete_time: float = 0.0
## 对方是否已确认可以游戏结束
var game_over_confirmed: bool = false
## 是否是默写模式的缓存
var is_dictation_cache: bool = false

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_p1_progress_bar = $P1ProgressBar as ProgressBar
		n_p2_progress_bar = $P2ProgressBar as ProgressBar
		n_p1_stratagem_line = $P1StratagemLine as StratagemHeroEffect_EffectGameCore_StratagemLine
		n_p2_stratagem_line = $P2StratagemLine as StratagemHeroEffect_EffectGameCore_StratagemLine
		n_you_tip_text = $YouTipText as Label
		n_p1_completed_text = $P1CompletedText as Label
		n_p2_completed_text = $P2CompletedText as Label

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
	var you_tip_text_font_size: float = StratagemHeroEffect.instance.get_fit_size(YOU_TIP_TEXT_DEFAULT_FONT_SIZE)
	n_you_tip_text.add_theme_font_size_override(&"font_size", int(you_tip_text_font_size))
	if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
		n_you_tip_text.position = window_size * YOU_TIP_TEXT_P1_POSITION_RATE
	elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
		n_you_tip_text.position = window_size * YOU_TIP_TEXT_P2_POSITION_RATE
	var completed_text_font_size: float = StratagemHeroEffect.instance.get_fit_size(COMPLETED_TEXT_DEFAULT_FONT_SIZE)
	n_p1_completed_text.add_theme_font_size_override(&"font_size", int(completed_text_font_size))
	n_p2_completed_text.add_theme_font_size_override(&"font_size", int(completed_text_font_size))
	n_p1_completed_text.size = Vector2(window_size.x, 0.0)
	n_p2_completed_text.size = Vector2(window_size.x, 0.0)
	n_p1_completed_text.position = window_size * COMPLETED_TEXT_P1_POSITION_RATE
	n_p2_completed_text.position = window_size * COMPLETED_TEXT_P2_POSITION_RATE

func _ready() -> void:
	if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
		self_stratagem_line = n_p1_stratagem_line
		opponent_stratagem_line = n_p2_stratagem_line
	elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
		self_stratagem_line = n_p2_stratagem_line
		opponent_stratagem_line = n_p1_stratagem_line
	self_stratagem_line.pressed_correct.connect(on_local_correct)
	self_stratagem_line.pressed_wrong.connect(on_local_wrong)
	self_stratagem_line.stratagem_done.connect(on_local_done)
	n_p1_stratagem_line.change_stratagem_data_to(StratagemHeroEffect_EffectGame.online_in_game_stratagems_list[0], is_dictation_cache)
	n_p2_stratagem_line.change_stratagem_data_to(StratagemHeroEffect_EffectGame.online_in_game_stratagems_list[0], is_dictation_cache)
	n_p1_stratagem_line.lighting = true
	n_p2_stratagem_line.lighting = true

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(delta: float) -> void:
	if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
		if (not was_p1_completed):
			local_complete_time += delta
		elif (was_p2_completed):
			if (remote_complete_time != 0.0 and game_over_confirmed):
				effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_GAME_OVER + ","), MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE)
				game_over()
	elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
		if (not was_p2_completed):
			local_complete_time += delta
	ingame_data_handle_loop()
	self_stratagem_line.update_check_input()
	self_stratagem_line.update(delta)
	opponent_stratagem_line.update(delta)
	if (was_p1_completed):
		p1_completed_text_animation_timer = move_toward(p1_completed_text_animation_timer, COMPLETED_TEXT_ANIMATION_TIME, delta)
	if (was_p2_completed):
		p2_completed_text_animation_timer = move_toward(p2_completed_text_animation_timer, COMPLETED_TEXT_ANIMATION_TIME, delta)
	n_p1_completed_text.modulate.a = p1_completed_text_animation_timer / COMPLETED_TEXT_ANIMATION_TIME
	n_p2_completed_text.modulate.a = p2_completed_text_animation_timer / COMPLETED_TEXT_ANIMATION_TIME

func on_local_done(_line: StratagemHeroEffect_EffectGameCore_StratagemLine, _arrow_count: int, _direction: StratagemData.CodeArrow) -> void:
	local_stratagem_index += 1
	if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
		n_p1_progress_bar.value = local_stratagem_index
	elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
		n_p2_progress_bar.value = local_stratagem_index
	if (StratagemHeroEffect_EffectGame.online_special_effect_mode == StratagemHeroEffect_EffectGame.OnlineSpecialEffectMode.RACING):
		if (local_stratagem_index >= StratagemHeroEffect_EffectGame.ONLINE_SPECIAL_EFFECT_MODE_RACING_STRATAGEMS_COUNT):
			effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_COMPLETE + ","), MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED)
			if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
				complete_p1()
			elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
				complete_p2()
			effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_COMPLETE_TIME + "," + str(int(local_complete_time))), MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE)
			return
		self_stratagem_line.change_stratagem_data_to(StratagemHeroEffect_EffectGame.online_in_game_stratagems_list[local_stratagem_index], false)
	if (is_dictation_cache):
		if (local_stratagem_index >= StratagemHeroEffect_EffectGame.ONLINE_SPECIAL_EFFECT_MODE_DICTATION_RACING_STRATAGEMS_COUNT):
			effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_COMPLETE + ","), MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED)
			if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
				complete_p1()
			elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
				complete_p2()
			return
		self_stratagem_line.change_stratagem_data_to(StratagemHeroEffect_EffectGame.online_in_game_stratagems_list[local_stratagem_index], true)
	effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_STRATAGEM_INDEX + "," + str(local_stratagem_index)), MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED)

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
		push_warning("Dirty data! Stratagem index given by remote peer is out of the bound of the local stratagem list. Disconnecting with remote peer. current_stratagem_index:", current_stratagem_index)
		drop_focus()
		StratagemHeroEffect_EffectGame.instance.soft_disconnect()
		return
	if (opponent_stratagem_index_cache != current_stratagem_index):
		opponent_stratagem_line.change_stratagem_data_to(StratagemHeroEffect_EffectGame.online_in_game_stratagems_list[current_stratagem_index], is_dictation_cache)
		opponent_stratagem_index_cache = current_stratagem_index
	opponent_stratagem_line.set_arrow_index(current_arrow_index)
	if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
		n_p2_progress_bar.value = opponent_stratagem_index_cache
	elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
		n_p1_progress_bar.value = opponent_stratagem_index_cache

## 使P1已完成
func complete_p1() -> void:
	was_p1_completed = true
	n_p1_stratagem_line.death = true
	n_p1_progress_bar.value = n_p1_progress_bar.max_value

## 使P2已完成
func complete_p2() -> void:
	was_p2_completed = true
	n_p2_stratagem_line.death = true
	n_p2_progress_bar.value = n_p2_progress_bar.max_value

## 信号方法-本地战备行按对
func on_local_correct(line: StratagemHeroEffect_EffectGameCore_StratagemLine, _direction: StratagemData.CodeArrow) -> void:
	StratagemHeroEffect_EffectGame.instance.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_ARROW_INDEX + "," + str(line.get_index_of_next_arrow())), MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED)

## 信号方法-本地战备行按错
func on_local_wrong(_line: StratagemHeroEffect_EffectGameCore_StratagemLine, _input_direction: StratagemData.CodeArrow, _correct_direction: StratagemData.CodeArrow) -> void:
	StratagemHeroEffect_EffectGame.instance.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_WRONG + "," + str(local_stratagem_index)), MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED)

func game_over() -> void:
	var game_over_lantern_slide: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_GameOver = StratagemHeroEffect_EffectGameCore_LanternSlideOnline_GameOver.CPS().instantiate() as StratagemHeroEffect_EffectGameCore_LanternSlideOnline_GameOver
	game_over_lantern_slide.set_detail_racing(int(local_complete_time), int(remote_complete_time))
	if (local_complete_time >= remote_complete_time):
		StratagemHeroEffect.instance.audio_game_over.play()
	else:
		StratagemHeroEffect.instance.audio_round_completes[randi_range(0, StratagemHeroEffect.instance.audio_round_completes.size() - 1)].play()
	StratagemHeroEffect.instance.audio_playing_music.stop()
	effect_game_main.n_game_core.add_lantern_slide(game_over_lantern_slide)
	drop_focus()

func ingame_data_handle_loop() -> void:
	var reback_list: Array[StratagemHeroEffect_EffectGame_InGameData] = []
	while (not StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.is_empty()):
		var ingame_data: StratagemHeroEffect_EffectGame_InGameData = StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.pop_front() as StratagemHeroEffect_EffectGame_InGameData
		match (ingame_data.head):
			StratagemHeroEffect_EffectGame_InGameData.DataHead.STRATAGEM_INDEX:
				set_opponent_progress(ingame_data.data.to_int(), 0)
			StratagemHeroEffect_EffectGame_InGameData.DataHead.ARROW_INDEX:
				set_opponent_progress(opponent_stratagem_index_cache, ingame_data.data.to_int())
			StratagemHeroEffect_EffectGame_InGameData.DataHead.COMPLETE:
				if (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST):
					complete_p2()
				elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.CLIENT):
					complete_p1()
			StratagemHeroEffect_EffectGame_InGameData.DataHead.WRONG:
				opponent_stratagem_line.play_wrong()
				set_opponent_progress(ingame_data.data.to_int(), 0)
			StratagemHeroEffect_EffectGame_InGameData.DataHead.GAME_OVER:
				game_over()
			StratagemHeroEffect_EffectGame_InGameData.DataHead.GAME_OVER_CONFIRM:
				game_over_confirmed = true
			StratagemHeroEffect_EffectGame_InGameData.DataHead.COMPLETE_TIME:
				remote_complete_time = ingame_data.data.to_int()
				effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_GAME_OVER_CONFIRM + ","), MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE)
				print("Got remote complete time: ", remote_complete_time)
			_:
				reback_list.append(ingame_data) #不是本幻灯片该处理的，塞回去
	StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.append_array(reback_list)

## 虚方法覆写-当本幻灯片实例抛下焦点后调用，本方法将于广播节点和设置状态之后调用
func _drop_focus_postfix() -> void:
	pass

func _got_focus_postfix() -> void:
	StratagemHeroEffect.instance.audio_playing_music.play()

func get_exitable() -> bool:
	return true

func _on_esc_exit() -> void:
	effect_game_main.soft_disconnect()
