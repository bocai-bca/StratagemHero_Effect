extends StratagemHeroEffect_EffectGameCore_LanternSlide
class_name StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing
## 联机效果模式弹幕夺取幻灯片类

static func CPS() -> PackedScene:
	# 修改此处路径导向本脚本应用于的节点的场景文件
	return preload("res://content/effect_game/core_online/lantern_slides/capturing/lantern_slide_online_capturing.tscn") as PackedScene

var n_super_earth_logo: TextureRect
var n_stratagems_area: StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing_StratagemsArea

## 基本夺取分数，只要完成一个战备就可以获得这个分数
const BASIC_CAPTURED_SCORE: int = 5
## 抢先夺取分数，如果抢先于对手完成这个战备(对手没完成也算)则可以在BASIC_CAPTURED_SCORE的基础上额外获得这个分数
const FIRST_CAPTUED_SCORE: int = 3

## 一个战备在屏幕上停留的标准时间
const STRATAGEM_STAY_TIME_BASIC: float = 6.0
## 一个战备在屏幕上停留的时间浮动值
const STRATAGEM_STAY_TIME_OFFSET: float = 1.5
## 一个战备相较于上一个战备的出现时间间隔标准值
const STRATAGEM_SPAWN_TIME_DELAY_BASIC: float = 1.0
## 一个战备相较于上一个战备的出现时间间隔浮动值
const STRATAGEM_SPAWN_TIME_DELAY_OFFSET: float = 0.5

## 效果模式主类引用，由效果模式主类在创建本幻灯片实例时赋予
var effect_game_main: StratagemHeroEffect_EffectGame
## 战备的出生时间和生存时间数据表，索引与EffectGame.online_in_game_stratagems_list一一对应
var stratagems_time_and_life: Array[StratagemTimeAndLife]
## 对方完成时间，由对方发包过来
var opponent_line_completion_time: PackedFloat64Array
## 本地是否已结束
var was_over: bool = false:
	set(value):
		was_over = value
		send_local_completion_time()
## 对方是否已确认可以游戏结束
var game_over_confirmed: bool = false
## 本地所得分数，在游戏结束后计算。由主机发给客机
var local_score: int = 0
## 对手所得分数，在游戏结束后计算。由主机发给客机
var opponent_score: int = 0
## 是否已向对方发送过分数，仅在主机上有效
var was_sent_scores: bool = false

func _init() -> void:
	opponent_line_completion_time.resize(StratagemHeroEffect_EffectGame.ONLINE_SPECIAL_EFFECT_MODE_CAPTURING_STRATAGEMS_COUNT)
	opponent_line_completion_time.fill(0.0)

func _notification(what: int) -> void:
	if (what == NOTIFICATION_SCENE_INSTANTIATED):
		n_super_earth_logo = $SuperEarthIcon as TextureRect
		n_stratagems_area = $StratagemsArea as StratagemHeroEffect_EffectGameCore_LanternSlideOnline_Capturing_StratagemsArea
		n_stratagems_area.parent = self

func _fit_size(window_size: Vector2) -> void:
	size = window_size
	n_stratagems_area.size = window_size

## 虚方法覆写-幻灯片聚焦状态的过程方法，一般会直接用于State.FOCUS时的_update方法
func _update_focus(delta: float) -> void:
	if (not was_over): #如果本地还没结束
		n_stratagems_area.update(delta)
	elif (effect_game_main.online_side == StratagemHeroEffect_EffectGame.OnlineSide.HOST and not was_sent_scores and opponent_line_completion_time != null): #否则(本地已结束且已收到对方的时间数据)
		calculate_scores()
		effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_SCORES + "," + str(local_score) + " " + str(opponent_score)), MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE)
		was_sent_scores = true
	elif (game_over_confirmed):
		effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_GAME_OVER + ","), MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE)
		game_over()
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
			StratagemHeroEffect_EffectGame_InGameData.DataHead.COMPLETE_TIME:
				if (effect_game_main.online_side != StratagemHeroEffect_EffectGame.OnlineSide.HOST):
					return
				opponent_line_completion_time = ingame_data.data.split_floats(" ", true)
			StratagemHeroEffect_EffectGame_InGameData.DataHead.SCORES:
				var splitted: PackedStringArray = ingame_data.data.split(" ")
				print("splitted: ", splitted)
				if (splitted.size() < 2):
					push_warning("DirtyData! Scores got format error, the size of array splitted is small than excepted.")
					effect_game_main.soft_disconnect()
					return
				local_score = splitted[0].to_int()
				opponent_score = splitted[1].to_int()
				effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_GAME_OVER_CONFIRM + ","), MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE)
			_:
				reback_list.append(ingame_data) #不是本幻灯片该处理的，塞回去
	StratagemHeroEffect_EffectGame.online_opponent_in_game_data_list.append_array(reback_list)

## 计算两方的分数
func calculate_scores() -> void:
	local_score = 0
	opponent_score = 0
	var local_completion_time: PackedFloat32Array = n_stratagems_area.line_completion_time
	for i in opponent_line_completion_time.size():
		var local_time: float = local_completion_time[i]
		var opponent_time: float = opponent_line_completion_time[i]
		if (local_time > 0.0):
			local_score += BASIC_CAPTURED_SCORE
			if (local_time > opponent_score):
				local_score += FIRST_CAPTUED_SCORE
		if (opponent_time > 0.0):
			opponent_score += BASIC_CAPTURED_SCORE
			if (opponent_score > local_time):
				opponent_score += FIRST_CAPTUED_SCORE
	print("Local score: ", local_score, ". Opponent score: ", opponent_score)

## 为一个战备行设置被夺取效果
func set_line_captured(line_index: int) -> void:
	if (line_index >= opponent_line_completion_time.size()):
		return
	opponent_line_completion_time[line_index] = 1.0
	n_stratagems_area.set_line_captured(line_index)

## 向对方发送本地的完成时间情况
func send_local_completion_time() -> void:
	var completion_time_string: String = ""
	var attach_space: bool = false
	for time in n_stratagems_area.line_completion_time:
		if (attach_space):
			completion_time_string += " "
			attach_space = false
		completion_time_string += str(time)
		attach_space = true
	effect_game_main.send_pack(StratagemHeroEffect_EffectGame_OnlineCode.new(StratagemHeroEffect_EffectGame_OnlineCode.Code.INGAME_DATA, StratagemHeroEffect_EffectGame_InGameData.HEAD_COMPLETE_TIME + "," + completion_time_string), MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE)

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

func _got_focus_postfix() -> void:
	stratagems_time_and_life = []
	var last_spawn_time: float = 0.0
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = effect_game_main.online_seed_cache
	for i in effect_game_main.online_in_game_stratagems_list.size():
		last_spawn_time += STRATAGEM_SPAWN_TIME_DELAY_BASIC + random.randf_range(-STRATAGEM_SPAWN_TIME_DELAY_OFFSET, STRATAGEM_SPAWN_TIME_DELAY_OFFSET)
		var stratagem_time_and_life: StratagemTimeAndLife = StratagemTimeAndLife.new()
		stratagem_time_and_life.spawn_time = last_spawn_time
		stratagem_time_and_life.life_time = STRATAGEM_STAY_TIME_BASIC + random.randf_range(-STRATAGEM_STAY_TIME_OFFSET, STRATAGEM_STAY_TIME_OFFSET)
		stratagems_time_and_life.append(stratagem_time_and_life)

## 战备的出生时间和生存时间数据
class StratagemTimeAndLife extends RefCounted:
	## 出生时间
	var spawn_time: float
	## 在屏幕上能够存在的时间
	var life_time: float
